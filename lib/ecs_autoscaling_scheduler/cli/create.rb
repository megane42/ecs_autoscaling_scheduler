# frozen_string_literal: true

require "tty-prompt"
require "active_support"
require "active_support/time"

module EcsAutoscalingScheduler
  class Cli
    class Create
      def run(option)
        cluster_name          = option.cluster_name          || ask_cluster_name
        service_name          = option.service_name          || ask_service_name(cluster_name)
        timezone              = option.timezone              || ask_timezone
        schedule              = option.schedule              || ask_schedule
        min_capacity          = option.min_capacity          || ask_min_capacity
        max_capacity          = option.max_capacity          || ask_max_capacity
        scheduled_action_name = option.scheduled_action_name || ask_scheduled_action_name(schedule, min_capacity, max_capacity)

        if ask_ok
          application_auto_scaling_client.put_scheduled_action(
            cluster_name:          cluster_name,
            service_name:          service_name,
            scheduled_action_name: scheduled_action_name,
            schedule_datetime:     schedule,
            timezone:              timezone,
            min_capacity:          min_capacity,
            max_capacity:          max_capacity,
          )
          puts "Create complete."
        else
          puts "Create cancelled."
        end
      end

      private
        def prompt
          @prompt ||= TTY::Prompt.new(interrupt: :signal)
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

        def ask_timezone
          prompt.ask("What is your time zone? (use 'Canonical ID' of https://www.joda.org/joda-time/timezones.html)", default: guess_timezone_name, required: true)
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

        def ask_ok
          prompt.yes?("Do you want to create this scheduled action?", required: true)
        end

        def guess_timezone_name
          # https://github.com/rails/rails/blob/v6.0.2.1/railties/lib/rails/tasks/misc.rake#L41-L51
          # https://blog.onk.ninja/2020/01/31/guess_local_timezone
          jan_offset = Time.now.beginning_of_year.utc_offset
          jul_offset = Time.now.beginning_of_year.change(month: 7).utc_offset
          offset     = jan_offset < jul_offset ? jan_offset : jul_offset
          ActiveSupport::TimeZone.all.detect { |zone| zone.utc_offset == offset }.tzinfo.name
        end
    end
  end
end
