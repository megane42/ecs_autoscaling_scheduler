# frozen_string_literal: true

require "aws-sdk-applicationautoscaling"

module EcsAutoscalingScheduler
  module Aws
    class ApplicationAutoScaling
      def initialize(client: ::Aws::ApplicationAutoScaling::Client.new)
        @client = client
      end

      def describe_scheduled_actions(cluster_name:, service_name:)
        client.describe_scheduled_actions(
          {
            service_namespace: "ecs",
            resource_id: resource_id(cluster_name: cluster_name, service_name: service_name),
          }
        ).scheduled_actions
      end

      def put_scheduled_action(cluster_name:, service_name:, scheduled_action_name:, schedule_datetime:, timezone:, min_capacity:, max_capacity:)
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
            resource_id: resource_id(cluster_name: cluster_name, service_name: service_name),
          }
        )
      end

      def delete_scheduled_action(cluster_name:, service_name:, scheduled_action_name:)
        client.delete_scheduled_action(
          {
            service_namespace: "ecs",
            scalable_dimension: "ecs:service:DesiredCount",
            scheduled_action_name: scheduled_action_name,
            resource_id: resource_id(cluster_name: cluster_name, service_name: service_name),
          }
        )
      end

      private
        attr_reader :client

        def resource_id(cluster_name:, service_name:)
          "service/#{cluster_name}/#{service_name}"
        end
    end
  end
end
