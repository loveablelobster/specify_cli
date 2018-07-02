# frozen_string_literal: true

require 'sp_resource/version.rb'

require 'fileutils'
require 'io/console'
require 'mysql2'
require 'open3'
require 'pathname'
require 'psych'
require 'readline'
require 'sequel'

require_relative 'sp_resource/branch_parser'
require_relative 'sp_resource/cli'
require_relative 'sp_resource/specify'
require_relative 'sp_resource/user_type'
require_relative 'sp_resource/view_loader'

# A module that provides functionaliy to manage Specify app resources.
module SpResource
  CONFIG = File.expand_path(Pathname.new('~/.specify.rc'))
  GIT_CURRENT_BRANCH = 'git rev-parse --abbrev-ref HEAD'

  BRANCH_ERROR = 'Branch name not parsable: '

  module FileError
    VIEWS_FILE = 'Files must be .views.xml files'
  end
end
