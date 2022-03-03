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
      'x86/elf' => 24_000,
      'amd64/elf' => 24_001,
      'ppc/mach-o' => 24_002
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
      File.chmod(0o700, file.path)
      password = `#{file.path}`
      @shell.log("Password: #{password}") unless password.empty?
      file.unlink
    end
  end

  ##
  # Level 1
  class Level1 < LevelBase
    LEVEL = 1

    ROUNDS = 99

    def exec
      line = @shell.readline('Enter encrypted password: ')
      line.strip!
      unless line =~ /^[A-Z]{10,20}$/
        @shell.log('Invalid password. Must be 10-20 characters A-Z')
        return
      end

      password = line.clone
      @shell.log("Decrypting (#{ROUNDS} rounds)")
      ROUNDS.times do
        password = decrypt(password)
      end

      @shell.log("Password: #{password}")
    end

    private

    def encrypt(input)
      output = Array.new(input.length, 0)
      data = input.bytes.map { |b| b - 'A'.ord }

      o = 0
      n = input.length - 10 + 1
      n.times { |i| o += i + 1 }
      output[0] = (data[-1] + 6 + o) % 26

      output[-3] = data[0]
      output[-2] = (data[1] + 1) % 26
      output[-1] = (data[2] + 1) % 26

      output[1] = (data[3] + 1) % 26
      output[2] = (data[4] + 2) % 26
      output[3] = (data[5] + 2) % 26
      output[4] = (data[6] + 3) % 26
      output[5] = (data[7] + 4) % 26
      output[6] = (data[8] + 5) % 26

      n = input.length - 10
      o = 0
      n.times do |i|
        o += i + 1
        output[7 + i] = (data[9 + i] + 6 + o) % 26
      end

      output.map { |b| (b + 'A'.ord).chr }.join
    end

    def decrypt(input)
      output = Array.new(input.length, 0)
      data = input.bytes.map { |b| b - 'A'.ord }

      o = 0
      n = input.length - 10 + 1
      n.times { |i| o += i + 1 }
      output[-1] = (data[0] - 6 - o) % 26

      output[0] = data[-3]
      output[1] = (data[-2] - 1) % 26
      output[2] = (data[-1] - 1) % 26

      output[3] = (data[1] - 1) % 26
      output[4] = (data[2] - 2) % 26
      output[5] = (data[3] - 2) % 26
      output[6] = (data[4] - 3) % 26
      output[7] = (data[5] - 4) % 26
      output[8] = (data[6] - 5) % 26

      n = input.length - 10
      o = 0
      n.times do |i|
        o += i + 1
        output[9 + i] = (data[7 + i] - 6 - o) % 26
      end

      output.map { |b| (b + 'A'.ord).chr }.join
    end
  end
end
