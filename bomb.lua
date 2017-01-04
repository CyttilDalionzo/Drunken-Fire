-- Objects that will handle bombs (and their explosions)
Bomb = Object:extend()

function Bomb:new(x, y, color, ownerTeam, owner, angle)
  self.x = x
  self.y = y
  self.color = color
  self.owner = ownerTeam
  self.uniqueOwner = owner
  
  self.width = POWERUP_RADIUS
  self.height = POWERUP_RADIUS
  
  self.timer = math.prandom(0.5,3.5) 
  
  self.isDead = false
  
  self.bombHitRadius = POWERUP_RADIUS*5
  self.bombRadius = POWERUP_RADIUS*0.5
  
  self.speed = math.prandom(FIREWORKS_SPEED*0.6, FIREWORKS_SPEED)
  self.speedX = self.speed*math.cos(angle)
  self.speedY = self.speed*math.sin(angle)
end

function Bomb:update(dt)
  self.timer = self.timer - dt
  
  self.x = math.clamp(self.x + self.speedX * dt, 0, WINDOW_WIDTH-self.width)
  self.y = math.clamp(self.y + self.speedY * dt, 0, WINDOW_HEIGHT-self.height)
  
  self.speedX = self.speedX * 0.99
  self.speedY = self.speedY * 0.99
  
  if self.timer <= 0 then
    self.isDead = true
    -- create random explosions around the bomb
    shakyCanvas = -1
    for i=1,math.round(math.prandom(2,6)) do
      table.insert(explosionsTable, Explosion(self.x+math.prandom(-30, 30), self.y+math.prandom(-30,30)))
    end
    -- reset bomb counter on "parent"
    for i,p in ipairs(playersTable) do
      if p.uniqueID == self.uniqueOwner then
        p.bombingAllowed = true
      end
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