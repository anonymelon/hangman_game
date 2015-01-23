#!/usr/bin/env ruby

require './utils/connector'
require 'yaml'

config = YAML.load_file('./configs/config.yml')
conn = Connector.new(config['db'])

# SQLs
select_max_length_sql = 'select max(length) from words;'
select_words_by_length_sql = 'select * from words where length='
words_slice_insert_sql = 'insert into words_slice values '

max_slice = config['max_slice']

def get_words_slice_insert_value_sql(letter_hash, word_length)
  value_list = []
  letter_hash.each do |letters, count|
    value_list.push([letters, letters.length, count])
  end
  parsed_list = value_list.map {|item|  "('#{ item[0] }', #{ word_length }, #{ item[1] }, #{ item[2] })"}
  parsed_list.join(',')
end

max_length_ret = conn.exec(select_max_length_sql)
max_count = 0
max_length_ret.each {|row| max_count = row['max(length)'] }

start_time = Time.now

p 'Start slice words.....'
# TODO: optimize loop here
# Select max count in words, eg: 29
(1..max_count).each do |word_length|
  # Init slice word hash
  letter_hash_list = [{}, {}, {}]
  # Select words length=word_length
  conn.exec(select_words_by_length_sql + word_length.to_s).each do |word_record|
    word = word_record['word']
    word_length = word_record['length']
    current_slice = (word_length < max_slice)? word_length:max_slice
    # Store in hash then save
    (1..current_slice).each do |slice_length|
      (0...word_length).step(slice_length) do |index|
        sliced_letters = word[index, slice_length]
        if sliced_letters.length == slice_length
          letter_hash_list[slice_length - 1][sliced_letters] ||= 0
          letter_hash_list[slice_length - 1][sliced_letters] += 1
        end
      end
    end
  end
  # Insert sliced letters into database
  letter_hash_list.each do |letter_hash|
    if letter_hash.length != 0
      conn.exec(words_slice_insert_sql + get_words_slice_insert_value_sql(letter_hash, word_length))
    end
  end
end


end_time = Time.now
p "Slice words time: #{ (end_time - start_time) * 1000.0 }"



