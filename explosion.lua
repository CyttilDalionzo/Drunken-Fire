-- Objects that will handle explosions
Explosion = Object:extend()

function Explosion:new(x, y)
  self.x = x
  self.y = y
  self.radius = 1
  self.maxRadius = math.prandom(3,7)
  self.isDead = false
  self.myColor = {math.prandom(0,255), math.prandom(0,255), math.prandom(0,255), 255}
end

function Explosion:update(dt)
  self.radius = self.radius + 12*dt
  if self.radius > self.maxRadius then
    self.isDead = true
  end
end

function Explosion:draw()
  local roundRadius = math.round(self.radius)
  
  for i=1,roundRadius do
    for j=1,i*2 do
      self.myColor[4] = math.abs(j-i-0.5)*25*(roundRadius+1-i)
      love.graphics.setColor(self.myColor)
      
      love.graphics.rectangle("fill", self.x+(j-i+0.5)*BLOCK_SIZE, self.y+(i-roundRadius)*BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
    end
  end
  
  for i=roundRadius,1,-1 do
    for j=1,i*2 do
      self.myColor[4] = math.abs(j-i-0.5)*25*(roundRadius+1-i)
      love.graphics.setColor(self.myColor)
      
      love.graphics.rectangle("fill", self.x+(j-i+0.5)*BLOCK_SIZE, self.y+(roundRadius-i+1)*BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
    end
  end
end