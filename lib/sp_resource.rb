# frozen_string_literal: true

require 'sp_resource/version.rb'

require 'fileutils'
require 'io/console'
require 'mysql2'
require 'pathname'
require 'psych'
require 'readline'
require 'sequel'

CONFIG = File.expand_path(Pathname.new('~/.sp_resource.yml'))

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
