# frozen_string_literal: true

require_relative 'configuration/config'
require_relative 'configuration/db_config'
require_relative 'configuration/host_config'

module Specify
  # A module that provides configuration facilities
  module Configuration
    TEMPLATE = {
      dir_names: { '~/' => 'localhost' },
      hosts: {
        'localhost' => {
          databases: {
            'specify' => {
              port: 3306,
              db_user: { name: 'root', password: nil },
              sp_user: nil
            }
          }
        }
      }
    }.freeze
  end
end
