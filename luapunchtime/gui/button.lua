local C = require "const"

local Button = {}

function Button.new(_height, _label, _cb)
  local o = {
    height = _height or (C.BTN_HEIGHT),
    label = _label or "_button_",
    cb = _cb
  }
  o.parent = nil
  o.disabled = false
  o.hover = false
  o.down = false
  o.pressed = false
  o.x = 0
  o.y = 0
  o.width = C.WINDOW_W
  o._prevMstate = false
  setmetatable(o, {__index = Button})
  return o
end

function Button:draw()
  movetext = 0
  if self.disabled then
    love.graphics.setColor( 0.25, 0.25, 0.25, 1)
  elseif self.down then
    love.graphics.setColor( 0.1, 0.1, 0.1, 1)
    movetext = 3
  elseif self.hover then
    love.graphics.setColor( 0.4, 0.4, 0.4, 1)
  else
    love.graphics.setColor( 0.2, 0.2, 0.2, 1)
  end
  love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
  if self.disabled then
    love.graphics.setColor( 0.6, 0.6, 0.6, 1)
  else
    love.graphics.setColor( 1, 1, 1, 1)
  end
  love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
  love.graphics.print( self.label, self.x+C.PADDING+movetext, self.y+C.PADDING/2+movetext )
end

function Button:update(dt)
  if self.disabled then return end
  x, y = love.mouse.getPosition( )
  if x > self.x and x < self.x+self.width and y > self.y and y < self.y + self.height then
    if love.mouse.isDown(1) and self._prevMstate == false then
      self.pressed = true
    end
    if self.pressed then
      if love.mouse.isDown(1) then
        self.down = true
      else
        self.down = false
        if self.cb ~= nil then
          self.cb()
        end
      end
    else
      self.down = false
    end
    self.hover = true
  else
    self.down = false
    self.hover = false
  end
  if self.pressed and not love.mouse.isDown(1) then self.pressed = false end
  self._prevMstate = love.mouse.isDown(1)
end

return Button
