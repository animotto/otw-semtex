# frozen_string_literal: true

require 'readline'

module Semtex
  ##
  # Shell
  class Shell
    PROMPT = 'Semtex> '

    def initialize
      @in = $stdin
      @out = $stdout
    end

    def log(message)
      @out.puts(message)
    end

    def run
      semtex = Semtex.new(self)

      loop do
        line = Readline.readline(PROMPT, true)
        break unless line

        line.strip!
        next if line.empty?

        words = line.split(/\s+/)
        cmd = words[0].downcase
        case cmd
        when 'quit', 'q'
          break

        when 'level', 'l'
          if words.length < 2
            log('Specify level')
            next
          end

          level = words[1].to_i
          semtex.level = level
          semtex.exec
        end
      end
    end
  end
end
