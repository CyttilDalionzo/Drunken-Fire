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