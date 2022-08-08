# frozen_string_literal: true

require_relative "ecs_autoscaling_scheduler/version"
require_relative "ecs_autoscaling_scheduler/aws/application_auto_scaling"
require_relative "ecs_autoscaling_scheduler/aws/ecs"

module EcsAutoscalingScheduler
  class Error < StandardError; end
  # Your code goes here...
end
