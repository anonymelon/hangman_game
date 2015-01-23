#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'mysql2'

class Connector
  def initialize(config)
    begin
      @client = Mysql2::Client.new(host: config['host'],
                                   username: config['username'],
                                   password: config['password'],
                                   encoding: config['encoding'],
                                   database: config['database'])
    rescue Mysql2::Error => e
      if e.message.include? 'Unknown database'
        db = Mysql2::Client.new(host: config['host'],
                                username: config['username'],
                                password: config['password'])
        db.query("create database if not exists #{ config['database'] };")
        retry
      else
        puts e.message
      end
    end
  end

  def exec(query)
    begin
      @client.query(query)
    rescue Mysql2::Error => e
      raise e
      return e.message
    end
  end
end
