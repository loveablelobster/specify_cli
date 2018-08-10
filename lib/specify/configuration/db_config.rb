# frozen_string_literal: true

module Specify
  module Configuration
    # A class that represents a Specify database configuration.
    class DBConfig < Config
      attr_reader :database, :user_name, :host, :port, :session_user

      # -> Configuration::DBConfig
      # Creates a new instance
      # _host_: String, the name or IP of the MySQL/MariaDB host
      # _database_: String, the name of the database
      # _file_: the YAML file (path) containg the configuration
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

      # -> Hash
      # Returns the connection paramaters for the database as a Hash.
      def connection
        raise "#{database} on #{host} not configured" unless known?
        { host: host,
          port: port || 3306,
          user: user_name,
          password: @user_password }
      end

      # Sets the _database_ name.
      # _name_: String
      def database=(name)
        @database = name
        touch
      end

      # -> Hash
      # Returns a Hash with the MySQL/MariaDB user name and password.
      def db_user
        { name: @user_name, password: @user_password }
      end

      # Sets the _host_ name.
      # _name_: String
      def host=(name)
        @host = name
        touch
      end

      # -> +true+ or +false+
      # Returns +true+ if the _host_ is known (has been configured), +false+
      # otherwise.
      def host?
        hosts[host]
      end

      # -> +true+ or +false+
      # Returns +true+ if the _database_ is known (has been configured), +false+
      # otherwise.
      def known?
        params ? true : false
      end

      # -> Hash
      # Returns a Hash with the parameters for the current _host_ and _database_
      # from the configuration YAML file.
      def params
        super.dig:hosts, @host, :databases, @database
      end

      # Sets the _port_ number for the _host_.
      # _number_: Integer
      def port=(number)
        @port = number&.to_i
        raise ArgumentError, "invalid port number: #{number}" unless port_valid?
        touch
      end

      # -> +true+
      # Saves the current state to the YAML file.
      def save
        return true if saved?
        host? ? update_host : save_new_host
        super
      end

      # Sets the Specify user.
      # _name_: String
      def session_user=(name)
        @session_user = name
        touch
      end

      # Sets the MySQL/MariaDB <em>user_name</em>.
      # _name_: String.
      def user_name=(name)
        @user_name = name
        touch
      end

      # Sets the MySQL/MariaDB <em>user_password</em>.
      # _password_: String
      def user_password=(password)
        @user_password = password
        touch
      end

      # -> +true+ or +false+
      # Returns +true+ if the <em>user_name</em> in memory differs from the
      # +:name+ in the params of the YAML file.
      def changed_user?
        params[:db_user][:name] != user_name
      end

      # -> +true+ or +false+
      # Returns +true+ if the <em>user_password</em> in memory differs from the
      # +:password+ in the params of the YAML file.
      def changed_password?
        params[:db_user][:password] != @user_password
      end

      # -> +true+ or +false+
      # Returns +true+ if the _port_ in memory differs from the +:port+ in the
      # params of the YAML file.
      def changed_port?
        hosts[host][:port] != port
      end

      # -> +true+ or +false+
      # Returns +true+ if the <em>session_user</em> in memory differs from the
      # <tt>:so_user</tt> in the params of the YAML file.
      def changed_session_user?
        params[:sp_user] != session_user
      end

      private

      # Adds parameters for _host_ and _database_ to be saved.
      def save_new_host
        add_host host, port
        add_database database, host: host
      end

      # Uppdates parameters for the _database_
      def update_database
        params[:db_user][:name] = user_name if changed_user?
        params[:db_user][:password] = @user_password if changed_password?
        params[:sp_user] = session_user if changed_session_user?
      end

      # Updates parameters for the _host_.
      def update_host
        hosts[host][:port] = port if changed_port?
        add_database database, host: host unless known?
        update_database
      end

      # Validates the port number
      def port_valid?
        port.nil? || port.to_i.positive?
      end
    end
  end
end
