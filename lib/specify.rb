# frozen_string_literal: true

require 'specify/version.rb'

require 'fileutils'
require 'io/console'
require 'mysql2'
require 'open3'
require 'pathname'
require 'psych'
require 'readline'
require 'sequel'

require_relative 'specify/branch_parser'
require_relative 'specify/cli'
require_relative 'specify/database'
require_relative 'specify/session'
require_relative 'specify/user_type'
require_relative 'specify/view_loader'

# A module that provides functionaliy to manage Specify app resources.
module Specify
  CONFIG = File.expand_path(Pathname.new('~/.specify.rc'))
  GIT_CURRENT_BRANCH = 'git rev-parse --abbrev-ref HEAD'

  BRANCH_ERROR = 'Branch name not parsable: '

  module FileError
    VIEWS_FILE = 'Files must be .views.xml files'
  end

  module LoginError
    INCONSISTENT_LOGIN = 'User is already logged in to a different collection'
  end
end
