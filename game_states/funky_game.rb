require 'yaml'

class FunkyGame < State
  
  
  attr_accessor :game_over
  attr_accessor :score
  
  
  def initialize(gosu)
    super(gosu)
    @gosu.caption = "Falling Blocks"
    self.game_over = false
    self.score     = 0
    
    @score_per_line = 10
    @score_multiplier = 10
    
    @game = FunkyGameMode.new(gosu)
  end
  
  
  def update
    @game.update
  end
  
  
  def draw
    @gosu.caption = "Level:  Score: #{self.score}" unless self.game_over
    @game.draw
  end
  
  
  def update_score(lines)
    self.score += (lines * @score_per_line) + ((lines - 1) * @score_multiplier)
    self.score += 50 if lines >= 4
  end
  
  
  def button_down(id)
    if self.game_over
      if id == Gosu::KbEnter || id == Gosu::KbReturn
        submit_highscore
        @gosu.next_state(:high_score)
      end
    end
    
    if id == Gosu::KbEscape
      @gosu.next_state(:main_menu)
    end
    
    @game.button_down(id)
    
  end
  
  
  def button_up(id)
    @game.button_up(id)
  end
  
  
  def submit_highscore
    scores = []
    scores << self.score
    file = YAML.load(File.open(MEDIA + HIGHSCORE, "r"))
    scores << file unless file == false
   
    file = File.new(MEDIA + HIGHSCORE, "w")
    file << scores.flatten.sort.reverse[0..9].to_yaml
    file.close
  end
  
  
end
