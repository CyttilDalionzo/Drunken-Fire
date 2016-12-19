function love.load()
  -- load classic library
  Object = require "classic"
  
  -- load grid object
  require "grid"
  
  main_grid = Grid()
  
  -- load fireworks objects
  require "firework"
  fireworksTable = {}
  
  -- load file containing player definition
  require "player"
  
  p1 = Player(0, 0, CELL_SIZE, CELL_SIZE)
  love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
  -- update the player
  p1:update(dt)
  
  -- update all fireworks
  for i=#fireworksTable, 1, -1 do
    fireworksTable[i]:update(dt)
    -- remove fireworks marked dead
    if fireworksTable[i].isDead then
      table.remove(fireworksTable, i)
    end
  end
  
end

function love.keypressed(key)
    p1:keyPressed(key)
end

function love.draw()
  -- draw the main grid
  main_grid:draw()
  
  -- draw the player
  p1:draw()
  
  -- draw all fireworks
  for i=1,#fireworksTable do
    fireworksTable[i]:draw()
  end
end

function math.rsign() return love.math.random(2) == 2 and 1 or -1 end

function math.prandom(min, max) return love.math.random() * (max - min) + min end

function clamp(val, min, max)
  if val > max then
    val = max
  elseif val < min then
    val = min
  end
  return val
end