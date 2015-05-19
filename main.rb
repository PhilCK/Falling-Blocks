require 'rubygems'
require 'gosu'

# game logic
require './game_logic/classic_game_mode'
require './game_logic/funky_game_mode'

# game objects
require './game_objects/falling_block'
require './game_objects/stage'

# states
require './game_states/state'
require './game_states/main_menu'
require './game_states/classic_game'
require './game_states/funky_game'
require './game_states/high_score'

# window
require './game'

# Globa
MEDIA = "media/"
HIGHSCORE = "highscores.txt"

# layers
BackgroundLayer, StageLayer, BlockLayer, UILayer =* 1..1000

Game.new.show
