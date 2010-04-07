class FallingBlock
  
  attr_accessor :stage, :mode
  attr_accessor :model, :colour, :block_id
  attr_accessor :offset_x, :offset_y
  attr_accessor :dead
  
  attr_accessor :blocks, :angles, :colours

  FUNKY_BLOCKS = [
            [], # void
            [ [0, 1], [0, -1], [1, 0], [-1, 0], [0, 0] ],  # star
            [ [0, 0], [0, 1], [1,1] ],  # diag block
            [ [1, -1], [0, -1], [0, 0] ],  # diag block - rverse
            [ [-1, 1], [-1, 0], [0, 0], [1, 0], [1, -1] ],  # L shape - reverse
            [ [-1, 0],  [0, 0],  [1, 0] ],  # long one
            [ [-1, 0], [0, 0],  [1, 1] ],  # L shape
            [ [-1, 0], [0, 0],  [1, -1] ]  # L shape - reverse
          ]
          
    FUNKY_BLOCK_ANGLE = [nil, 0, 90, 90, 90, 90, 90, 90]

    FUNKY_BLOCK_COLOUR = [
          "VOID DO NOT CALL",
          0xffff0000,
          0xff0000ff,
          0xff00ff00,
          0xffff00ff,
          0xffffff00,
          0xff00ffff,
          0xffff0000
    ]
  
  CLASSIC_BLOCKS = [
            [], # void
            [ [-1, -1], [0, -1], [-1, 0], [0, 0] ],  # block
            [ [0, -1],  [-1, 0], [0, 0],  [1, 0] ],  # 3 prong thing
            [ [-1, -1], [-1, 0], [0, 0],  [1, 0] ],  # L shape
            [ [1, -1],  [-1, 0], [0, 0],  [1, 0] ],  # L shape - reverse
            [ [-1, 0],  [0, 0],  [1, 0],  [2, 0] ],  # long one
            [ [-1, -1], [0, -1], [0, 0],  [1, 0] ],  # Z shape
            [ [-1, 0],  [0, 0],  [0, -1], [1, -1] ]   # Z shape - reverse
          ]
          
  CLASSIC_BLOCK_ANGLE = [nil, 0, 90, 90, 90, 90, 90, 90]
  
  CLASSIC_BLOCK_COLOUR = [
        "VOID DO NOT CALL",
        0xffff0000,
        0xff0000ff,
        0xff00ff00,
        0xffff00ff,
        0xffffff00,
        0xff00ffff,
        0xffff0000
  ]

  
  
  def initialize(stage)
    self.dead   = false
    self.stage  = stage
    self.mode = stage.mode
    
    if mode == :classic
      self.blocks = CLASSIC_BLOCKS
      self.angles = CLASSIC_BLOCK_ANGLE
      self.colours = CLASSIC_BLOCK_COLOUR
    elsif mode == :funky
      self.blocks = FUNKY_BLOCKS
      self.angles = FUNKY_BLOCK_ANGLE
      self.colours = FUNKY_BLOCK_COLOUR
    end
    
    self.block_id = rand(self.blocks.length - 1) + 1
    self.colour = self.colours[self.block_id]
    self.model  = self.blocks[self.block_id]
    
    self.offset_x = Stage::COLS / 2 - (self.model.collect{|v| v[0]}.min.abs)
    self.offset_y = 1
  end
  
  
  def update
    if self.stage.is_legal?([0, 1])
      self.offset_y += 1
    else
      self.dead = true
      self.stage.write_block
    end
  end


  def move(offset)

    if self.stage.is_legal?(offset)
      self.offset_x += offset[0]
      self.offset_y += offset[1]

      if offset[1] > 0
        self.stage.set_tick
      end

    end

  end
  
  
  def drop
    offset = [0, 1]
    
    while self.stage.is_legal?(offset)
      move(offset)
    end
    
    self.stage.set_tick(self.stage.tick_length)
  end


  def rotate
    
    angle = angles[self.block_id] * Math::PI / 180
    
    old_model = self.model
    new_model = []
    
    old_model.each do |vert|
      x = vert[0]
      y = vert[1]
      
      n_x = (Math::cos(angle) * x) - (Math::sin(angle) * y)
      n_y = (Math::cos(angle) * y) + (Math::sin(angle) * x)
      
      new_model << [n_x.round, n_y.round]
      
    end
    
    self.model = new_model
    
    unless self.stage.is_legal?([0, 0])
      self.model = old_model
    end
    
    
  end


  def draw
  end


  def tick

  end


end
