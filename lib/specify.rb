# frozen_string_literal: true

# require 'specify/version.rb'

require 'date'
require 'fileutils'
require 'io/console'
require 'mysql2'
require 'open3'
require 'pathname'
require 'psych'
require 'readline'
require 'securerandom'
require 'sequel'

require_relative 'specify/branch_parser'
require_relative 'specify/cli'
require_relative 'specify/configuration'
require_relative 'specify/database'
require_relative 'specify/number_format'
require_relative 'specify/session'
require_relative 'specify/user_type'
require_relative 'specify/services'

# FIXME: causes warnings, but is also required for call from bash script
#        raises name error for VERSION and DESCRIPTION constants otherwise
require_relative 'specify/version'

# A module that provides functionaliy to manage Specify app resources.
module Specify
  GIT_CURRENT_BRANCH = 'git rev-parse --abbrev-ref HEAD'

  BRANCH_ERROR = 'Branch name not parsable: '

  # FileError is a module that contains errors for file operations.
  module FileError
    VIEWS_FILE = 'Files must be .views.xml files'
    NO_FILE = "File not found"
  end

  # LoginError is a module that contains errors for User logins.
  module LoginError
    INCONSISTENT_LOGIN = 'User is already logged in to a different collection'
  end
end
