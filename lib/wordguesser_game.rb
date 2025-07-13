class String
  def where(character)
    unless character.is_a?(String) && character.length == 1
      raise ArgumentError, "Character must be length == 1"
    end
    result = self.chars.each_with_index
                  .select { |c, i| c == character }
                  .map { |_, i| i }
    result.empty? ? nil : result
  end

  def replace_index(character, indexes)
    unless character.is_a?(String) && character.length == 1
      raise ArgumentError, "Character must be length == 1"
    end
    chars = self.chars
    indexes.each do |i|
      chars[i] = character
    end
    chars.join
  end
end

class WordGuesserGame
  # add the necessary class methods, attributes, etc. here
  # to make the tests in spec/wordguesser_game_spec.rb pass.

  # Get a word from remote "random word" service

  def initialize(word)
    @word = word.downcase
    @guesses = ''
    @wrong_guesses = ''
    @word_with_guesses = '-'*word.length
    @status = :play
  end

  def check_win_or_lose
    if @status != :play
      return @status
    elsif @wrong_guesses.length >= 7
      @status = :lose
    elsif @word == @word_with_guesses
      @status = :win
    end
    return @status
  end


  attr_reader :word
  attr_reader :guesses
  attr_reader :wrong_guesses
  attr_reader :word_with_guesses

  def guess(input)
    if input.nil? || (input.length != 1)
      raise ArgumentError, "Guess must be a single character!"
    elsif !(input.match?(/[a-zA-Z]/))
      raise ArgumentError, "Guess must be an alphabetical character!"
    end
    saninput = input.downcase

    if @guesses.include?(saninput) || @wrong_guesses.include?(saninput)
      return false
    end

    index_found = @word.where(saninput)
    if(index_found)
      @word_with_guesses = @word_with_guesses.replace_index(saninput, index_found)
      @guesses << saninput
    else
      @wrong_guesses << saninput
    end

    self.check_win_or_lose
    return true
  end 


  # You can test it by installing irb via $ gem install irb
  # and then running $ irb -I. -r app.rb
  # And then in the irb: irb(main):001:0> WordGuesserGame.get_random_word
  #  => "cooking"   <-- some random word
  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://randomword.saasbook.info/RandomWord')
    Net::HTTP.new('randomword.saasbook.info').start do |http|
      return http.post(uri, "").body
    end
  end
end
