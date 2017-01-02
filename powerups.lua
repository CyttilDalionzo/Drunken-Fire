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
    self.color = {25, 75, 25}
  elseif theType == 2 then
    -- Slower rotation
    self.color = {50, 50, 175}
  elseif theType == 3 then
    -- Faster rotation
    self.color = {25, 25, 75}
  elseif theType == 4 then
    -- Slower Arrows
    self.color = {175, 50, 50}
  elseif theType == 5 then
    -- Faster Arrows
    self.color = {75, 25, 25}
  elseif theType == 6 then
    -- Change Weapon
    self.color = {50, 150, 150}
  elseif theType == 7 then
    -- Unable to jump
    self.color = {175, 175, 75}
  elseif theType == 8 then
    -- An extra life!
    self.color = {255, 150, 150}
  end
end

function Powerup:draw()
  -- drawing fill AND line, because otherwise the edges of the circle aren't smooth.
  love.graphics.setColor(self.color, 200)
  love.graphics.circle("line", self.x, self.y, self.radius)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  
  -- glowing circle animation
  love.graphics.setColor(self.color, 130)
  love.graphics.circle("line", self.x, self.y, self.glowRadius)
  self.glowRadius = self.glowRadius + 0.25
  if self.glowRadius > self.radius*2 then
    self.glowRadius = self.radius
  end
end