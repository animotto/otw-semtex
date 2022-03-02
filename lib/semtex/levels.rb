# frozen_string_literal: true

require 'socket'
require 'tempfile'

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
    PORTS = {
      'x86/elf' => 24000,
      'amd64/elf' => 24001,
      'ppc/mach-o' => 24002
    }.freeze

    def exec
      list = PORTS.keys
      index = @shell.choose('Choose your platform:', list)
      return unless index

      port = PORTS[list[index]]
      @shell.log("Connecting to #{HOST}:#{port}")
      socket = TCPSocket.new(HOST, port)
      data = socket.read
      socket.close

      file = Tempfile.new
      @shell.log("Writing data to temporary file: #{file.path}")
      data.bytesize.times do |i|
        next if !i.zero? && i.odd?

        file.write(data[i])
      end
      file.close

      @shell.log('Running executable file')
      File.chmod(0700, file.path)
      password = `#{file.path}`
      @shell.log("Password: #{password}") unless password.empty?
    end
  end
end
