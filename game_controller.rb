#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'rest_client'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

class GameController
  attr_reader :playerId, :url, :words_to_guess, :each_guess

  def initialize(playerId, url)
    @playerId = playerId
    @url = url
    @actions = {
      start_game: 'startGame',
      next_word: 'nextWord',
      guess_word: 'guessWord',
      get_result: 'getResult',
      # submit_result: 'submitResult',
    }
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def start_game
    res = post(@url, {playerId: @playerId, action: @actions[:start_game]})
    @logger.debug("start_game: #{ res }")
    @session_id = res['sessionId']
    @words_to_guess = res['data']['numberOfWordsToGuess']
    @each_guess = res['data']['numberOfGuessAllowedForEachWord']
  end

  def get_word
    res = action_post(@actions[:next_word])
    @logger.debug("get_word: #{ res }")
  end

  def guess(letter)
    res = action_post(@actions[:guess_word], letter)
    @logger.debug("guess: #{ res }")
    puts res['data']
  end

  def get_result
    res = action_post(@actions[:get_result])
    @logger.debug("get_result: #{ res }")
  end

  def submit

  end
  # reflect it in another class
  private
  # Deal will errors
  def get(url, data = {})
    # TODO: parse data in url query
    RestClient.get(url)
  end

  def post(url, data = {})
    begin
      JSON.parse(RestClient.post(url, data.to_json, {content_type: 'json', accept: 'json'}))
    rescue JSON::ParserError => e
      puts "got error in json parse: #{ e.messge }"
      raise e
    rescue Exception => e
      # Timeout unexpected errors
      puts "got error: #{ e.message }"
      raise e
    end

  end

  def action_post(action, letter = nil)
    request_body = {
      sessionId: @session_id,
      action: action
    }
    request_body[:guess] = letter if action == @actions[:guess_word] and letter
    post(@url, request_body)
  end

end

config = YAML.load_file('./config.yml')
gc = GameController.new(config['user']['id'], config['server']['url'])
gc.start_game
gc.get_word
gc.guess('E')
gc.guess('S')
gc.guess('A')
gc.guess('O')
gc.guess('P')
gc.get_result

