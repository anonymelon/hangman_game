#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'rest_client'
require 'logger'

require './utils/connector'
require './models/word'
require './utils/logger'

class GameController
  attr_accessor :current_word
  attr_reader :playerId, :url, :words_to_guess, :each_guess, :total_word_count, :score,
              :correct_word_count, :each_allow_guess, :logger, :session_id, :all_words

  def initialize(playerId, url, db_config)
    @playerId = playerId
    @url = url
    @all_words = []
    @actions = {
      start_game: 'startGame',
      next_word: 'nextWord',
      guess_word: 'guessWord',
      get_result: 'getResult',
      submit_result: 'submitResult',
    }
    @logger = GameLogger.new(Logger::DEBUG)
    @conn = Connector.new(db_config)
  end

  def start_game
    res = post(@url, {playerId: @playerId, action: @actions[:start_game]})
    @logger.debug("start_game: #{ res['data'] }")
    update_session(__method__, res)
  end

  def get_word
    res = action_post(@actions[:next_word])
    @logger.debug("get_word: #{ res['data'] }")
    update_session(__method__, res)
  end

  def guess(letter = nil)
    return if letter == nil
    if !@current_word.name.include? '*'
      @current_word.right_guessed = true
      return
    end
    @logger.debug("guessing word: #{ @current_word.name }, letter: #{ letter }")
    @current_word.guessed_letters.push(letter)
    res = action_post(@actions[:guess_word], letter.upcase)
    @logger.debug("guess: #{ res['data'] }")
    update_session(__method__, res)
  end

  def get_result
    res = action_post(@actions[:get_result])
    @logger.debug("get_result: #{ res['data'] }")
    update_session(__method__, res)
    res
  end

  def submit
    res = action_post(@actions[:submit_result])
    @logger.info(res)
  end

  private
  def post(url, data = {})
    begin
      JSON.parse(RestClient.post(url, data.to_json, {content_type: 'json', accept: 'json'}))
    rescue JSON::ParserError => e
      @logger.error("got error in json parse: #{ e.messge }")
      raise e
    rescue Exception => e
      # Timeout unexpected errors
      @logger.error("got unexpected error: #{ e.message }")
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

  # TODO: refine it
  def update_session(method, res)
    case method
    when :start_game
      @session_id = res['sessionId']
      @words_to_guess = res['data']['numberOfWordsToGuess']
      # 10 guess may minus more score, so let's make it 7
      # @each_allow_guess = res['data']['numberOfGuessAllowedForEachWord']
      @each_allow_guess = 7
    when :get_result
      @current_word.wrong_guess = res['data']['wrongGuessCountOfCurrentWord']
      @correct_word_count = res['data']['correctWordCount']
      @total_word_count = res['data']['totalWordCount']
      @score = res['data']['score']
    when :guess
      @current_word.name = res['data']['word']
      @current_word.wrong_guess = res['data']['wrongGuessCountOfCurrentWord']
      @total_word_count = res['data']['totalWordCount']
    when :get_word
      @current_word = Word.new(res['data']['word'])
      @current_word.wrong_guess = res['data']['wrongGuessCountOfCurrentWord']
      @total_word_count = res['data']['totalWordCount']
      @all_words.push(@current_word)
    end
  end
end
