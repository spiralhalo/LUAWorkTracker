local C = require "const"
local utf8 = require "utf8"

local TextField = {}

function TextField.new(_height, _content)
  local o = {
    height = _height or (C.LINE_HEIGHT+C.PADDING),
    content = _content or "",
    cb = _cb
  }
  o.parent = nil
  o.hover = false
  o.active = false
  o.x = 0
  o.y = 0
  o.width = C.WINDOW_W
  o._cursorDisplay = false
  o._internClock = 0
  o._internKeyClock = 0
  o._prevMstate = false
  setmetatable(o, {__index = TextField})
  return o
end

TextField.activeTF = nil
function TextField.receiveText(t)
  if TextField.activeTF == nil then return end
  if TextField.activeTF.active and TextField.activeTF.parent.active then
    TextField.activeTF.content = TextField.activeTF.content .. t
  end
end

function TextField.receiveKey(key)
  if TextField.activeTF == nil then return end
  if TextField.activeTF.active and TextField.activeTF.parent.active then
    if key == 'backspace' then
      -- get the byte offset to the last UTF-8 character in the string.
      local byteoffset = utf8.offset(TextField.activeTF.content, -1)

      if byteoffset then
          -- remove the last UTF-8 character.
          -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
          TextField.activeTF.content = TextField.activeTF.content:sub(1, byteoffset - 1)
      end
    end
  end
end

function TextField:draw()
  if self.hover then
    love.graphics.setColor( 0.4, 0.4, 0.4, 1)
  else
    love.graphics.setColor( 0.2, 0.2, 0.2, 1)
  end
  love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
  if self.active then
    love.graphics.setColor( 0, 1, 1, 1)
  elseif self.hover then
    love.graphics.setColor( 0.8, 0.8, 0.8, 1)
  else
    love.graphics.setColor( 0.5, 0.5, 0.5, 1)
  end
  love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
  love.graphics.print( self.content, self.x+C.PADDING, self.y+C.PADDING/2 )

  if self.active and self._cursorDisplay then
    font = love.graphics.getFont()
    width = font:getWidth(self.content)
    love.graphics.rectangle( 'fill', self.x+width+C.PADDING, self.y+C.PADDING, 2, self.height-C.PADDING*2)
  end
end

function TextField:update(dt)
  self._internClock = self._internClock + dt
  if self._internClock > C.CURSOR_PERIOD then
    self._internClock = 0
    self._cursorDisplay = not self._cursorDisplay
  end

  x, y = love.mouse.getPosition( )
  if x > self.x and x < self.x+self.width and y > self.y and y < self.y + self.height then
    if love.mouse.isDown(1) and not self._prevMstate then
      self.active = true
      TextField.activeTF = self
    end
    self.hover = not self.active
  else
    if love.mouse.isDown(1) and not self._prevMstate then
      self.active = false
    end
    self.hover = false
  end
  if self.pressed and not love.mouse.isDown(1) then self.pressed = false end
  self._prevMstate = love.mouse.isDown(1)
end

return TextField
