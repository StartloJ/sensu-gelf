#!/usr/bin/env ruby
#
# Sensu GELF Handler
# ===
#
# This handler packages alerts into GELF messages and passes them
# to a Graylog2 server (or any other server that can accept GELF.)
# You need to set the options in the gelf.json file which should
# live in your /etc/sensu/conf.d directory. The 'server' and 'port'
# options are mandatory. An example gelf.json file is provided.
#
# In optional you can use another name for json_config(with -j / --json) 
# with separate log handler and send to targets log server with config.
#
# Things to note about how GELF messages are constructed:
# ---------------
#  - The 'facility' field is hardcoded to 'sensu'. This may change in the
#    future.
#
#  - The 'short_message' field is modeled after the Twitter handler, thus,
#    when a new alert is created the content will look like:
#     "ALERT - client_hostname/check_name: Check Notification Message",
#    and when an alert is resolved the content will look like:
#     "RESOLVE - client_hostname/check_name: Check Notification Message",
#
#  - The 'level' field is set to GELF::INFO when an alert is resolved,
#    and GELF::FATAL when an alert is created.
#
#  - The Sensu error level (eg: WARNING, CRITICAL) is available in the
#    '_status' field as an integer.
#
# Copyright 2019 Watcharin Yangngam (twitter.com/DukeCyber)
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-handler'
require 'gelf'
require 'json'

class GelfHandler < Sensu::Handler
  option :json_config,
        description: 'Configuration name',
        short: '-j JSONCONFIG',
        long: '--json JSONCONFIG',
        default: 'gelf'

  def event_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVE' : 'ALERT'
  end

  def action_to_gelf_level
    @event['action'].eql?('resolve') ? ::GELF::Levels::INFO : ::GELF::Levels::FATAL
  end

  def server_address
    get_setting('server')
  end

  def server_port
    get_setting('port')
  end

  def get_setting(name)
    settings[config[:json_config]][name]
  rescue TypeError, NoMethodError => e
    puts "settings: #{settings}"
    puts "error: #{e.message}"
    exit 3 # unknown
  end

  def handle
    @notifier = ::GELF::Notifier.new(server_address, server_port , "LAN" ,{ :protocol => GELF::Protocol::TCP })
    gelf_msg = {
      short_message: "#{action_to_string} - #{event_name}: #{@event['check']['notification']}",
      full_message: @event['check']['output'],
      facility: "sensu",
      level: action_to_gelf_level,
      host: @event['client']['name'],
      timestamp: @event['check']['issued'],
      _address: @event['client']['address'],
      _check_name: @event['check']['name'],
      _command: @event['check']['command'],
      _status: "#{translate_status}",
      _occurrences: @event['occurrences'],
      _action: @event['action']
    }
    @notifier.notify!(gelf_msg)
  end

  def check_status
    @event['check']['status']
  end

  def translate_status
    status = {
      0 => :OK,
      1 => :WARNING,
      2 => :CRITICAL,
      3 => :UNKNOWN
    }
    begin
      status.fetch(check_status.to_i)
    rescue KeyError
      status.fetch(3)
    end
  end
end