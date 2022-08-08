# frozen_string_literal: true

require_relative "ecs_autoscaling_scheduler/version"
require_relative "ecs_autoscaling_scheduler/aws"

module EcsAutoscalingScheduler
  class Error < StandardError; end
end
