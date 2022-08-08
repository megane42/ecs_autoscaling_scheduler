# frozen_string_literal: true

require "aws-sdk-ecs"

module EcsAutoscalingScheduler
  module Aws
    class Ecs
      def initialize(client: ::Aws::ECS::Client.new)
        @client = client
      end

      def all_cluster_names
        cluster_arns = client.list_clusters.cluster_arns
        client.describe_clusters(clusters: cluster_arns).clusters.map(&:cluster_name)
      end

      def all_service_names(cluster:)
        service_arns = client.list_services(cluster: cluster).service_arns
        client.describe_services(cluster: cluster, services: service_arns).services.map(&:service_name)
      end

      private
        attr_reader :client
    end
  end
end
