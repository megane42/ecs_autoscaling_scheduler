# frozen_string_literal: true

require "tty-prompt"

module EcsAutoscalingScheduler
  class Cli
    def index
      cluster_name = ask_cluster_name
      service_name = ask_service_name(cluster_name)

      scheduled_actions = application_auto_scaling_client.describe_scheduled_actions(cluster_name: cluster_name, service_name: service_name)

      scheduled_actions.each do |scheduled_action|
        pp scheduled_action
      end
    end

    def create
      cluster_name          = ask_cluster_name
      service_name          = ask_service_name(cluster_name)
      schedule              = ask_schedule
      min_capacity          = ask_min_capacity
      max_capacity          = ask_max_capacity
      scheduled_action_name = ask_scheduled_action_name(schedule, min_capacity, max_capacity)

      application_auto_scaling_client.put_scheduled_action(
        cluster_name:          cluster_name,
        service_name:          service_name,
        scheduled_action_name: scheduled_action_name,
        schedule_datetime:     schedule,
        min_capacity:          min_capacity,
        max_capacity:          max_capacity,
      )
    end

    def destroy
      cluster_name          = ask_cluster_name
      service_name          = ask_service_name(cluster_name)
      scheduled_action_name = ask_to_select_scheduled_action_name(cluster_name, service_name)

      application_auto_scaling_client.delete_scheduled_action(cluster_name: cluster_name, service_name: service_name, scheduled_action_name: scheduled_action_name)
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
        prompt.select("Which cluster do you want to scale?", ecs_client.all_cluster_names, required: true)
      end

      def ask_service_name(cluster)
        prompt.select("Which service do you want to scale?", ecs_client.all_service_names(cluster: cluster), required: true)
      end

      def ask_schedule
        prompt.ask("What time do you want to scale? (YYYY-MM-DD hh:mm:ss)", required: true, convert: :time)
      end

      def ask_min_capacity
        prompt.ask("What is the MIN capacity?", required: true)
      end

      def ask_max_capacity
        prompt.ask("What is the MAX capacity?", required: true)
      end

      def ask_scheduled_action_name(schedule, min_capacity, max_capacity)
        prompt.ask("What is the name of the scheduled action?", default: "#{schedule.strftime('%Y%m%d-%H%M%S')}-min-#{min_capacity}-max-#{max_capacity}", required: true)
      end

      def ask_to_select_scheduled_action_name(cluster_name, service_name)
        prompt.select("What is the name of the scheduled action?", application_auto_scaling_client.describe_scheduled_actions(cluster_name: cluster_name, service_name: service_name).map(&:scheduled_action_name), required: true)
      end
  end
end
