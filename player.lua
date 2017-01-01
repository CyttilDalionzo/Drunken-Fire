Player = Actor:extend()

CONTROLS = {{"left", "right", "up", "down", "j", "k"}, {"a", "d", "w", "s", "v", "b"}}

function Player:new(x, y, width, height, controlNum, health)
  Player.super.new(self, x, y, width, height, health)
  
  self.controls = CONTROLS[controlNum]
  self.controlNum = controlNum
  self.enemy = false
  
  if controlNum == 1 then
    self.baseColor = {50,100,255,255}
    self.fireworkColor = {50, 100, 255, 180}
  elseif controlNum == 2 then
    self.baseColor = {0,180,0,255}
    self.fireworkColor = {0, 255, 0, 180}
  end
  
  if TEAMS then
    self.id = 0
  end
  
end

function Player:update(dt)
    self.moveX = 0
    self.moveY = 0
    self.moveZ = 0
    self.shootF = 0
    
    if love.keyboard.isDown(self.controls[1]) then
      self.moveX = 1
    elseif love.keyboard.isDown(self.controls[2]) then
      self.moveX = -1
    end
    
    if love.keyboard.isDown(self.controls[3]) then
      self.moveY = 1
    elseif love.keyboard.isDown(self.controls[4]) then
      self.moveY = -1
    end
    
    if love.keyboard.isDown(self.controls[5]) then
      self.moveZ = 1
    end
    
    if love.keyboard.isDown(self.controls[6]) then
      self.shootF = 1
    end
    
    Player.super.update(self, dt)
end

