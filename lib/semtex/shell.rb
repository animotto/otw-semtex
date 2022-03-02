# frozen_string_literal: true

require 'readline'

module Semtex
  ##
  # Shell
  class Shell
    BANNER = <<~ENDBANNER
    ____________________________

     OverTheWire wargame Semtex
    ____________________________

    ENDBANNER

    PROMPT = 'Semtex> '

    def initialize
      @in = $stdin
      @out = $stdout
    end

    def log(message = '')
      @out.puts(message)
    end

    def choose(title, list)
      @out.puts(title)
      list.each_with_index do |item, i|
        @out.puts(" #{i + 1}) #{item}")
      end

      @out.puts
      @out.print('= ')
      index = @in.gets.to_i - 1
      if index.negative? || index >= list.length
        @out.puts('Invalid choice')
        return nil
      end

      index
    end

    def run
      semtex = Semtex.new(self)
      log(BANNER)

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
            log('Specify the level')
            next
          end

          level = words[1].to_i
          semtex.level = level
          semtex.exec

        else
          log('Unrecognized command')
        end
      end
    end
  end
end
