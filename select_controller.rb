#!/usr/bin/env ruby

require './connector'
require 'yaml'

class SelectController
  def initialize

  end

  def select(mask_word)

  end
end


config = YAML.load_file('config.yml')['db']
conn = Connector.new(config)

mask_word = '**E**E'

p mask_word.downcase

p mask_word.split('')

p mask_word.scan(/\w/)

p mask_word.index(/\w/)

p mask_word =~ /w/

puts mask_word.gsub!('*', '.')
