require "yajl"

$logger = Yajl.create_logger

require 'droplet_kit'
require 'pp'

require_relative "swell/secrets.rb"
require_relative "swell/ssh_manager.rb"
require_relative "swell/droplet_manager.rb"
require_relative "swell/deployer.rb"
