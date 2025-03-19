# frozen_string_literal: true

require_relative "cli/index"
require_relative "cli/create"
require_relative "cli/destroy"
require_relative "cli/destroy_outdated"
require_relative "cli/bye"
require_relative "cli/option"

require "tty-prompt"
require "optparse"

module EcsAutoscalingScheduler
  class Cli
    COMMAND = {
      index: "index",
      create: "create",
      destroy: "destroy",
      destroy_outdated: "destroy_outdated",
      bye: "bye",
    }

    def run
      option = parse_option
      case option.command || ask_command
      when COMMAND[:index]
        Index.new.run(option)
      when COMMAND[:create]
        Create.new.run(option)
      when COMMAND[:destroy]
        Destroy.new.run(option)
      when COMMAND[:destroy_outdated]
        DestroyOutdated.new.run(option)
      else
        Bye.new.run
      end
    end

    private
      def parse_option
        option_params = {}

        OptionParser.new do |opts|
          opts.on("-x VALUE", "--command VALUE")               { |v| option_params[:command] = v }
          opts.on("-c VALUE", "--cluster-name VALUE")          { |v| option_params[:cluster_name] = v }
          opts.on("-s VALUE", "--service-name VALUE")          { |v| option_params[:service_name] = v }
          opts.on("-z VALUE", "--timezone VALUE")              { |v| option_params[:timezone] = v }
          opts.on("-t VALUE", "--schedule VALUE")              { |v| option_params[:schedule] = Time.parse(v) }
          opts.on("-m VALUE", "--min-capacity VALUE", Integer) { |v| option_params[:min_capacity] = v }
          opts.on("-M VALUE", "--max-capacity VALUE", Integer) { |v| option_params[:max_capacity] = v }
          opts.on("-n VALUE", "--scheduled-action-name VALUE") { |v| option_params[:scheduled_action_name] = v }
        end.parse!

        Option.new(**option_params)
      end

      def prompt
        @prompt ||= TTY::Prompt.new
      end

      def ask_command
        prompt.select("Which command do you want to do?", COMMAND.values, required: true)
      end
  end
end
