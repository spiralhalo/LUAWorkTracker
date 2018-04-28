local C = require "const"

local List = {}

function List.new(_height, _content, _cb)
  local o = {
    height = _height or (C.BTN_HEIGHT + C.PADDING),
    content = _content or {},
    cb = _cb or nil
  }
  o.parent = nil
  o.x = 0
  o.y = 0
  o.width = C.WINDOW_W
  o.startRow = 1
  o.mousein = false
  setmetatable(o, {__index = List})
  o:refresh()
  return o
end

function List:refresh()
  n_content = #(self.content)
  self.lineheight = C.LINE_HEIGHT + C.PADDING/2
  self.n_showable = (self.height - C.PADDING) / self.lineheight
  self.maxStartRow = n_content - self.n_showable + 1
  if self.maxStartRow < 1 then
    self.maxStartRow = 1
  end
end

function List:set(v)
  self.content = v
  self:refresh()
end

function List:add(v, pos)
  if pos ~= nil then
    table.insert(self.content,v)
  else
    table.insert(self.content,pos,v)
  end
  self:refresh()
end

function List:remove(pos)
  table.remove(self.content, pos)
  self:refresh()
end

function List:draw()
  love.graphics.setColor( 0.1, 0.1, 0.1, 1)
  love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
  if self.startRow < 1 then
    self.startRow = 1
  elseif self.startRow > self.maxStartRow then
    self.startRow = self.maxStartRow
  end
  if self.mousein then
    love.graphics.setColor( 0.4, 0.4, 0.4, 1)
    line = math.floor((love.mouse.getY()-self.y)/self.lineheight)
    if line+1 >= self.startRow and line+1 <= #self.content then
      y = line*self.lineheight
      love.graphics.rectangle( 'fill', self.x+C.PADDING/2, self.y+y+C.PADDING/4, self.width-C.PADDING/2, self.lineheight)
      if love.mouse.isDown(1) and self.cb ~= nil then
        self.cb(line+self.startRow)
      end
    end
  end
  love.graphics.setColor( 1, 1, 1, 1)
  love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
  y = 0
  for i=self.startRow,self.startRow+self.n_showable-1 do
    if self.content[i] == nil then break end
    text = self.content[i]
    if type(text) == 'table' then
      text = table.concat(text, ", ")
    end
    love.graphics.print( text, self.x+C.PADDING, self.y+C.PADDING/2+y )
    y = y + self.lineheight
  end
end

function List:update(dt)
  x, y = love.mouse.getPosition( )
  if x > self.x and x < self.x+self.width and y > self.y+C.PADDING/2 and y < self.y+self.height-C.PADDING/2 then
    self.mousein = true
  else
    self.mousein = false
  end
end

return List
