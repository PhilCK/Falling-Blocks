class Stage
  
  
  ROWS = 20
  COLS = 10
  NODE = 20
  NGAP = 0      # this is the gap between nodes
  
  
  attr_accessor :x_coord, :y_coord
  attr_accessor :height, :width
  attr_accessor :nodes
  attr_accessor :falling_block, :mode
  attr_accessor :last_tick, :tick_length
  attr_accessor :image
  attr_accessor :gosu
  
  
  STAGE_COLOUR = 0xffffffff
  
  
  def initialize(gosu, mode)
    self.gosu = gosu
    self.mode = mode
    
    # height / width of stage
    self.width  = ( (COLS * NODE) + (NGAP * (COLS + 1)) )
    self.height = ( (ROWS * NODE) + (NGAP * (ROWS + 1)) )
    
    # coords of stage so that it is centered
    self.x_coord = (@gosu.width  / 2) - (self.width  / 2)
    self.y_coord = (@gosu.height / 2) - (self.height / 2)
    
    @lines_cleared = 0
    @level = 1
    
    # init the array for the stage
    self.nodes = Array.new(COLS)
    
    COLS.times do |node|
      self.nodes[node] = Array.new(ROWS, 0)
    end
    
    #initial block
    self.falling_block = FallingBlock.new(self)
    self.image = Gosu::Image.new(@gosu, MEDIA + "block.png", true)
    
    #initial tick
    self.tick_length = 500
    set_tick
    
    @clear_sounds = [
      nil,
      Gosu::Sample.new(@gosu, MEDIA + "power_up_01.wav"),
      Gosu::Sample.new(@gosu, MEDIA + "power_up_02.wav"),
      Gosu::Sample.new(@gosu, MEDIA + "power_up_03.wav"),
      Gosu::Sample.new(@gosu, MEDIA + "power_up_04.wav")
    ]
    
    
    @drop_sound = Gosu::Sample.new(@gosu, MEDIA + "click.wav")
  end
  
  
  def update
    unless @gosu.current_state.game_over
    
      if self.falling_block.dead
        @drop_sound.play
        self.falling_block = FallingBlock.new(self)
        unless is_legal?([0, 0])
          game_over
        end
      end
    
      if self.last_tick < Gosu::milliseconds
        self.falling_block.update
      
        # reset tick length
        set_tick
      end
    
      remove_complete_rows
      
    else
      
      do_game_over
      
    end
  end
  
  
  def draw
    draw_block
    draw_stage
  end
  
  
  # offset has to be an array
  def is_legal?(offset)
    legal = true
    
    # As some of the blocks are in the negitive side, they need to be shifted
    # accross so we can get there true width
    model_compensation = self.falling_block.model.collect {|v| v[0]}.min.abs
    
    offset_x = offset[0] + self.falling_block.offset_x
    offset_y = offset[1] + self.falling_block.offset_y
    
    
    # check if in bounds
    self.falling_block.model.each do |n|    
      
      unless (offset_x - model_compensation >= 0 && offset_x < (COLS)) &&
             (offset_y >= 0 && offset_y < (ROWS))
          
        legal = false
      end
    end
    
    
    # check nodes
    if legal
      
      self.falling_block.model.each do |n|
        
        if self.nodes[offset_x + n[0]][offset_y + n[1]] > 0
          legal = false
        end
        
      end
    end
        
    legal
    
    rescue NoMethodError
      legal = false
      
  end
  
  
  def set_tick(offset = 0)
    @level = [@lines_cleared / 10, 1].max
    tick = self.tick_length - [@level * 100, 50].min
    
    self.last_tick = Gosu::milliseconds + (tick - offset)
  end
  
  
  def write_block
    
    self.falling_block.model.each do |n|
      x_coord = n[0] + self.falling_block.offset_x
      y_coord = n[1] + self.falling_block.offset_y
      
      self.nodes[x_coord][y_coord] = self.falling_block.block_id
    end
  end
  
  
  private
  
  
  def do_game_over
    self.nodes[rand(COLS)][rand(ROWS)] = rand(6) + 1
  end
  
  
  def game_over
    @gosu.caption = "Game Over!"
    @gosu.current_state.game_over = true
  end
  
  
  def draw_stage
    @gosu.draw_quad(@x_coord,           @y_coord,           STAGE_COLOUR,
                    @x_coord + @width,  @y_coord,           STAGE_COLOUR,
                    @x_coord,           @y_coord + @height, STAGE_COLOUR,
                    @x_coord + @width,  @y_coord + @height, STAGE_COLOUR,
                    StageLayer)
                    
    COLS.times  do |x|
      ROWS.times do |y|
        if self.nodes[x][y] > 0
          n_x = self.x_coord + (x * NODE) + (x * NGAP)
          n_y = self.y_coord + (y * NODE) + (y * NGAP)
          
          self.image.draw(n_x, n_y, StageLayer, 1, 1, self.falling_block.colours[self.nodes[x][y]] )
          
        end
      end
    end
    
  end
  
  
  def draw_block

    if self.falling_block
      self.falling_block.model.each do |node|
        # offset coords
        x_coord = @x_coord + ((node[0] + falling_block.offset_x) * NODE)
        y_coord = @y_coord + ((node[1] + falling_block.offset_y) * NODE)
      
        self.image.draw(x_coord, y_coord, BlockLayer, 1, 1, self.falling_block.colour)
      end
    end

  end
  
  
  def remove_complete_rows

    # check to see if there are any completed rows
    rows_to_clear = []

    ROWS.times do |y|
      nodes_filled = []
      
      COLS.times do |x|   
        if self.nodes[x][y] > 0
          nodes_filled << x
        end
      end
      
      rows_to_clear << y if nodes_filled.length == COLS
    end
    
    
    # delete completed rows and fill new ones
    if rows_to_clear.length > 0
      
      rows_to_clear.each do |y|
      
        COLS.times do |x|
          
          self.nodes[x].delete_at(y)
        end
        
        effect(rows_to_clear.length)
        
      end
      
      if self.nodes[0].length < ROWS
         (ROWS - self.nodes[0].length).times do
           self.nodes.length.times do |x|
             self.nodes[x] = self.nodes[x].reverse
             self.nodes[x] << 0
             # turn the stage col back
             self.nodes[x] = self.nodes[x].reverse
           end
         end
       end
       
       @lines_cleared += rows_to_clear.length
       @clear_sounds[rows_to_clear.length].play
       @gosu.current_state.update_score(rows_to_clear.length)
       
    end
    
  end
  
  
  def effect(rows)
    
  end
  
  
end
