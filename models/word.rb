
class Word
  attr_accessor :name, :total_guess, :current_guess, :wrong_guess,
                :guessed_letters, :right_guessed, :pass_guess
  attr_reader :length

  def initialize(name)
    @name = name
    @length = name.length
    @guessed_letters = []
    @right_guessed = false
    # This happens when the letter not in db
    @pass_guess = false
  end

end
