Ball = Class{}

function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height

  if difficulty == 1 then
    self.dx = math.random(2) == 1 and -85 or 85 --lua version of ternery function
    self.dy = math.random(-45, 45)
  elseif difficulty == 2 then
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
  else 
    self.dx = math.random(2) == 1 and -150 or 150
    self.dy = math.random(-65, 65)
  end
end

function Ball:collides(box)
  if self.x > box.x + box.width or self.x + self.width < box.x then
    return false
  end

  if self.y > box.y + box.height or self.y + self.height < box.y then
    return false
  end

  return true
end

function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2

  if difficulty == 1 then
    self.dx = math.random(2) == 1 and -85 or 85 --lua version of ternery function
    self.dy = math.random(-45, 45) * 1.25
  elseif difficulty == 2 then
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50) * 1.5
  else
    self.dx = math.random(2) == 1 and -150 or 150
    self.dy = math.random(-65, 65) * 1.75
  end
end

function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

function Ball:afterScore(dt)
  if self.dy <= 0 then
    self.y = math.max(8, self.y + self.dy * dt)
  elseif self.dy > 0 then
    self.y = math.min(VIRTUAL_HEIGHT - 12, self.y + self.dy * dt)
  end
end

function Ball:serve(dt)
  if difficulty == 1 then
    self.dx = servingPlayer == 1 and 100 or -85 --lua version of ternery function
    self.dy = math.random(-45, 45) * 1.25
  elseif difficulty == 2 then
    self.dx = servingPlayer == 1 and 100 or -100
    self.dy = math.random(-50, 50) * 1.5
  else
    self.dx = servingPlayer == 1 and 100 or -150
    self.dy = math.random(-65, 65) * 1.75
  end
end

function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, 4, 4) --Ball
end
