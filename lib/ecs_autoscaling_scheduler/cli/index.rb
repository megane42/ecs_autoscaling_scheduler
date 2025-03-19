# frozen_string_literal: true

require "tty-prompt"

module EcsAutoscalingScheduler
  class Cli
    class Index
      def run(option)
        cluster_name = option.cluster_name || ask_cluster_name
        service_name = option.service_name || ask_service_name(cluster_name)

        scheduled_actions = application_auto_scaling_client.describe_scheduled_actions(
          cluster_name: cluster_name,
          service_name: service_name,
        )

        scheduled_actions.sort_by(&:schedule).each do |a|
          puts "* name: #{a.scheduled_action_name}, min: #{a.scalable_target_action.min_capacity}, max: #{a.scalable_target_action.max_capacity}, schedule: #{a.schedule}, timezone: #{a.timezone}"
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
          prompt.select("Which cluster do you want to see?", ecs_client.all_cluster_names, required: true)
        end

        def ask_service_name(cluster)
          prompt.select("Which service do you want to see?", ecs_client.all_service_names(cluster: cluster), required: true)
        end
    end
  end
end
