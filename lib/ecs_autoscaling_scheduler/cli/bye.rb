# frozen_string_literal: true

require "tty-prompt"

module EcsAutoscalingScheduler
  class Cli
    class Bye
      def run
        puts "bye."
      end
    end
  end
end
