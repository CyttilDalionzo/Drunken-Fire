GAME_STATES = {}
CURRENT_STATE = nil
suit = require "suit"
multiCheck = {text = "Multiplayer"}
teamCheck = {text = "Teams?"}
enemySlider = {value = 2, min = 0, max = 20}

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
  
  -- powerups
  require "powerups"
  
  -- bombs
  require "bomb"
  
  -- some other graphical thingies
  love.graphics.setBackgroundColor(255,255,255)
  
  WINDOW_WIDTH = love.graphics.getWidth()
  WINDOW_HEIGHT = love.graphics.getHeight()
  explosionsTable = {}
  BLOCK_SIZE = 20
  
  require "gamestate_mainmenu"
  require "gamestate_maingame"
  require "gamestate_gameover"
  
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
