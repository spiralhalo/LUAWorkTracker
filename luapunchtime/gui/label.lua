local C = require "const"

local Label = {}

function Label.new(_height, _label)
  local o = {
    height = _height or (C.LINE_HEIGHT),
    label = _label or "_label_"
  }
  o.parent = nil
  o.x = 0
  o.y = 0
  o.width = C.WINDOW_W
  setmetatable(o, {__index = Label})
  return o
end

function Label:draw()
  love.graphics.print( self.label, self.x+C.PADDING, self.y+C.PADDING/2 )
end

function Label:update(dt)

end

return Label
