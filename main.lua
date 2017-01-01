GAME_STATES = {}
CURRENT_STATE = nil
local suit = require "suit"
local multiCheck = {text = "Multiplayer"}
local teamCheck = {text = "Teams?"}
local enemySlider = {value = 2, min = 0, max = 10}

suit.theme.color = {
    normal  = {bg = { 66, 66, 66}, fg = {100,100,100}},
    hovered = {bg = { 50,153,187}, fg = {0,0,0}},
    active  = {bg = {255,153,  0}, fg = {225,0,225}}
}

function love.load()
  -- load classic library
  Object = require "classic"
  
  -- load grid object
  require "grid"
  
  -- load fireworks objects
  require "firework"
  
  -- load file containing player and enemy definition
  require "actor"
  require "player"
  require "enemy"
  
  -- load file for explosions
  require "explosion"
  
  -- dust clouds
  require "dust"
  
  -- some other graphical thingies
  love.graphics.setBackgroundColor(255,255,255)
  
  WINDOW_WIDTH = love.graphics.getWidth()
  WINDOW_HEIGHT = love.graphics.getHeight()
  explosionsTable = {}
  BLOCK_SIZE = 20
  
  switchGameState("mainMenu")
end

function love.update(dt)
  GAME_STATES[CURRENT_STATE](dt)
end

function love.draw()
  GAME_STATES[CURRENT_STATE..tostring("Draw")]()
end

function switchGameState(newState)
  CURRENT_STATE = newState
  if GAME_STATES[CURRENT_STATE..tostring("Init")] ~= nil then
    GAME_STATES[CURRENT_STATE..tostring("Init")]()
  end
end

function GAME_STATES.mainGameInit()
  GLOBAL_ID = 0
  
  main_grid = Grid()
  
  fireworksTable = {}
  playersTable = {}
  explosionsTable = {}
  dustTable = {}
  
  PLAYER_SIZE = CELL_SIZE
  BLOCK_SIZE = CELL_SIZE*0.5
  
  GAME_RESULT = nil
  whoIsDead = 0
  
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

end

function GAME_STATES.mainGameDraw()
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
  
  love.graphics.setColor(100, 100, 100)
  -- love.graphics.setNewFont(12)
  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function GAME_STATES.mainMenu(dt)
  suit.layout:reset(WINDOW_WIDTH*0.5-150,WINDOW_HEIGHT*0.5-245)
  
  suit.Label("DRUNKEN FIREWORKS", {align = "center"}, suit.layout:row(300,50))
  
  suit.layout:padding(80)
  
  suit.Checkbox(multiCheck, {align = 'right'}, suit.layout:row(300,50))
  suit.layout:padding(0)
  
  suit.Checkbox(teamCheck, {align = 'right'}, suit.layout:row(300,50))
  
  suit.layout:padding(40)
  
  suit.Label("Amount of Enemies:", {align = "left"}, suit.layout:row(300,50))
  
  suit.layout:padding(0)
  
  suit.layout:push(suit.layout:row())
    suit.Slider(enemySlider, suit.layout:col(200, 50))
    suit.Label(("%i"):format(enemySlider.value),  {align = "right"}, suit.layout:col(100,50))
  suit.layout:pop()
  
  suit.layout:padding(40)
  
  suit.Label("Press RETURN to start", {align = "center"}, suit.layout:row(300, 50))
  
  -- Random Explosions!
  if math.random() > 0.96 then
    table.insert(explosionsTable, Explosion(WINDOW_WIDTH*math.random(), WINDOW_HEIGHT*math.random()))
  end
  
  -- update all explosions
  for i=#explosionsTable,1,-1 do
    if explosionsTable[i].isDead then
      table.remove(explosionsTable, i)
    else
      explosionsTable[i]:update(dt)
    end
  end
end

function GAME_STATES.mainMenuDraw()
  -- draw all explosions
  for i=1,#explosionsTable do
    explosionsTable[i]:draw()
  end
  
  love.graphics.setColor(20, 20, 20)
  love.graphics.setNewFont(24)
  suit.draw()
end

function GAME_STATES.gameOver(dt)
  -- pass
end

function GAME_STATES.gameOverDraw(dt)
  love.graphics.setNewFont(48)
  local text = ""
  if GAME_RESULT == "WIN" then
    text = "You won!"
  elseif GAME_RESULT == "LOSE" then
    text = "You lost..."
  elseif GAME_RESULT == "WIN 1" then
    text = "Player 1 won!"
  elseif GAME_RESULT == "WIN 2" then
    text = "Player 2 won!"
  end
  
  local centerPosition = WINDOW_HEIGHT*0.5 - (80 + 112 + 24)*0.5
  
  love.graphics.printf(text, 0, centerPosition, WINDOW_WIDTH, "center")
  
  love.graphics.setNewFont(24)
  love.graphics.printf("Press RETURN to return to main menu", 0, centerPosition+80, WINDOW_WIDTH, "center")
  love.graphics.printf("Press SHIFT to play again", 0, centerPosition+112, WINDOW_WIDTH, "center")
end

function love.keyreleased(key)
    if CURRENT_STATE == "gameOver" then
      if key == "lshift" or key == "rshift" then
        switchGameState("mainGame")
      elseif key == "return" then
        switchGameState("mainMenu")
      end
    elseif CURRENT_STATE == "mainMenu" then
      if key == "return" then
        switchGameState("mainGame")
      end
    end
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
