class MainMenu < State
  
  
  def state_initialize
    @gosu.caption = "Main Menu"
    
    @options = [:classic_game, :funky_game, :high_score]
    @images = [
        Gosu::Image.new(@gosu, MEDIA + 'title_original.png', false),
        Gosu::Image.new(@gosu, MEDIA + 'title_stupid.png', false),
        Gosu::Image.new(@gosu, MEDIA + 'title_highscores.png', false)
      ]
      
    @current_option = 0
  end
  
  
  def draw
    @images[@current_option].draw(0, 0, UILayer)
  end
  
  
  def button_down(id)
    
    if id == Gosu::KbEscape
      @gosu.close
    end
    
    if id == Gosu::KbDown
      @current_option = (@current_option + 1) % @options.length
    end
    
    if id == Gosu::KbUp
      @current_option = (@current_option - 1) % @options.length
    end
    
    if id == Gosu::KbEnter || id == Gosu::KbReturn
      @gosu.next_state(@options[@current_option])
    end
    
  end
  
  
end