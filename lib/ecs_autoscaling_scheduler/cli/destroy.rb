# frozen_string_literal: true

require "tty-prompt"

module EcsAutoscalingScheduler
  class Cli
    class Destroy
      def run
        cluster_name          = ask_cluster_name
        service_name          = ask_service_name(cluster_name)
        scheduled_action_name = ask_scheduled_action_name(cluster_name, service_name)

        if ask_ok
          application_auto_scaling_client.delete_scheduled_action(
            cluster_name: cluster_name,
            service_name: service_name,
            scheduled_action_name: scheduled_action_name,
          )
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

        def ask_scheduled_action_name(cluster_name, service_name)
          prompt.select("Which scheduled action do you want to destroy?", application_auto_scaling_client.describe_scheduled_actions(cluster_name: cluster_name, service_name: service_name).map(&:scheduled_action_name), required: true)
        end

        def ask_ok
          prompt.yes?("Do you want to destroy this scheduled action?", required: true)
        end
    end
  end
end
