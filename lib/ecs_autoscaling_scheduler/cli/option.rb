# frozen_string_literal: true

module EcsAutoscalingScheduler
  class Cli
    class Option
      attr_reader :command
      attr_reader :cluster_name
      attr_reader :service_name
      attr_reader :timezone
      attr_reader :schedule
      attr_reader :min_capacity
      attr_reader :max_capacity
      attr_reader :scheduled_action_name

      def initialize(**kwargs)
        @command               = kwargs[:command]
        @cluster_name          = kwargs[:cluster_name]
        @service_name          = kwargs[:service_name]
        @timezone              = kwargs[:timezone]
        @schedule              = kwargs[:schedule]
        @min_capacity          = kwargs[:min_capacity]
        @max_capacity          = kwargs[:max_capacity]
        @scheduled_action_name = kwargs[:scheduled_action_name]
      end
    end
  end
end
