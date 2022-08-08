# frozen_string_literal: true

require_relative "cli/index"
require_relative "cli/create"
require_relative "cli/destroy"
require_relative "cli/bye"

require "tty-prompt"

module EcsAutoscalingScheduler
  class Cli
    COMMAND = {
      index: "index",
      create: "create",
      destroy: "destroy",
      bye: "bye",
    }

    def run
      case ask_command
      when COMMAND[:index]
        Index.new.run
      when COMMAND[:create]
        Create.new.run
      when COMMAND[:destroy]
        Destroy.new.run
      else
        Bye.new.run
      end
    end

    private
      def prompt
        @prompt ||= TTY::Prompt.new
      end

      def ask_command
        prompt.select("Which command do you want to do?", COMMAND.values, required: true)
      end
  end
end
