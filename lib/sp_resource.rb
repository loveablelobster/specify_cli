# frozen_string_literal: true

require 'sp_resource/version.rb'

require 'io/console'
require 'mysql2'
require 'pathname'
require 'psych'
require 'sequel'

require_relative 'sp_resource/branch_parser'
require_relative 'sp_resource/specify'
require_relative 'sp_resource/user_type'
require_relative 'sp_resource/view_loader'


# Add requires for other files you add to your project here, so
# you just need to require this one file in your bin file

CONFIG = Pathname.new('/usr/local/etc/sp_view_loader/db.yml')

# A module that provides functionaliy to manage Specify app resources.
module SpResource
  module FileError
    VIEWS_FILE = 'Files must be .views.xml files'
  end
end
