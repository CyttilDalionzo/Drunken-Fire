-- Base class for every "living thing" in the game: human players and computer players
Actor = Object:extend()

MAX_WALKING_SPEED = 300
ACCELERATION = 25
DAMPING = 0.95
JUMP_SPEED = 100
GRAVITY = 5
ROTATING_SPEED = 0.02*math.pi

function Actor:new(x, y, width, height, health)
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
  
  self.health = health
  
  self.baseColor = {80,80,80,255}
  self.angle = 0
  self.direction = 1
  self.loadShot = false
  self.fireworkColor = {0,0,255,180}
  
  self.moveX = 0
  self.moveY = 0
  self.moveZ = 0
  self.shootF = 0

  self.wobble = false
  self.wobbleCounter = 0
  self.effectCounter = 0
end

function Actor:update(dt)    
    -- horizontal movement
    if self.moveX == 1 then
      self.speedX = self.speedX - ACCELERATION
    elseif self.moveX == -1 then
      self.speedX = self.speedX + ACCELERATION
    else
      self.speedX = self.speedX * DAMPING
    end
    -- limit speed, and don't let player move off the game field
    self.speedX = math.clamp(self.speedX, -MAX_WALKING_SPEED, MAX_WALKING_SPEED)
    
    -- wobble movement when the player is hit
    if self.wobble then
      self.x = self.x + math.prandom(-2,2)
      self.y = self.y + math.prandom(-2,2)
      self.wobbleCounter = self.wobbleCounter + dt
      if self.wobbleCounter > 0.7 then
        self.wobbleCounter = 0
        self.wobble = false
      end
    end
    
    self.x = math.clamp(self.x + self.speedX * dt, 0, WINDOW_WIDTH-self.width)
    -- horizontal bouncing
    if self.x <= 0 or (self.x >= WINDOW_WIDTH-self.width) then
      self.speedX = self.speedX * -15
    end
    
    -- vertical_movement
    if self.moveY == 1 then
      self.speedY = self.speedY - ACCELERATION
    elseif self.moveY == -1 then
      self.speedY = self.speedY + ACCELERATION
    else
      self.speedY = self.speedY * DAMPING
    end
    -- limit speed, and don't let player move off the game field
    self.speedY = math.clamp(self.speedY, -MAX_WALKING_SPEED, MAX_WALKING_SPEED)
    self.y = math.clamp(self.y + self.speedY * dt, 0, WINDOW_HEIGHT-self.height)
    -- vertical bouncing
    if self.y <= 0 or self.y >= (WINDOW_HEIGHT-self.height) then
      self.speedY = self.speedY * -15
    end
    
    -- jumping movement; only allowed to jump when on the floor
    if self.z == 0 then
      if self.moveZ == 1 then
        self.speedZ = JUMP_SPEED
      end
      self.color = self.baseColor
    else
      self.color = {180, 0, 0, 255}
    end
    self.speedZ = self.speedZ - GRAVITY
    -- limit jumping, as player can't go through the floor/ceiling
    self.z = math.clamp(self.z + self.speedZ * dt, 0, 100)
    -- set size of the player according to depth positioning
    self.width = self.initialWidth + self.z
    self.height = self.initialHeight + self.z
    
    -- rotate player if k is being pressed
    self.angle = self.angle + self.direction*0.5*ROTATING_SPEED
    if self.shootF == 1 then
      self.angle = self.angle + self.direction*ROTATING_SPEED
      self.loadShot = true
    -- the first frame after k has been released, shoot fireworks!
    elseif self.loadShot == true then
      self.loadShot = false
      table.insert(fireworksTable, Firework(self.x+self.width*0.5, self.y+self.height*0.5, self.z, self.angle, self.fireworkColor))
      -- once in a while, change direction
      if math.random() > 0.5 then
        self.direction = self.direction * -1
      end
    end
    
    -- dust clouds!
    if (self.moveX ~= 0 or self.moveY ~= 0) and self.z == 0 then
      self.effectCounter = self.effectCounter + dt
      if self.effectCounter > 0.05 then
        table.insert(dustTable, Dust(self.x+self.width*0.5, self.y+self.height*0.5, self.angle, self.height))
        self.effectCounter = 0
      end
    end
end

function Actor:draw()
    love.graphics.push()
    
    love.graphics.translate(self.x+self.width*0.55, self.y+self.height*0.5)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-(self.x+self.width*0.55), -(self.y+self.height*0.5))
    
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.x,self.y,  self.x+self.width,self.y,  self.x+self.width*1.1,self.y+self.height*0.5,  self.x+self.width,self.y+self.height,  self.x, self.y+self.height)
    
    love.graphics.pop()
    
    -- Health squares
    love.graphics.setColor(220,0,0)
    local amountLevels = math.floor((self.health-1)/4)
    for i=0,(self.health-1) do
      love.graphics.rectangle("fill", 2+self.x+8*(i%4), self.y-10+(math.floor(i/4)-amountLevels)*10, 5, 5)
    end
end

function Actor:ChangeHealth(n)
  self.health = self.health + n
  self.wobble = true
  if self.health <= 0 then
    print("Should Die")
  end
end

--[[

-- feable attempt at creating shadow
if self.z ~= 0 then
  local scale_factor = 1.75
  love.graphics.setColor(0,0,0,20)
  love.graphics.ellipse("fill", self.x+self.width*0.5, self.y+self.height*0.5, self.width*0.5*scale_factor, self.height*0.5*scale_factor)
end

-- feable attempt at creating shadow
if self.z ~= 0 then
  local scale_factor = self.z*1.5
  love.graphics.setColor(0,0,0,20)
  love.graphics.rectangle("fill", self.x-scale_factor, self.y-scale_factor, self.width+scale_factor*2, self.height+scale_factor*2)
end
--]]