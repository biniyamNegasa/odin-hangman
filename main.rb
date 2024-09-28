# frozen_string_literal: true

require_relative './hangman'
game = Hangman.new
game.play_game
# game = Marshal::load(File.open('output/pause.yaml'))
# puts game
