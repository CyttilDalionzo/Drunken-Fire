Player = Object:extend()

MAX_WALKING_SPEED = 400
ACCELERATION = 35
DAMPING = 0.95
JUMP_SPEED = 100
GRAVITY = 5
ROTATING_SPEED = 0.02*math.pi

function Player:new(x, y, width, height)
  -- initialize stuff
  self.x = x
  self.y = y
  self.z = 0
  
  self.initialWidth = width
  self.width = width
  
  self.initialHeight = height
  self.height = height
  
  self.speedX = 0
  self.speedY = 0
  self.speedZ = 0
  
  self.color = {0,0,0,255}
  self.angle = 0
  self.direction = 1
end

function Player:update(dt)
    -- horizontal movement
    if love.keyboard.isDown("left") then
      self.speedX = self.speedX - ACCELERATION
    elseif love.keyboard.isDown("right") then
      self.speedX = self.speedX + ACCELERATION
    else
      self.speedX = self.speedX * DAMPING
    end
    -- limit speed, and don't let player move off the game field
    self.speedX = clamp(self.speedX, -MAX_WALKING_SPEED, MAX_WALKING_SPEED)
    self.x = clamp(self.x + self.speedX * dt, 0, WINDOW_WIDTH-self.width)
    -- horizontal bouncing
    if self.x <= 0 or (self.x >= WINDOW_WIDTH-self.width) then
      self.speedX = self.speedX * -15
    end
    
    -- vertical_movement
    if love.keyboard.isDown("up") then
      self.speedY = self.speedY - ACCELERATION
    elseif love.keyboard.isDown("down") then
      self.speedY = self.speedY + ACCELERATION
    else
      self.speedY = self.speedY * DAMPING
    end
    -- limit speed, and don't let player move off the game field
    self.speedY = clamp(self.speedY, -MAX_WALKING_SPEED, MAX_WALKING_SPEED)
    self.y = clamp(self.y + self.speedY * dt, 0, WINDOW_HEIGHT-self.height)
    -- vertical bouncing
    if self.y <= 0 or self.y >= (WINDOW_HEIGHT-self.height) then
      self.speedY = self.speedY * -15
    end
    
    -- jumping movement; only allowed to jump when on the floor
    if self.z == 0 then
      if love.keyboard.isDown("j") then
        self.speedZ = JUMP_SPEED
      end
      self.color = {0,0,0,255}
    else
      self.color = {255, 0, 0, 255}
    end
    self.speedZ = self.speedZ - GRAVITY
    -- limit jumping, as player can't go through the floor/ceiling
    self.z = clamp(self.z + self.speedZ * dt, 0, 100)
    -- set size of the player according to depth positioning
    self.width = self.initialWidth + self.z
    self.height = self.initialHeight + self.z
    
    -- rotate player, and once in a while, change direction
    self.angle = self.angle + self.direction*ROTATING_SPEED
    if math.random() > 0.99 then
      self.direction = self.direction * -1
    end
end

function Player:keyPressed(key)
     -- shoot fireworks!
    if key == "k" then
        table.insert(fireworksTable, Firework(self.x+self.width*0.5, self.y+self.height*0.5, self.angle))
    end
end

function Player:draw()
    love.graphics.push()
    
    love.graphics.setColor(self.color)
    love.graphics.translate(self.x+self.width*0.55, self.y+self.height*0.5)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-(self.x+self.width*0.55), -(self.y+self.height*0.5))
    love.graphics.polygon("fill", self.x,self.y,  self.x+self.width,self.y,  self.x+self.width*1.1,self.y+self.height*0.5,  self.x+self.width,self.y+self.height,  self.x, self.y+self.height)
    
    love.graphics.pop()
end
