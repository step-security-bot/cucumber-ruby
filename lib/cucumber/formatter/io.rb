# frozen_string_literal: true

require 'cucumber/formatter/http_io'
require 'cucumber/formatter/url_reporter'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    module Io
      module_function

      attr_reader :ios

      def ensure_io(path_or_url_or_io)
        return nil if path_or_url_or_io.nil?
        io = if io?(path_or_url_or_io)
               path_or_url_or_io
             elsif url?(path_or_url_or_io)
               url = path_or_url_or_io
               reporter = url.start_with?(Cucumber::Cli::Options::CUCUMBER_PUBLISH_URL) ? URLReporter.new($stdout) : NoReporter.new
               HTTPIO.open(url, nil, reporter)
             else
               File.open(path_or_url_or_io, Cucumber.file_mode('w'))
             end
        @ios ||= []
        @ios.push(io)
        io
      end

      # at_exit do
      #   unless io.closed?
      #     io.flush
      #     io.close
      #   end
      # end

      module ClassMethods
        def new(*args, &block)
          instance = super

          config = args[0]
          if config.respond_to? :on_event
            config.on_event :test_run_finished do
              puts "#### #{instance.ios}"
            end
          end

          instance
        end
      end

      def self.included(formatter_class)
        formatter_class.extend(ClassMethods)
      end

      def initialize(_config)
        puts 'io initialize called'
      end

      def io?(path_or_url_or_io)
        path_or_url_or_io.respond_to?(:write)
      end

      def url?(path_or_url_or_io)
        path_or_url_or_io.match(%r{^https?://})
      end

      def ensure_file(path, name)
        raise "You *must* specify --out FILE for the #{name} formatter" unless String == path.class
        raise "I can't write #{name} to a directory - it has to be a file" if File.directory?(path)
        raise "I can't write #{name} to a file in the non-existing directory #{File.dirname(path)}" unless File.directory?(File.dirname(path))
        ensure_io(path)
      end

      def ensure_dir(path, name)
        raise "You *must* specify --out DIR for the #{name} formatter" unless String == path.class
        raise "I can't write #{name} reports to a file - it has to be a directory" if File.file?(path)
        FileUtils.mkdir_p(path) unless File.directory?(path)
        File.absolute_path path
      end
    end
  end
end
