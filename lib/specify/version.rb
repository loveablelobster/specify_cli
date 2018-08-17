# frozen_string_literal: true

module Specify
  # :nodoc:
  VERSION = '0.0.4'

  # :nodoc:
  SUMMARY = 'A command line interface for Specify'

  # :nodoc:
  DESCRIPTION = <<~HEREDOC
    specify_cli is a tool that allows certain tasks in a Specify database
    (http://www.sustain.specifysoftware.org) to be carried out from the command
    line.
    Currently supported tasks:
    - upload of views to the database
    - generation of stub records
  HEREDOC
end
