-- Powerups
Powerup = Object:extend()

POWERUP_RADIUS = 15

function Powerup:new(x, y, theType)
  self.x = x
  self.y = y
  self.theType = theType
  
  self.radius = POWERUP_RADIUS
  self.glowRadius = self.radius
  
  if theType == 0 then
    -- Slower movement
    self.color = {50,150,50}
  elseif theType == 1 then
    -- Faster Movement
    self.color = {0, 100, 0}
  elseif theType == 2 then
    -- Slower rotation
    self.color = {50, 50, 150}
  elseif theType == 3 then
    -- Faster rotation
    self.color = {0, 0, 100}
  elseif theType == 4 then
    -- Slower Arrows
    self.color = {150, 50, 50}
  elseif theType == 5 then
    -- Faster Arrows
    self.color = {100, 0, 0}
  elseif theType == 6 then
    -- Change Weapon
    self.color = {50, 150, 150}
  elseif theType == 7 then
    -- Unable to jump
    self.color = {150, 150, 50}
  end
end

function Powerup:draw()
  love.graphics.setColor(self.color, 200)
  love.graphics.circle("line", self.x, self.y, self.radius)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  
  love.graphics.setColor(self.color, 130)
  love.graphics.circle("line", self.x, self.y, self.glowRadius)
  self.glowRadius = self.glowRadius + 0.25
  if self.glowRadius > self.radius*2 then
    self.glowRadius = self.radius
  end
end