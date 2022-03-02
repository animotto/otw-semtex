# frozen_string_literal: true

module Semtex
  ##
  # Semtex
  class Semtex
    attr_accessor :level

    def initialize(shell)
      @shell = shell
      @level = 0
      @levels = []
      LevelBase.successors.each do |successor|
        @levels << successor.new(@shell)
      end
    end

    def exec
      level = @levels.detect { |l| l.class::LEVEL == @level }
      unless level
        @shell.log('Unknown level')
        return
      end

      level.exec
    end
  end
end
