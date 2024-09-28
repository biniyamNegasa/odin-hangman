# frozen_string_literal: true

# The popular game where you have to guess a word
class Hangman
  attr_reader :chosen_word, :player_word, :guess_list

  def initialize
    @chosen_word = []
    @player_word = []
    @guess_list = []
  end

  def play_game
    chosen_word = random_word
    player_word = %w[_] * chosen_word.length
    guess_list = Set[]

    number_of_rounds = 3 + chosen_word.length
    while number_of_rounds.positive?
      p player_word
      break if are_equal?(player_word, chosen_word)

      puts "You're left with #{number_of_rounds} guesses"
      print 'Give your guess among the alphabets: '
      player_guess = gets.chomp.downcase
      if player_guess == 'resume'
        data = load
        player_word = data.player_word
        chosen_word = data.chosen_word
        guess_list = data.guess_list
        number_of_rounds = 3 + chosen_word.length - guess_list.length
      end
      if player_guess == 'pause'
        @player_word = player_word
        @guess_list = guess_list
        @chosen_word = chosen_word
        save
        return
      end
      next if player_guess.length > 1

      if guess_list.include?(player_guess)
        puts 'You have already guessed that letter!'
        next
      end
      guess_list << player_guess
      chosen_word.each_with_index do |char, ind|
        player_word[ind] = char if char == player_guess
      end
      print "Your guess: #{guess_list.join(', ')}"
      puts
      number_of_rounds -= 1
    end

    who_won(player_word, chosen_word)
  end

  def to_s
    "#{@guess_list} | #{@chosen_word} | #{@player_word}"
  end

  private

  def random_word
    current_words = File.open('words.txt').readlines
    current_words.map!(&:chomp)
    filtered_words = current_words.filter { |word| word.length >= 5 && word.length <= 12 }

    filtered_words.sample.split('')
  end

  def are_equal?(word1, word2)
    word1.join == word2.join
  end

  def who_won(player_word, chosen_word)
    if are_equal?(player_word, chosen_word)
      puts 'Congratulations! You have guessed the word.'
    else
      puts 'You have lost!'
    end
    print 'The word was: '
    puts chosen_word.join
  end

  def save
    data = Marshal.dump(self)
    Dir.mkdir('output') unless Dir.exist?('output')
    File.open('output/pause.yaml', 'w') do |file|
      file.puts(data)
    end
  end

  def load
    file = File.open('output/pause.yaml')
    Marshal.load(file)
  end
end
