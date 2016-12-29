function love.load()
  -- load classic library
  Object = require "classic"
  
  -- load grid object
  require "grid"
  
  main_grid = Grid()
  
  -- load fireworks objects
  require "firework"
  fireworksTable = {}
  
  -- load file containing player and enemy definition
  require "actor"
  require "player"
  require "enemy"
  playersTable = {}
  
  -- load file for explosions
  require "explosion"
  explosionsTable = {}
  
  -- dust clouds
  require "dust"
  dustTable = {}
  
  MULTIPLAYER = true
  IS_FULLSCREEN = false
  
  PLAYER_SIZE = CELL_SIZE
  
  -- initialize player(s)
  local p1 = Player(CELL_SIZE, CELL_SIZE, PLAYER_SIZE, PLAYER_SIZE, 1, 8)
  table.insert(playersTable, p1)
  
  if MULTIPLAYER then
    local p2 = Player(WINDOW_WIDTH - CELL_SIZE*2, WINDOW_HEIGHT - CELL_SIZE*2, PLAYER_SIZE, PLAYER_SIZE, 2, 8)
    table.insert(playersTable, p2)
  end
  
  for i=1,4 do
    local e = Enemy(math.random()*(WINDOW_WIDTH-CELL_SIZE), math.random()*(WINDOW_HEIGHT-CELL_SIZE), PLAYER_SIZE, PLAYER_SIZE, 4)
    table.insert(playersTable, e)
  end
  
  -- some other graphical thingies
  love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
  -- update all fireworks
  for i=#fireworksTable, 1, -1 do
    local f = fireworksTable[i]
    f:update(dt)
    if f.isDead then
      table.remove(fireworksTable, i)
    end
    -- check for collisions between fireworks and player(s); only if close enough, and on same depth level
    for j=1,#playersTable do
      local p = playersTable[j]
      -- Sending signals to enemies
      if p.enemy then 
        if CheckCollisionPlayer(f.x, f.y, p.x+p.width*0.5, p.y+p.height*0.5, math.max(p.width, p.height)+20) then
          p.fireworkSideX = f.x < (p.x+p.width*0.5)
          p.fireworkSideY = f.y < (p.y+p.height*0.5)
          p.fireworkClose = true
          
          if CheckZ(f.z, p.z) then
            p.fireworkOnLevel = true
          else
            p.fireworkNotOnLevel = true
          end
        end
      end
      
      -- Collision Checking
      if CheckZ(f.z, p.z) and CheckCollisionPlayer(f.x, f.y, p.x+p.width*0.5, p.y+p.height*0.5, math.max(p.width, p.height)) then
        p:ChangeHealth(-1)
        table.insert(explosionsTable, Explosion(p.x, p.y))
        f:Kill()
      end
    end
      
    -- check for collisions between fireworks
    for j=#fireworksTable,(i+1),-1 do
      local f2 = fireworksTable[j]
      if CheckZ(f.z, f2.z) and CheckCollisionFirework(f.x, f.y, f.width, f.height, f2.x, f2.y, f2.width, f2.height) then
        table.insert(explosionsTable, Explosion(0.5*(f.x+f2.x), 0.5*(f.y+f2.y)))
        f:Kill()
        f2:Kill()
      end
    end
  end
  
  -- update all explosions
  for i=#explosionsTable,1,-1 do
    if explosionsTable[i].isDead then
      table.remove(explosionsTable, i)
    else
      explosionsTable[i]:update(dt)
    end
  end
  
  -- update the player(s)
  for i,p in ipairs(playersTable) do
    p:update(dt)
    if p.enemy and p.myTarget == nil then
      for j,e in ipairs(playersTable) do
        if i ~= j then
          if CheckCollisionPlayer(p.x+p.width*0.5, p.y+p.height*0.5, e.x+e.width*0.5, e.y+e.height*0.5, p.width+e.width+500) and 
             math.abs(p.angle-CalculateAngle(e.x, e.y, p.x, p.y)) < 0.5*math.pi then
             p.myTarget = j
             p.shootF = 1
             break
          end
        end
      end
    end
  end
  
  -- remove dust (particle) effects if dead
  for i=#dustTable,1,-1 do
    if dustTable[i].opacity <= 0.002 then
      table.remove(dustTable, i)
    end
  end

end

function love.draw()
  -- draw the main grid
  main_grid:draw()
  
  -- draw dust (particle) effects
  for i=1,#dustTable do
   dustTable[i]:draw()
  end
  
  -- draw all fireworks at bottom level
  for i,f in ipairs(fireworksTable) do
    if f.z <= 0 then
      f:draw()
    end
  end
  
  -- draw the player(s)
  table.sort(playersTable, orderZ)
  for i=1,#playersTable do
    playersTable[i]:draw()
  end
  
  -- draw all fireworks at the top level
  for i,f in ipairs(fireworksTable) do
    if f.z > 0 then
      f:draw()
    end
  end
  
  -- draw all explosions
  for i=1,#explosionsTable do
    explosionsTable[i]:draw()
  end
  
  love.graphics.setColor(0,0,0)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  
  local point1 = {10,10}
  local point2 = {50,50}
  
  local theAngle = math.atan2(point1[2]-point2[2], point1[1]-point2[1])
  
  if theAngle < 0 then
    theAngle = theAngle + 2*math.pi
  elseif theAngle >= 2*math.pi then
    theAngle = theAngle - 2*math.pi
  end
  
  love.graphics.print(tostring(theAngle), 10, 40)
  love.graphics.print(tostring(CalculateAngle(point1[1], point1[2], point2[1], point2[2])), 10, 70)

end

-- Two Z levels: *precisely* on the ground, and not
function CheckZ(fireZ, playerZ)
  return (fireZ == 0 and playerZ == 0) or (fireZ ~= 0 and playerZ ~= 0)
end

-- Turns the player into a circle, but otherwise quite accurate
function CheckCollisionPlayer(fireX, fireY, playerX, playerY, playerR)
  return math.dist(fireX, fireY, playerX, playerY) <= playerR
end

-- Careful Collision: only takes into account the radius of the largest firework
function CheckCollisionFirework(X1, Y1, W1, H1, X2, Y2, W2, H2)
  return math.dist(X1,Y1,X2,Y2) <= math.max(math.max(W1,H1),math.max(W2,H2))
end

-- Function for ordering players/enemies based on Z level
function orderZ(a,b)
  return a.z < b.z
end

function CalculateAngle(targetX, targetY, playerX, playerY)
  local theAngle = math.atan2(targetY-playerY, targetX-playerX)
  
  if theAngle < 0 then
    theAngle = theAngle + 2*math.pi
  elseif theAngle >= 2*math.pi then
    theAngle = theAngle - 2*math.pi
  end
  
  return theAngle
end

-- Just some handy dandy math functions I'll probably use a lot
function math.rsign() return love.math.random(2) == 2 and 1 or -1 end

function math.prandom(min, max) return love.math.random() * (max - min) + min end

function math.random() return love.math.random() end

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function math.clamp(n, low, high) return math.min(math.max(low, n), high) end

function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end
