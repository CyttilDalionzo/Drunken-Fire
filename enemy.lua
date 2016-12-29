Enemy = Actor:extend()

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
        if self.fireworkNotOnLevel == false and math.prandom(-10,10) <= self.strength then
        -- only fireworks on our level, JUMP!
          self.moveZ = 1
        end
        -- otherwise, there's both fireworks above and below, MOVE!
      end
    else
      self.moveX = math.rsign()
      self.moveY = math.rsign()
      
      if self.moveX == 1 and self.x < 200 then
        self.moveX = -1
      elseif self.moveX == -1 and self.x > WINDOW_WIDTH - 200 then
        self.moveX = 1
      end
      
      if self.moveY == 1 and self.y < 200 then
        self.moveY = -1
      elseif self.moveY == -1 and self.y < WINDOW_HEIGHT-200 then
        self.moveY = 1
      end
    end
    
    --[[
    if math.abs(self.angle) < 0.5*math.pi and self.x > WINDOW_WIDTH-170 or
       math.abs(self.angle-0.5*math.pi) < 0.5*math.pi and self.y > WINDOW_HEIGHT-170 or
       math.abs(self.angle-math.pi) < 0.5*math.pi and self.x < 170 or
       math.abs(self.angle-1.5*math.pi) < 0.5*math.pi and self.y < 170 then
         self.shootF = 0
    end
    --]]
    
    self.timeLastShot = self.timeLastShot + dt
    
    if self.myTarget ~= nil then
      local targ = playersTable[self.myTarget]
      if math.abs(self.angle - CalculateAngle(targ.x, targ.y, self.x, self.y)) < 0.15*math.pi and self.timeLastShot > 1 then
        self.shootF = 0
        self.loadShot = true
        self.myTarget = nil
        self.timeLastShot = 0
      end
    end
    
    Enemy.super.update(self, dt)
    
    self.moveX = 0
    self.moveY = 0
    self.moveZ = 0

    self.fireworkClose = false
    self.fireworkOnLevel = false
    self.fireworkNotOnLevel = false
end

