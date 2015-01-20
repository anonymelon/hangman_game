#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'

chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a


get '/' do
  'Hello world!'
end

post '/messages' do
  p request.class
  p request.inspect
  puts request.body.string, '========'

  # acknowledge
  "message received"
end
