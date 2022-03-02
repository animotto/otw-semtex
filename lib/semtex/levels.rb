# frozen_string_literal: true

module Semtex
  ##
  # Level base
  class LevelBase
    HOST = 'semtex.labs.overthewire.org'

    @@successors = []

    class << self
      def inherited(subclass)
        super
        @@successors << subclass
      end

      def successors
        @@successors
      end
    end

    def initialize(shell)
      @shell = shell
    end

    def exec; end
  end

  ##
  # Level 0
  class Level0 < LevelBase
    LEVEL = 0
  end
end
