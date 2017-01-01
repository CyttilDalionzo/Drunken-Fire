--[[ 
-- OLD TRY
function CheckCollisionFirework(X1, Y1, W1, H1, A1,   X2, Y2, W2, H2, A2)
  -- translate points to make X1, Y1 the origin
  local translateX = X2-X1
  local translateY = Y2-Y1
  
  -- rotate points
  translateX = translateX * math.cos(-A1) - translateY * math.sin(-A1)
  translateY = translateX * math.sin(-A1) + translateY * math.cos(-A1)
  
  -- un-translate
  X2 = translateX + X1
  Y2 = translateY + Y1
  
  -- now the first rectangle has been made orthogonal, but the second rectangle
  return CheckAABBCollision(X1,Y1,W1,H1, X2,Y2,W2,H2)
end

function CheckAABBCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
--]]

--[[ Old fullscreen function
function love.keyreleased(key)
  if key == "escape" then
    if IS_FULLSCREEN then
      IS_FULLSCREEN = false
    else
      IS_FULLSCREEN = true
    end
    love.window.setFullscreen(IS_FULLSCREEN)
  end
end
--]]


    --[[ Something with staying away from edges
    if math.abs(self.angle) < 0.5*math.pi and self.x > WINDOW_WIDTH-170 or
       math.abs(self.angle-0.5*math.pi) < 0.5*math.pi and self.y > WINDOW_HEIGHT-170 or
       math.abs(self.angle-math.pi) < 0.5*math.pi and self.x < 170 or
       math.abs(self.angle-1.5*math.pi) < 0.5*math.pi and self.y < 170 then
         self.shootF = 0
    end
    --]]