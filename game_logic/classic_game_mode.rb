class ClassicGameMode

  
  def initialize(gosu)
    @gosu  = gosu
    @stage = Stage.new(gosu, :classic)
    @song = Gosu::Song.new(@gosu, MEDIA + 'Transpose.mp3')
    @song.volume = 0.03
    @button_status  = false
    @last_button    = nil
    @button_counter = 90
    @button_press   = Gosu::milliseconds
  end
  

  def update
    @stage.update
    
    if @button_status && (@button_press < Gosu::milliseconds)
      button_down(@last_button)
    end
    
  end


  def draw
    #@song.play unless @song.playing?
    @stage.draw
  end

  
  def button_down(id)
    
    
    if (id == Gosu::KbEnter || id == Gosu::KbReturn) && @button_status == false
      @stage.falling_block.drop
    end
    
    if (id == Gosu::KbW || id == Gosu::KbUp) && @button_status == false
      @stage.falling_block.rotate
    end
    
    @button_status = true
    @last_button   = id
    @button_press  = Gosu::milliseconds + @button_counter
    
    if @stage.falling_block
      
      if id == Gosu::KbLeft || id == Gosu::KbA
        @stage.falling_block.move([-1, 0])
      end
      
      if id == Gosu::KbRight || id == Gosu::KbD
        @stage.falling_block.move([1, 0])
      end
  
      if id == Gosu::KbSpace || id == Gosu::KbS
        @stage.falling_block.move([0, 1])
      end
      
    end
    
  end

  
  def button_up(id)
    @button_status = false
  end

  
end