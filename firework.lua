-- Base class for all projectiles in the game: regular rockets, "wondertol", anything else?
Firework = Object:extend()

FIREWORKS_SPEED = 375

function Firework:new(x, y, z, angle, color, owner, extraSpeed)
  if z <= 10 then
    self.z = 0
    self.width = 25
    self.height = 10
    self.startDistance = PLAYER_SIZE+10
  else
    self.width = 37.5
    self.height = 18
    self.z = z
    self.startDistance = PLAYER_SIZE+35
  end
  
  self.x = x + math.cos(angle)*(self.startDistance-self.width*0.5)
  self.y = y + math.sin(angle)*(self.startDistance-self.height*0.5)
  
  self.direction = math.rsign()
  self.temp_accel = 0.0005

  self.angle = angle
  self.acceleration = 0
  self.speed = math.prandom((FIREWORKS_SPEED+extraSpeed)*0.6, FIREWORKS_SPEED+extraSpeed)
  self.speedX = self.speed*math.cos(angle)
  self.speedY = self.speed*math.sin(angle)
  
  self.hitCounter = 0
  self.isDead = false
  
  self.color = color
  self.effectCounter = 0
  
  self.owner = owner
end

function Firework:update(dt)
  -- accelerate (and rotate) in a certain direction...
  self.acceleration = self.acceleration + self.temp_accel*math.pi*self.direction
  self.angle = self.angle + self.acceleration
  
  -- ...until a tipping point is reached
  if math.abs(self.acceleration) > 0.15 then
    self:resetDirection()
  end
  
  -- actually move firework
  self.speedX = self.speed*math.cos(self.angle)
  self.speedY = self.speed*math.sin(self.angle)
  
  self.effectCounter = self.effectCounter + dt
  if self.effectCounter > 0.01 then
    table.insert(dustTable, Dust(self.x, self.y, self.angle, self.height))
    self.effectCounter = 0
  end

  -- move in x and y directions
  -- bounce off the edges
  self.x = math.clamp(self.x + self.speedX * dt, 0, WINDOW_WIDTH-self.width)
  if self.x <= 0 or self.x >= WINDOW_WIDTH-self.width then
    self.speedX = self.speedX * -0.8
    self.angle = self.angle + math.pi
    self:resetDirection()
  end
  
  self.y = math.clamp(self.y + self.speedY * dt, 0, WINDOW_HEIGHT-self.height)
  if self.y <= 0 or self.y >= WINDOW_HEIGHT-self.height then
    self.speedY = self.speedY * -0.8
    self.angle = self.angle + math.pi
    self:resetDirection()
  end
  
  -- kill if it has hit something 3 times
  if self.hitCounter >= 3 then
    self:Kill()
  end
  
end

function Firework:Kill()
  self.isDead = true
end

function Firework:resetDirection()
  self.acceleration = 0
  self.temp_accel = math.prandom(0.0001, 0.0006)
  self.direction = self.direction * -1
  self.hitCounter = self.hitCounter + 1
end

function Firework:draw()
  love.graphics.push()
  
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self.x, -self.y)
  
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x-self.width*0.5, self.y-self.height*0.5, self.width, self.height)
  
  love.graphics.pop()
end