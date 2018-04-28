local Button = require "gui.button"
local Label = require "gui.label"
local List = require "gui.list"
local C = require "const"

local GUI = {}

function GUI.new(_padding, _width, _title)
  local o = {
    padding = _padding or C.PADDING,
    width = _width or C.WINDOW_W,
    height = C.WINDOW_H,
    title = _title
  }
  o.x = 0
  o.y = 0
  o.height = 10
  o.active = true
  o.modal = false
  o.widgets = {}
  setmetatable(o, {__index = GUI})
  return o
end

function GUI:draw()
  love.graphics.setLineStyle( "rough" )
  love.graphics.setLineWidth( 2 )
  love.graphics.setColor( 0.1, 0.1, 0.1, 1)
  love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
  if self.title ~= nil then
    love.graphics.setColor( 0.5, 0.2, 0.9, 1)
    love.graphics.rectangle( 'fill', self.x, self.y, self.width, C.TITLE_HEIGHT )
    love.graphics.setColor( 0.8, 0.9, 1, 1)
    love.graphics.print(self.title, self.x+C.PADDING, self.y+C.PADDING*2)
  end
  love.graphics.setColor( 1, 1, 1, 1)
  love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
  for k,v in pairs(self.widgets) do
    v:draw()
  end
end

function GUI:numWidgets()
  return #(self.widgets)
end

function GUI:addWidget(widget, position)
  pos = position or (self:numWidgets()+1)
  widget.parent = self
  table.insert(self.widgets, pos, widget)
  self:refresh()
end

function GUI:refresh()
  y = self.y + C.PADDING
  if self.title ~= nil then y = y + C.TITLE_HEIGHT end
  for i,v in ipairs(self.widgets) do
    v.y = y
    v.x = self.x + C.PADDING
    v.width = self.width - C.PADDING * 2
    y = y + v.height
    y = y + C.PADDING
  end
  self.height = y
end

function GUI:update(dt)
  if not self.active then return end
  for k,v in pairs(self.widgets) do
    v:update(dt)
  end
end

return GUI
