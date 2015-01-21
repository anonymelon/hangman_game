#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'rest_client'
require 'yaml'

begin
  response = RestClient.get 'http://localhost:4567'
  puts response.code
rescue Exception => e
  puts e
end

config = YAML.load_file('config.yml')
puts config


p 'test'



p rand(3)

chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
p chars
