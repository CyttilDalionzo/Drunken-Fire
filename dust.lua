-- Objects that will handle explosions
Dust = Object:extend()

function Dust:new(x, y, angle, size)
  self.x = x
  self.y = y
  self.angle = angle
  self.size = size*0.8
  self.opacity = 100
end

function Dust:draw()
  love.graphics.push()
  
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self.x, -self.y)
  
  love.graphics.setColor(210+math.prandom(-20,20), 180+math.prandom(-20,20), 140+math.prandom(-20,20), self.opacity)
  love.graphics.rectangle("fill", self.x-self.size*0.5, self.y-self.size*0.5, self.size, self.size)
  
  -- gradually reduce size and lower opacity
  self.size = self.size*0.97
  self.opacity = self.opacity*0.97
  
  love.graphics.pop()
end