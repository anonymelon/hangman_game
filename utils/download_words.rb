#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'rest_client'

config = YAML.load_file('./configs/config.yml')

begin
  config['words_config'].each do |item|
    puts "download from: #{ item['url'] }"
    response = RestClient.get(item['url'])
    File.write(item['name'], response)
    puts "download done, output file: #{ item['name'] }"
  end
rescue Exception => e
  puts e
end