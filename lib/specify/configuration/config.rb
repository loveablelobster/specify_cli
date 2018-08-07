# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class Config
      attr_reader :dir_names, :hosts

      def initialize(file = nil, dir_names: nil, hosts: nil)
        @file = Pathname.new(file || DATABASES)
        if dir_names || hosts
          @dir_names = dir_names
          @hosts = hosts
          @params = { dir_names: dir_names, hosts: hosts }
        else
          @params = Psych.load_file(@file)
          @dir_names = @params[:dir_names]
          @hosts = @params[:hosts]
        end
        yield(self) if block_given?
      end

      def self.empty(&block)
        new dir_names: {}, hosts: {}, &block
      end

      def add_host(name, port = nil)
        raise "Host '#{name}' already configured" if hosts[name]
        hosts[name] = { port: port, databases: {} }
      end

      def add_database(name, host:)
        add_host(host) unless hosts[host]
        if hosts.dig host, :databases, name
          raise "Database '#{name}' on '#{host}' already configured"
        end
        db = hosts[host][:databases][name] = db_template
        yield(db) if block_given?
      end

      def map_host(host, directory:)
        raise "Directory '#{directory}' already mapped" if dir_names[directory]
        dir_names[directory] = host
      end

      def params
        { dir_names: @dir_names, hosts: @hosts }
      end

      def save
        File.open(@file, 'w') do |file|
          file.write(Psych.dump(@params))
        end
        true
      end

      private

      def proceed?(message)
        STDERR.puts message
        STDERR.print "Configure? (Y/n)"
        return true if /^[Yy](es)?/.match Readline.readline(': ')
      end

      def require_input(message)
        STDERR.print message
        answer = Readline.readline(': ')
        return if answer.empty?
        answer
      end

      def db_template
        {
          db_user: { name: nil, password: nil },
          sp_user: nil
        }
      end
    end
  end
end
