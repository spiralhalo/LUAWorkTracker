local C = require "const"
local Util = require "util"

local List = {}

function List.new(_height, _content, _cb, _useColor)
  local o = {
    height = _height or (C.BTN_HEIGHT + C.PADDING),
    content = _content or {},
    cb = _cb or nil,
    useColor = _useColor
  }
  o.parent = nil
  o.reversed = false
  o.x = 0
  o.y = 0
  o.width = C.WINDOW_W
  o.startRow = 1
  o.mousein = false
  o._count = #o.content
  o._colorCache = nil
  setmetatable(o, {__index = List})
  o:refresh()
  return o
end

function List:refresh(dec)
  if self.useColor ~= nil then
    if dec == true or self._colorCache == nil then
      self._colorCache = {}
      for i=1,self._count do
        text = self.content[i]
        color = nil
        if type(text) == 'table' and type(self.useColor) == 'number' then
          color = Util.colorHash(text[self.useColor])
        else
          color = Util.colorHash(text)
        end
        table.insert(self._colorCache, color)
      end
    else
      text = self.content[self._count]
      color = nil
      if type(text) == 'table' and type(self.useColor) == 'number' then
        color = Util.colorHash(text[self.useColor])
      else
        color = Util.colorHash(text)
      end
      table.insert(self._colorCache, color)
    end
  end
  self.lineheight = C.LINE_HEIGHT + C.PADDING/2
  self.n_showable = (self.height - C.PADDING) / self.lineheight
  self.maxStartRow = self._count - self.n_showable + 1
  if self.maxStartRow < 1 then
    self.maxStartRow = 1
  end
end

function List:set(v)
  self.content = v
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
  -- determine visible rows
  startShow = self.startRow
  endShow = self.startRow+self.n_showable-1
  inc = 1
  if self.reversed then
    startShow = self._count - startShow + 1
    endShow = self._count - endShow + 1
    inc = -1
  end
  -- determine selected row
  selected = 0
  if self.mousein then
    line = math.floor((love.mouse.getY()-self.y)/self.lineheight)
    if line <= math.abs(endShow-startShow) then
      selected = line*inc + startShow
      -- render selected row
      y = line*self.lineheight
      love.graphics.setColor( 0.4, 0.4, 0.4, 1)
      love.graphics.rectangle( 'fill', self.x+C.PADDING/2, self.y+y+C.PADDING/4, self.width-C.PADDING/2, self.lineheight)
      -- detect mouse click
      if love.mouse.isDown(1) and self.cb ~= nil then
        self.cb(selected)
      end
    end
  end
  -- render visible row
  y = 0
  for i=startShow,endShow,inc do
    if self.content[i] == nil then break end
    text = self.content[i]
    if type(text) == 'table' then
      text = table.concat(text, ", ")
    end
    if self.useColor ~= nil and selected ~= i then
      love.graphics.setColor(self._colorCache[i])
      love.graphics.rectangle( 'fill', self.x+C.PADDING/2, self.y+y+C.PADDING/4, self.width-C.PADDING/2, self.lineheight)
    end
    love.graphics.setColor( 1, 1, 1, 1)
    love.graphics.print( text, self.x+C.PADDING, self.y+C.PADDING+y )
    y = y + self.lineheight
  end
  -- render border
  love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
end

function List:update(dt)
  if self._count ~= #self.content then
    dec = self._count > #self.content
    self._count = #self.content
    self:refresh(dec)
  end
  x, y = love.mouse.getPosition( )
  if x > self.x and x < self.x+self.width and y > self.y+C.PADDING/2 and y < self.y+self.height-C.PADDING/2 then
    self.mousein = true
  else
    self.mousein = false
  end
end

return List
