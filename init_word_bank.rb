#!/usr/bin/env ruby

require './connector'
require 'yaml'

insert_list = []

File.open('./allword.txt', 'r') do |file|
  file.each do |line|
    # Filter letters
    if /^[a-z]+$/ =~ (line)
      insert_list.push(line.chop!)
    end
  end
end

def get_insert_value_str(insers_list)
  # Parse to mysql insert values
  insert_str_list = insers_list.map do |word|
    "('#{ word }', #{ word.length }, 1)"
  end
  insert_str_list.join(',')
end

config = YAML.load_file('config.yml')['db']
conn = Connector.new(config)

drop_words_talbe = %Q(
  drop table if exists words;
)

words_table_schema = %Q(
  create table if not exists words(
    word char(255),
    length int(100),
    wight int(100)
  )
)

value_str = get_insert_value_str(insert_list)
insert_data_sql = "insert into words values #{ value_str }"

conn.exec(drop_words_talbe)
conn.exec(words_table_schema)
conn.exec(insert_data_sql)
puts "total insert #{ insert_list.length }"




