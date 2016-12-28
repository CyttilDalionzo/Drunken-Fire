Enemy = Actor:extend()

function Enemy:update(dt)
    self.moveX = 0
    self.moveY = 0
    self.moveZ = 0
    self.shootF = 0
    
    -- do intelligent stuff
    if math.random() < 0.01 then
      self.shootF = 1
    end
    
    Enemy.super.update(self, dt)
end

