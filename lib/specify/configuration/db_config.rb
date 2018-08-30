# frozen_string_literal: true

module Specify
  module Configuration
    # DBConfigs are Specify:Database configurations.
    class DBConfig < Config
      # The name of the _Specify_ database.
      attr_reader :database

      # The name of the MySQL/MariaDB host for the _Specify_ database.
      attr_reader :host

      # The port for the MySQL/MariaDB server for the _Specify_ database.
      attr_reader :port

      # The MySQL/MariaDB user for the database. This is typically the _Specify_
      # <em>master user</em>.
      attr_reader :user_name

      # An existing Specify::Model::User#name; the name of the
      # Specify::Model::User that is logged in to #collection during a Session.
      attr_reader :session_user

      # Returns a new DBConfig for +database+ on +host+
      #
      # _file_: the YAML file (path) containg the configuration.
      def initialize(host, database, file = nil)
        super(file)
        @host = host
        @database = database
        @port = hosts.dig @host, :port
        @user_name = params&.dig :db_user, :name
        @user_password = params&.dig :db_user, :password
        @session_user = params&.fetch :sp_user, nil
        @saved = known? ? true : false
      end

      # Returns the connection paramaters for the database as a Hash.
      def connection
        raise "#{database} on #{host} not configured" unless known?
        { host: host,
          port: port || 3306,
          user: user_name,
          password: @user_password }
      end

      # Returns +true+ if #user_name differs from the user +:name+ in the
      # #params of the YAML file.
      def changed_user?
        params[:db_user][:name] != user_name
      end

      # Returns +true+ if the <em>user_password</em> attribute differs from the
      # +:password+ in the #params of the YAML file.
      def changed_password?
        params[:db_user][:password] != @user_password
      end

      # Returns +true+ if #port differs from the +:port+ in the #params of the
      # YAML file.
      def changed_port?
        hosts[host][:port] != port
      end

      # Returns +true+ if the #session_user differs from the <tt>:so_user</tt>
      # in the #params of the YAML file.
      def changed_session_user?
        params[:sp_user] != session_user
      end

      # Sets the #database.
      def database=(name)
        @database = name
        touch
      end

      # Returns a Hash with the MySQL/MariaDB user name and password.
      def db_user
        { name: @user_name, password: @user_password }
      end

      # Sets the #host
      def host=(name)
        @host = name
        touch
      end

      # Returns +true+ if #host is known (has been configured), +false+
      # otherwise.
      def host?
        hosts[host]
      end

      # Returns +true+ if #database is known (has been configured), +false+
      # otherwise.
      def known?
        params ? true : false
      end

      # Returns a Hash with the parameters for the #host #database from the
      # configuration YAML file.
      def params
        super.dig:hosts, @host, :databases, @database
      end

      # Sets the #port
      def port=(number)
        @port = number&.to_i
        raise ArgumentError, "invalid port number: #{number}" unless port_valid?
        touch
      end

      # Saves the current state to the YAML file.
      def save
        return true if saved?
        host? ? update_host : save_new_host
        super
      end

      # Sets #session_user.
      def session_user=(name)
        @session_user = name
        touch
      end

      # Sets the #user_name.
      def user_name=(name)
        @user_name = name
        touch
      end

      # Sets the MySQL/MariaDB <em>user_password</em>.
      def user_password=(password)
        @user_password = password
        touch
      end

      private

      def save_new_host
        add_host host, port
        add_database database, host: host
      end

      def update_database
        params[:db_user][:name] = user_name if changed_user?
        params[:db_user][:password] = @user_password if changed_password?
        params[:sp_user] = session_user if changed_session_user?
      end

      def update_host
        hosts[host][:port] = port if changed_port?
        add_database database, host: host unless known?
        update_database
      end

      def port_valid?
        port.nil? || port.to_i.positive?
      end
    end
  end
end
