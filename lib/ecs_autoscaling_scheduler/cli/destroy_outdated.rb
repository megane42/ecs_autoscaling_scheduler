# frozen_string_literal: true

require "tty-prompt"
require "time"
require "tzinfo"

module EcsAutoscalingScheduler
  class Cli
    class DestroyOutDated
      def run
        cluster_name = ask_cluster_name
        service_name = ask_service_name(cluster_name)

        scheduled_actions = application_auto_scaling_client.describe_scheduled_actions(cluster_name: cluster_name, service_name: service_name)
        if scheduled_actions.length == 0
          puts "There is no scheduled action."
          return
        end

        now = Time.now
        outdated_scheduled_actions = scheduled_actions.filter do |scheduled_action|
          timezone   = TZInfo::Timezone.get(scheduled_action.timezone)
          time_local = Time.parse(scheduled_action.schedule)
          time_utc   = timezone.local_to_utc(time_local)
          time_utc < now
        end
        if outdated_scheduled_actions.length == 0
          puts "There is no outdated scheduled action."
          return
        end

        if ask_ok(outdated_scheduled_actions.length)
          outdated_scheduled_actions.each do |outdated_scheduled_action|
            puts "Destroying #{outdated_scheduled_action.scheduled_action_name}..."
            application_auto_scaling_client.delete_scheduled_action(
              cluster_name: cluster_name,
              service_name: service_name,
              scheduled_action_name: outdated_scheduled_action.scheduled_action_name,
            )
          end
          puts "Destroy complete."
        else
          puts "Destroy cancelled."
        end
      end

      private
        def prompt
          @prompt ||= TTY::Prompt.new
        end

        def ecs_client
          @ecs_client ||= EcsAutoscalingScheduler::Aws::Ecs.new
        end

        def application_auto_scaling_client
          @application_auto_scaling_client ||= EcsAutoscalingScheduler::Aws::ApplicationAutoScaling.new
        end

        def ask_cluster_name
          prompt.select("Which cluster do you want to manage?", ecs_client.all_cluster_names, required: true)
        end

        def ask_service_name(cluster)
          prompt.select("Which service do you want to manage?", ecs_client.all_service_names(cluster: cluster), required: true)
        end

        def ask_ok(num_outdated)
          prompt.yes?("Do you want to destroy all (#{num_outdated}) outdated scheduled actions?", required: true)
        end
    end
  end
end
