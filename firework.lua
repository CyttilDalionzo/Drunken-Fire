Firework = Object:extend()

FIREWORKS_SPEED = 750

function Firework:new(x, y, angle)
  self.width = 50
  self.height = 20
  
  self.x = x + math.cos(angle)*(100-self.width*0.5)
  self.y = y + math.sin(angle)*(100-self.height*0.5)
  
  self.direction = math.rsign()
  self.temp_accel = 0.0005

  self.angle = angle
  self.acceleration = 0
  self.speedX = FIREWORKS_SPEED*math.cos(angle)
  self.speedY = FIREWORKS_SPEED*math.sin(angle)
  
  self.hitCounter = 0
  self.isDead = false
end

function Firework:update(dt)
  -- accelerate (and rotate) in a certain direction, until a tipping point is reached
  self.acceleration = self.acceleration + self.temp_accel*math.pi*self.direction
  self.angle = self.angle + self.acceleration
  
  if math.abs(self.acceleration) > 0.15 then
    self:resetDirection()
  end
  
  -- actually move firework
  self.speedX = FIREWORKS_SPEED*math.cos(self.angle)
  self.speedY = FIREWORKS_SPEED*math.sin(self.angle)

  -- move in x and y directions
  -- bounce off the edges
  self.x = clamp(self.x + self.speedX * dt, 0, WINDOW_WIDTH-self.width)
  if self.x <= 0 or self.x >= WINDOW_WIDTH-self.width then
    self.speedX = self.speedX * -0.8
    self.angle = self.angle + math.pi
    self:resetDirection()
  end
  
  self.y = clamp(self.y + self.speedY * dt, 0, WINDOW_HEIGHT-self.height)
  if self.y <= 0 or self.y >= WINDOW_HEIGHT-self.height then
    self.speedY = self.speedY * -0.8
    self.angle = self.angle + math.pi
    self:resetDirection()
  end
  
  -- kill if it has hit something 3 times
  if self.hitCounter >= 3 then
    self.isDead = true
  end
  
end

function Firework:resetDirection()
  self.acceleration = 0
  self.temp_accel = math.prandom(0.0001, 0.0006)
  self.direction = self.direction * -1
  self.hitCounter = self.hitCounter + 1
end

function Firework:draw()
  love.graphics.push()
  
  love.graphics.setColor(0, 255, 0, 180)
  love.graphics.translate(self.x+self.width*0.5, self.y+self.height*0.5)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-(self.x+self.width*0.5), -(self.y+self.height*0.5))
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  
  love.graphics.pop()
end