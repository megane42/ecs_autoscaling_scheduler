# frozen_string_literal: true

require_relative "ecs_autoscaling_scheduler/version"
require_relative "ecs_autoscaling_scheduler/aws"
require_relative "ecs_autoscaling_scheduler/cli"

module EcsAutoscalingScheduler
  class Error < StandardError; end
end
