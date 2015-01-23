#!/usr/bin/env ruby

require './utils/connector'
require 'yaml'


class InitDB
  def initialize
    @config = YAML.load_file('./configs/config.yml')
    @conn = Connector.new(@config['db'])
  end

  def prepare_db
    drop_words_table = %Q(
      drop table if exists words, words_slice;
    )
    words_table_schema = %Q(
      create table if not exists words(
        word char(255),
        length int,
        wight int
      )
    )
    # count may be much large
    words_slice_schema = %Q(
      create table if not exists words_slice(
        letters char(255),
        word_length int,
        length int,
        count int
      )
    )
    @conn.exec(drop_words_table)
    @conn.exec(words_table_schema)
    @conn.exec(words_slice_schema)
  end

  def get_insert_value_str(insers_list)
    # Parse to mysql insert values
    insert_str_list = insers_list.map do |word|
      "('#{ word }', #{ word.length }, 1)"
    end
    insert_str_list.join(',')
  end


  def insert_values(insert_list)
    return unless insert_list.length > 0
    value_str = get_insert_value_str(insert_list)
    insert_data_sql = "insert into words values #{ value_str }"
    @conn.exec(insert_data_sql)
  end

  # After test, to large word record will always get low score in short word length guess
  def insert_words
    #Large words only insert length > 5
    # TODO: refine with loop
    File.open(@config['words_config'][0]['name'], 'r') do |file|
      insert_list = []
      file.each do |line|
        # Filter letters
        if /^[a-z-]+$/ =~ (line)
          line.chop!
          line = line.gsub('-', '')
          if line.length > 5
            insert_list.push(line.downcase)
          end
          insert_list.push(line.downcase)
        end
        # Too much insert values will got error, so insert in bucket
        if insert_list.length >= @config['insert_bucket'].to_int
          insert_values(insert_list)
          insert_list = []
        end
      end
      insert_values(insert_list)
    end

    #Tiny words only insert length <= 5
    File.open(@config['words_config'][1]['name'], 'r') do |file|
      insert_list = []
      file.each do |line|
        # Filter letters
        if /^[a-z-]+$/ =~ (line)
          line.chop!
          line = line.gsub('-', '')
          if line.length <= 5
            insert_list.push(line.downcase)
          end
        end
        # Too much insert values will got error, so insert in bucket
        if insert_list.length >= @config['insert_bucket'].to_int
          insert_values(insert_list)
          insert_list = []
        end
      end
      insert_values(insert_list)
    end
  end
end

p 'Start init db.....'
start_time = Time.now
init_db = InitDB.new
init_db.prepare_db()
init_db.insert_words()

end_time = Time.now
p "Init db time: #{ (end_time - start_time) * 1000 } ms"
