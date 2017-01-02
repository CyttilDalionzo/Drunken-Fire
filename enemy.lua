Enemy = Actor:extend()

function Enemy:new(x, y, width, height, health)
  Enemy.super.new(self, x, y, width, height, health)
  
    -- these are all properties of the enemy, which is why I should probably put them in the enemy constructor function
  self.enemy = true
  self.fireworkOnLevel = false
  self.fireworkNotOnLevel = false
  self.fireworkSideX = 0
  self.fireworkSideY = 0
  self.fireworkClose = false
  self.strength = math.round(math.prandom(1,10))
  self.health = 11-self.strength
  self.myTarget = nil
  self.timeLastShot = 0
  self.lockDirection = {0,0}
  
  if TEAMS then
    self.id = 1
  end
  
end

function Enemy:update(dt)
    -- if there's a firework close, move out of the way as much as possible
    if self.fireworkClose then
      if fireworkSideX then
        self.moveX = 1
      else
        self.moveX = -1
      end
      
      if fireworkSideY then
        self.moveY = 1
      else
        self.moveY = -1
      end
      
      if self.fireworkOnLevel then
        if self.fireworkNotOnLevel == false and math.prandom(0,9) <= self.strength then
        -- only fireworks on our level, JUMP!
          self.moveZ = 1
        end
        -- otherwise, there's both fireworks above and below, MOVE!
      end
    end
    
    if self.fireworkClose == false or math.random() > 0.9 then
      self.moveX = math.rsign()
      self.moveY = math.rsign()
      
      -- make sure we don't crash into edges (too often)
      if self.moveX == 1 and self.x < 250 then
        self.moveX = -1
      elseif self.moveX == -1 and self.x > WINDOW_WIDTH - 250 then
        self.moveX = 1
      end
      
      if self.moveY == 1 and self.y < 250 then
        self.moveY = -1
      elseif self.moveY == -1 and self.y < WINDOW_HEIGHT - 250 then
        self.moveY = 1
      end
    end
    
    self.timeLastShot = self.timeLastShot + dt
    
    if self.myTarget ~= nil and self.myTarget > #playersTable then
      self.myTarget = nil
    end
    
    if self.myTarget ~= nil then
      local targ = playersTable[self.myTarget]
      -- move towards target
      self.moveX = -1
      self.moveY = -1
      if targ.x < self.x then
        self.moveX = 1
      end
      if targ.y < self.y then
        self.moveY = 1
      end
      
      -- when the angle is right, SHOOT! MUWHAHAH!
      if math.abs(self.angle - CalculateAngle(targ.x, targ.y, self.x, self.y)) < 0.15*math.pi and self.timeLastShot > (-0.0625*self.strength + 1.125) then
        self.shootF = 0
        self.loadShot = true
        self.myTarget = nil
        self.timeLastShot = 0
      end
    end
    
    if self.lockDirection[1] > 0 and self.moveX == 1 then
      self.moveX = 0
    elseif self.lockDirection[1] < 0 and self.moveX == -1 then
      self.moveX = 0
    end
    
    if self.lockDirection[2] > 0 and self.moveY == 1 then
      self.moveY = 0
    elseif self.lockDirection[2] < 0 and self.moveY == -1 then
      self.moveY = 0
    end
    
    Enemy.super.update(self, dt)
    
    self.moveX = 0
    self.moveY = 0
    self.moveZ = 0

    self.fireworkClose = false
    self.fireworkOnLevel = false
    self.fireworkNotOnLevel = false
end

