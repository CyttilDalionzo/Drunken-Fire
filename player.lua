Player = Actor:extend()

function Player:update(dt)
    self.moveX = 0
    self.moveY = 0
    self.moveZ = 0
    self.shootF = 0
    
    if love.keyboard.isDown("left") then
      self.moveX = 1
    elseif love.keyboard.isDown("right") then
      self.moveX = -1
    end
    
    if love.keyboard.isDown("up") then
      self.moveY = 1
    elseif love.keyboard.isDown("down") then
      self.moveY = -1
    end
    
    if love.keyboard.isDown("j") then
      self.moveZ = 1
    end
    
    if love.keyboard.isDown("k") then
      self.shootF = 1
    end
    
    Player.super.update(self, dt)
end

