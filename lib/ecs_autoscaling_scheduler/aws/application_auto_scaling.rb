require "aws-sdk-applicationautoscaling"

module EcsAutoscalingScheduler
  module Aws
    class ApplicationAutoScaling
      def initialize(client: ::Aws::ApplicationAutoScaling::Client.new, timezone: "UTC")
        @client   = client
        @timezone = timezone
      end

      def describe_scheduled_actions
        client.describe_scheduled_actions(
          {
            service_namespace: "ecs",
          }
        )
      end

      def put_scheduled_action(scheduled_action_name:, schedule_datetime:, min_capacity:, max_capacity:, resource_id:)
        client.put_scheduled_action(
          {
            service_namespace: "ecs",
            scalable_dimension: "ecs:service:DesiredCount",
            scheduled_action_name: scheduled_action_name,
            schedule: "at(#{schedule_datetime.strftime("%FT%T")})",
            timezone: timezone,
            scalable_target_action: {
              min_capacity: min_capacity,
              max_capacity: max_capacity,
            },
            resource_id: resource_id
          }
        )
      end

      def delete_scheduled_action(scheduled_action_name:, resource_id:)
        client.delete_scheduled_action(
          {
            service_namespace: "ecs",
            scalable_dimension: "ecs:service:DesiredCount",
            scheduled_action_name: scheduled_action_name,
            resource_id: resource_id,
          }
        )
      end

      private

      attr_reader :client, :timezone
    end
  end
end
