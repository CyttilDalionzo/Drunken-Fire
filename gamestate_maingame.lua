function GAME_STATES.mainGameInit()
  GLOBAL_ID = 0
  
  main_grid = Grid()
  
  fireworksTable = {}
  playersTable = {}
  explosionsTable = {}
  dustTable = {}
  powerupsTable = {}
  bombsTable = {}
  
  PLAYER_SIZE = CELL_SIZE
  BLOCK_SIZE = CELL_SIZE*0.5
  
  GAME_RESULT = nil
  whoIsDead = 0
  powerupCounter = 0
  shakyCanvas = -2
  
  MULTIPLAYER = multiCheck.checked
  TEAMS = teamCheck.checked
  AMOUNT_ENEMIES = math.floor(enemySlider.value)
  
  if MULTIPLAYER then
    AMOUNT_PLAYERS = 2
  else
    AMOUNT_PLAYERS = 1
  end
  
  -- initialize player(s)
  local p1 = Player(CELL_SIZE, CELL_SIZE, PLAYER_SIZE, PLAYER_SIZE, 1, 8)
  table.insert(playersTable, p1)
  
  if AMOUNT_PLAYERS == 2 then
    local p2 = Player(WINDOW_WIDTH - CELL_SIZE*2, WINDOW_HEIGHT - CELL_SIZE*2, PLAYER_SIZE, PLAYER_SIZE, 2, 8)
    table.insert(playersTable, p2)
  end
  
  for i=1,AMOUNT_ENEMIES do
    local e = Enemy(math.random()*(WINDOW_WIDTH-CELL_SIZE), math.random()*(WINDOW_HEIGHT-CELL_SIZE), PLAYER_SIZE, PLAYER_SIZE, 4)
    table.insert(playersTable, e)
  end
end

