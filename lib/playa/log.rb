require 'fileutils'
require 'logger'
require 'time'

module Playa
  # :nocov:
  class MonoLogger < Logger
    # Create a trappable Logger instance.
    #
    # @param logdev [String|IO] The filename (String) or IO object (typically
    #   STDOUT, STDERR or an open file).
    # @param shift_age [] Number of old log files to keep, or frequency of
    #   rotation (daily, weekly, monthly).
    # @param shift_size [] Maximum log file size (only applies when shift_age
    #   is a number).
    #
    # @example
    #   Logger.new(name, shift_age = 7, shift_size = 1048576)
    #   Logger.new(name, shift_age = 'weekly')
    #
    def initialize(logdev, shift_age=nil, shift_size=nil)
      @progname = nil
      @level = DEBUG
      @default_formatter = Formatter.new
      @formatter = nil
      @logdev = nil
      if logdev
        @logdev = LocklessLogDevice.new(logdev)
      end
    end

    class LocklessLogDevice < LogDevice
      def initialize(log = nil)
        @dev = @filename = @shift_age = @shift_size = nil
        if log.respond_to?(:write) and log.respond_to?(:close)
          @dev = log
        else
          @dev = open_logfile(log)
          @dev.sync = true
          @filename = log
        end
      end

      def write(message)
        @dev.write(message)
      rescue Exception => ignored
        warn("log writing failed. #{ignored}")
      end

      def close
        @dev.close rescue nil
      end

    private

      def open_logfile(filename)
        if (FileTest.exist?(filename))
          open(filename, (File::WRONLY | File::APPEND))
        else
          create_logfile(filename)
        end
      end

      def create_logfile(filename)
        logdev = open(filename, (File::WRONLY | File::APPEND | File::CREAT))
        logdev.sync = true
        add_log_header(logdev)
        logdev
      end

      def add_log_header(file)
        file.write(
          "# Logfile created on %s by %s\n" % [Time.now.to_s, Logger::ProgName]
        )
      end
    end
  end

  class Log

    # @return [TrueClass]
    def self.logger
      @logger ||= MonoLogger.new(filename).tap do |log|
        log.formatter = proc do |_, time, _, message|
          time.utc.iso8601 + ": " + message + "\n"
        end
      end
    end

    private

    # @api private
    # @return [String]
    def self.filename
      @_filename ||= directory + '/playa.log'
    end

    # @api private
    # @return [String]
    def self.directory
      FileUtils.mkdir_p(path) unless File.directory?(path)

      path
    end

    # @api private
    # @return [String]
    def self.path
      Dir.home + '/.playa'
    end

  end
  # :nocov:
end
