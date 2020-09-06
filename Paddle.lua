Paddle = Class{}

function Paddle:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height

  self.dy = 0
  self.dx = 0
end

function Paddle:update(dt)
  if self.dy < 0 then
    self.y = math.max(0, self.y + self.dy * dt)
  elseif self.dy > 0 then
    self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt)
  elseif self.dx <= 0 then
    if self.x < VIRTUAL_WIDTH / 2 then
      self.x = math.max(4, self.x + self.dx * dt)
    elseif self.x > VIRTUAL_WIDTH / 2 then
      self.x = math.max((VIRTUAL_WIDTH / 2) + 24, self.x + self.dx * dt)
    end
  elseif self.dx > 0 then
    if self.x < VIRTUAL_WIDTH / 2 then
      self.x = math.min((VIRTUAL_WIDTH / 2) - 28, self.x + self.dx * dt)
    elseif self.x > VIRTUAL_WIDTH / 2 then
      self.x = math.min(VIRTUAL_WIDTH - 8, self.x + self.dx * dt)
    end
  end
end

function Paddle:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