function GAME_STATES.mainGame(dt)
  -- update all fireworks
  for i=#fireworksTable, 1, -1 do
    local f = fireworksTable[i]
    f:update(dt)
    if f.isDead then
      table.remove(fireworksTable, i)
    else
      -- check for collisions between fireworks and player(s); only if close enough, and on same depth level
      for j=1,#playersTable do
        local p = playersTable[j]
        -- Sending signals to enemies
        if p.enemy then 
          if CheckCollisionPlayer(f.x, f.y, p.centerX, p.centerY, math.max(p.width, p.height)+20) and f.owner ~= p.id then
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
        
        -- Collision Checking; not one of their own fireworks, same Z level, colliding with player
        if f.owner ~= p.id and CheckZ(f.z, p.z) and CheckCollisionPlayer(f.x, f.y, p.centerX, p.centerY, math.max(p.width, p.height)) then
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
  end
  
  -- update all bombs
  for i,b in ipairs(bombsTable) do
    if b.isDead then
      table.remove(bombsTable, i)
    else
      b:update(dt)
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
    
    -- collide with powerups  
    for k, powerUp in ipairs(powerupsTable) do
      if CheckCollisionPlayer(p.centerX, p.centerY, powerUp.x, powerUp.y, powerUp.radius+p.width*0.5) then
        -- do something based on powerUp type
        local poType = powerUp.theType
        if poType == 0 then
          p.poSpeed = p.poSpeed - MAX_WALKING_SPEED*0.2
        elseif poType == 1 then
          p.poSpeed = p.poSpeed + MAX_WALKING_SPEED*0.2
        elseif poType == 2 then
          p.poRotation = p.poRotation - ROTATING_SPEED*0.2
        elseif poType == 3 then
          p.poRotation = p.poRotation + ROTATING_SPEED*0.2
        elseif poType == 4 then
          p.poFireworkSpeed = p.poFireworkSpeed - FIREWORKS_SPEED*0.2 
        elseif poType == 5 then
          p.poFireworkSpeed = p.poFireworkSpeed + FIREWORKS_SPEED*0.2
        elseif poType == 6 then
          -- Weapon 0 becomes 1, and weapon 1 becomes 0
          p.poWeapon = (p.poWeapon+1)%2
        elseif poType == 7 then
          -- True becomes false, false becomes true
          p.poJump = (p.poJump ~= true)
        elseif poType == 8 then
          p:ChangeHealth(1)
        end
        table.remove(powerupsTable, k)
      end
    end
    
    -- Collide with bombs
    for i,b in ipairs(bombsTable) do
      if b.isDead and CheckCollisionPlayer(p.centerX, p.centerY, b.x, b.y, p.width+b.bombHitRadius) and p.id ~= b.owner then
        p:ChangeHealth(-2)
      end
    end
    
    if p.enemy then
      p.lockDirection = {0,0}
      for j,e in ipairs(playersTable) do
        if i ~= j then
          
          if p.myTarget == nil and
             CheckCollisionPlayer(p.centerX, p.centerY, e.centerX, e.centerY, p.width+e.width+500) and 
             math.abs(p.angle-CalculateAngle(e.centerX, e.centerY, p.centerX, p.centerY)) < 0.5*math.pi and
             p.id ~= e.id and
             math.random() > 0.8 then
            
             p.myTarget = j
             p.shootF = 1
             break
          end
          
          if CheckCollisionPlayer(p.centerX, p.centerY, e.centerX, e.centerY, p.width+e.width+45) and CheckZ(p.z, e.z) then
            p.lockDirection = {p.centerX - e.centerX, p.centerY - e.centerY}
          end
        end
      end
    end
    if p.isDead then
      if p.enemy then
        AMOUNT_ENEMIES = AMOUNT_ENEMIES - 1
      else 
        whoIsDead = p.controlNum
        AMOUNT_PLAYERS = AMOUNT_PLAYERS - 1
      end
      table.remove(playersTable, i)
    end
  end
  
  -- remove dust (particle) effects if dead
  for i=#dustTable,1,-1 do
    if dustTable[i].opacity <= 0.002 then
      table.remove(dustTable, i)
    end
  end
  
  -- Oh no, a random powerup appeared in the tall grass!
  powerupCounter = powerupCounter + dt
  if powerupCounter >= 4 then
    table.insert(powerupsTable, Powerup(WINDOW_WIDTH*math.random(), WINDOW_HEIGHT*math.random(), math.round(math.prandom(0,8))))
    powerupCounter = 0
  end
  
  -- GAME OVER CONDITIONS
  if TEAMS then
    if AMOUNT_ENEMIES <= 0 then
      GAME_RESULT = "WIN"
    elseif AMOUNT_PLAYERS <= 0 then
      GAME_RESULT = "LOSE"
    end
  elseif MULTIPLAYER then
    if whoIsDead == 1 then
      GAME_RESULT = "WIN 2"
    elseif whoIsDead == 2 then
      GAME_RESULT = "WIN 1"
    end
  else
    if AMOUNT_ENEMIES <= 0 then
      GAME_RESULT = "WIN"
    elseif whoIsDead == 1 then
      GAME_RESULT = "LOSE"
    end
  end
  
  if GAME_RESULT ~= nil then
    switchGameState("gameOver")
  end
  
  -- for shaky canvas
  if shakyCanvas > 0 then
    shakyCanvas = shakyCanvas - dt
  end
end

function GAME_STATES.mainGameDraw()
  -- shaking canvas special effect
  -- Intial state (-1): Save "normal" canvas translation, start shaking
  -- Shaky mode (0): Translate complete canvas randomly in X and Y direction
  -- Stop shaking (<0): Return to "normal" canvas translation, stop shaking
  if shakyCanvas == -1 then
    love.graphics.push()
    shakyCanvas = 0.25
  elseif shakyCanvas > 0 then
    love.graphics.translate(math.prandom(-5,5), math.prandom(-5,5))
  elseif shakyCanvas <= 0 and shakyCanvas > -1 then
    love.graphics.pop()
    shakyCanvas = -2
  end
  
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
  
  -- draw all bombs
  for i=1,#bombsTable do
    bombsTable[i]:draw()
  end
  
  -- draw all powerups
  for i=1,#powerupsTable do
    powerupsTable[i]:draw()
  end
  
  love.graphics.setColor(100, 100, 100)
  -- love.graphics.setNewFont(12)
  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end