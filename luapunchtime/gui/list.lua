local C = require "const"
local Util = require "util"

local List = {}

function List.new(_height, _content, _cb, _useColor, _reverse)
  local o = {
    height = _height or (C.BTN_HEIGHT + C.PADDING),
    content = _content or {},
    cb = _cb or nil,
    useColor = _useColor,
    reverse = _reverse or false
  }
  o.parent = nil
  o.x = 0
  o.y = 0
  o.width = C.WINDOW_W
  o._scr = 1
  o._count = #o.content
  setmetatable(o, {__index = List})
  o:refresh()
  return o
end

function List.receiveMouseWheel(x, y)
  if List.activ == nil then return end
  if y > 0 and List.activ._scr > 1 then
    List.activ._scr = List.activ._scr - 1
  elseif y < 0 and List.activ._scr < List.activ._mScr then
    List.activ._scr = List.activ._scr + 1
  end
  List.activ:refreshDisplay()
end

function List:refreshDisplay()
  local inc,hinc = self._inc,self._inc*0.5
  self._beg=self._scr*inc+self._count*(0.5-hinc)-(hinc-0.5)
  self._end=(self._scr+self._nshown-1)*inc+self._count*(0.5-hinc)
end

function List:refresh(dc)
  if self.useColor ~= nil then
    local st = self._count
    if dc == true or self._color == nil then
      self._color = {}
      st = 1
    end
    for i=st,self._count do
      local txt, cl = self.content[i]
      if type(txt) == 'table' and type(self.useColor) == 'number' then
        cl = Util.colorHash(txt[self.useColor])
      else
        cl = Util.colorHash(txt)
      end
      table.insert(self._color, cl)
    end
  end
  self.line_h = C.LINE_HEIGHT + C.PADDING/2
  self._nshown = math.floor((self.height - C.PADDING) / self.line_h)
  self._mScr = math.max(self._count - self._nshown + 1, 1)
  self._sb = self._nshown < self._count
  self._sb_h = self._nshown/self._count*self.height-C.PADDING*2
  if self.reverse then
    self._inc = -1
  else
    self._inc = 1
  end
  self:refreshDisplay()
end

function List:set(v)
  self.content = v
  self:refresh()
end

function List:draw()
  love.graphics.setColor( 0.1, 0.1, 0.1, 1)
  love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
  -- render visible row
  local y = 0
  for i=self._beg,self._end,self._inc do
    if self.content[i] ~= nil then
      local text = self.content[i]
      if type(text) == 'table' then
        text = table.concat(text, ", ")
      end
      if self.useColor ~= nil then
        love.graphics.setColor(self._color[i])
        love.graphics.rectangle( 'fill', self.x+C.PADDING/2, self.y+y+C.PADDING/4, self.width-C.PADDING/2, self.line_h)
      end
      love.graphics.setColor( 1, 1, 1, 1)
      love.graphics.print( text, self.x+C.PADDING, self.y+C.PADDING+y )
      y = y + self.line_h
    end
  end
  -- render highlight
  if self._mousein == true then
    local line = (self._sel - self._beg)*self._inc
    if line <= math.abs(self._end-self._beg) then
      local y = line*self.line_h
      love.graphics.setBlendMode('add')
      love.graphics.setColor(1, 1, 1, 0.2)
      love.graphics.rectangle( 'fill', self.x+C.PADDING/2, self.y+y+C.PADDING/4, self.width-C.PADDING/2, self.line_h)
      love.graphics.rectangle( 'line', self.x+C.PADDING/2, self.y+y+C.PADDING/4+1, self.width-C.PADDING/2-3, self.line_h-3)
      love.graphics.setBlendMode('alpha','alphamultiply')
    end
  end
  -- render border
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
  -- render scrollbar
  if self._sb then
    love.graphics.setColor( 1, 1, 1, 0.7)
    local scrolly = self.y+self.height*(self._scr-1)/self._count + C.PADDING
    local xsize = C.PADDING
    love.graphics.rectangle( 'fill', self.x+self.width-xsize*2, scrolly, xsize, self._sb_h, xsize/2, math.min(xsize/2,self._sb_h/2) )
  end
end

function List:update(dt)
  if self._count ~= #self.content then
    dec = self._count > #self.content
    self._count = #self.content
    self:refresh(dec)
  end
  local mx, my = love.mouse.getPosition( )
  if mx > self.x and mx < self.x+self.width and my > self.y+C.PADDING/2 and my < self.y+self.height-C.PADDING/2 then
    self._sel = math.floor((my-self.y)/self.line_h)*self._inc + self._beg
    self._mousein = true
    List.activ = self
    -- detect mouse click
    if love.mouse.isDown(1) and self.cb ~= nil then
      self.cb(self._sel)
    end
  else
    self._sel = nil
    self._mousein = false
    if List.activ == self then
      List.activ = nil
    end
  end
end

return List
