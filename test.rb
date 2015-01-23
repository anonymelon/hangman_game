require 'thread'

thread_pool = []
(0...8).each do |index|
  thread_pool << Thread.new do
    load 'play_game.rb'
  end
end

thread_pool.each { |c| c.join }
