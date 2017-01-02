-- Objects that will handle bombs (and their explosions)
Bomb = Object:extend()

function Bomb:new(x, y, color, owner)
  self.x = x
  self.y = y
  self.color = color
  self.owner = owner
  
  self.timer = math.prandom(1,5) 
  
  self.isDead = false
  
  self.bombHitRadius = POWERUP_RADIUS*4
  self.bombRadius = POWERUP_RADIUS*0.5
end

function Bomb:ChangeTimer(dt)
  self.timer = self.timer - dt
  if self.timer <= 0 then
    self.isDead = true
    for i=1,math.round(math.prandom(2,6)) do
      table.insert(explosionsTable, Explosion(self.x+math.prandom(-30, 30), self.y+math.prandom(-30,30)))
    end
  end
end

function Bomb:draw()
  love.graphics.setColor(self.color, 255)
  love.graphics.circle("line", self.x-self.bombRadius, self.y-self.bombRadius, self.bombRadius)
  love.graphics.circle("fill", self.x-self.bombRadius, self.y-self.bombRadius, self.bombRadius)
  
  love.graphics.circle("line", self.x+self.bombRadius, self.y-self.bombRadius, self.bombRadius)
  love.graphics.circle("fill", self.x+self.bombRadius, self.y-self.bombRadius, self.bombRadius)
  
  love.graphics.circle("line", self.x+self.bombRadius, self.y+self.bombRadius, self.bombRadius)
  love.graphics.circle("fill", self.x+self.bombRadius, self.y+self.bombRadius, self.bombRadius)
  
  love.graphics.circle("line", self.x-self.bombRadius, self.y+self.bombRadius, self.bombRadius)
  love.graphics.circle("fill", self.x-self.bombRadius, self.y+self.bombRadius, self.bombRadius)
end