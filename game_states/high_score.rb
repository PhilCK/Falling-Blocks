class HighScore < State
  
  
  def initialize(gosu)
    @gosu = gosu
    @gosu.caption = "High Scores"
    @font = Gosu::Font.new(@gosu, "Arial Black", 40)
    
    @highscores = [YAML.load(File.open(MEDIA + HIGHSCORE, "r"))].flatten!
  end
  
  
  def update
  end
  
  
  def draw
    @highscores.length.times do |score|
      @font.draw("#{score + 1}.  #{@highscores[score]}", 40, 40 * score + 40, UILayer, 1, 1, 0xFF000000)
    end
  end
  
  
  def button_down(id)
    if id == Gosu::KbEscape || id == Gosu::KbEnter || id == Gosu::KbReturn
      @gosu.next_state(:main_menu)
    end
    
  end
  
end