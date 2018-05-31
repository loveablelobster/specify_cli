# frozen_string_literal: true

require 'sp_resource/version.rb'

require 'io/console'
require 'mysql2'
require 'pathname'
require 'psych'
require 'sequel'

CONFIG = Pathname.new('/usr/local/etc/sp_resource/db.yml')

require_relative 'sp_resource/branch_parser'
require_relative 'sp_resource/cli'
require_relative 'sp_resource/specify'
require_relative 'sp_resource/user_type'
require_relative 'sp_resource/view_loader'

# A module that provides functionaliy to manage Specify app resources.
module SpResource
  module FileError
    VIEWS_FILE = 'Files must be .views.xml files'
  end
end
