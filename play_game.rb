#!/usr/bin/env ruby

require 'yaml'

require './controllers/game_controller'
require './strategies/strategy'
require './utils/write_score'

config = YAML.load_file('./configs/config.yml')

gc = GameController.new(config['user']['id'], config['server']['url'], config['db'])
strategy = Strategy.new(config['db'])

gc.start_game
(1..gc.words_to_guess).each do |guess_count|
  gc.logger.debug("-------------Guess count: #{ guess_count }-------------")
  gc.get_word
  while !gc.current_word.pass_guess and !gc.current_word.right_guessed and gc.current_word.wrong_guess < gc.each_allow_guess
    gc.guess(strategy.get_a_letter(gc.current_word))
  end
  gc.get_result
end

final_result = gc.get_result

WriteScore.new(config['score_path']).write({session_id: gc.session_id, result: final_result})

if final_result['data']['score'] > 1000
  gc.submit
end
