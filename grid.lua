-- The underlying grid. 
-- I made it into a class to keep the main file clean, and because I don't know if I want to do stuff with it in the future
Grid = Object:extend()

CELL_SIZE = nil
WINDOW_WIDTH = nil
LEVEL_WIDTH = 24
LEVEL_HEIGHT = 16

function Grid:new()
  WINDOW_WIDTH = love.graphics.getWidth()
  WINDOW_HEIGHT = love.graphics.getHeight()
  CELL_SIZE = WINDOW_WIDTH/LEVEL_WIDTH
end

function Grid:draw()
  love.graphics.setColor(180, 180, 180, 180)
  for i=0,LEVEL_WIDTH do
    love.graphics.line(i*CELL_SIZE, 0, i*CELL_SIZE, WINDOW_HEIGHT)
  end
  
  for i=0,LEVEL_HEIGHT do
    love.graphics.line(0, i*CELL_SIZE, WINDOW_WIDTH, i*CELL_SIZE)
  end

end