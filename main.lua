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
  require "actor"
  require "player"
  playersTable = {}
  
  p1 = Player(CELL_SIZE * math.floor(LEVEL_WIDTH*0.5), CELL_SIZE * math.floor(LEVEL_HEIGHT*0.5), CELL_SIZE, CELL_SIZE)
  table.insert(playersTable, p1)
  love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
  -- update the player
  p1:update(dt)
  
  -- update all fireworks
  for i=#fireworksTable, 1, -1 do
    local f = fireworksTable[i]
    f:update(dt)
    -- remove fireworks marked dead
    if f.isDead then
      table.remove(fireworksTable, i)
    else
      -- check for collisions between fireworks and player(s); only if close enough, and on same depth level
      for j=1,#playersTable do
        local p = playersTable[j]
        if CheckZ(f.z, p.z) and CheckCollision(f.x, f.y, math.max(f.width, f.height), p.x+p.width*0.5, p.y+p.height*0.5, math.max(p.width, p.height)) then
          p:ChangeHealth(-1)
          f:Kill()
        end
      end
      
      -- check for collisions between fireworks
      for j=(i+1),#fireworksTable do
        local f2 = fireworksTable[j]
        if CheckZ(f.z, f2.z) and CheckCollision(f.x, f.y, math.max(f.width, f.height), f2.x, f2.y, math.max(f2.width, f2.height)) then
          f:Kill()
          f2:Kill()
        end
      end
    end
  end
  

end

-- TO DO: Make collision checking more accurate for fireworks: 
-- right now, only the "radius" of the other object is taken into account
-- I need to create a function that actually properly calculates the center and the radius of a firework, and use that

function CheckZ(fireZ, playerZ)
  if (fireZ == 0 and playerZ == 0) or (fireZ ~= 0 and playerZ ~= 0) then
    return true
  end
  return false
end

function CheckCollision(fireX, fireY, fireR, playerX, playerY, playerR)
  if math.dist(fireX, fireY, playerX, playerY) <= playerR then
    return true
  end
  return false
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

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function clamp(val, min, max)
  if val > max then
    val = max
  elseif val < min then
    val = min
  end
  return val
end