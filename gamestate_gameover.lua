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