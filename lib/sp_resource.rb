# frozen_string_literal: true

require 'sp_resource/version.rb'

require 'io/console'
require 'mysql2'
require 'pathname'
require 'psych'
require 'sequel'

require_relative 'sp_resource/specify'

# Add requires for other files you add to your project here, so
# you just need to require this one file in your bin file

CONFIG = Pathname.new('/usr/local/etc/sp_view_loader/db.yml')
