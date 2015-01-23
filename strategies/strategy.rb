
require './utils/connector'

class Strategy
  def initialize(db_config)
    @conn = Connector.new(db_config)
    @letter_range = ('a'..'z')
  end

  # TODO: Analyze letter groups
  def get_a_letter(current_word)
    word = current_word.name.downcase
    if word.index(/\w/)
      word_regexp = word.gsub('*', '.')
      select_sql = "select word from words where word regexp '#{ word_regexp }' and length=#{ word.length };"
      match_result = @conn.exec(select_sql)
      # If no records match in db, pass guess
      if match_result.count == 0
        current_word.pass_guess = true
        return nil
      end
      match_words = match_result.map {|row| row['word']}

      get_letter_by_words(match_words, current_word.guessed_letters)
    # If no right letters
    else
      select_sql = "select letters from words_slice where word_length=#{ word.length } and length=1 order by count desc;"
      ordered_letters = []
      @conn.exec(select_sql).map do |row|
        if !current_word.guessed_letters.include?(row['letters'])
          ordered_letters.push(row['letters'])
        end
      end
      ordered_letters[0]
    end
  end

  # find max count letter in words list
  def get_letter_by_words(words, guessed_letters)
    letter_with_count = []
    @letter_range.each do |letter|
      if !guessed_letters.include? letter
        letter_with_count.push([letter, words.join('').count(letter)])
      end
    end

    letter_with_count = letter_with_count.sort {|x, y| y[1] <=> x[1]}
    letter_with_count[0][0]
  end
end