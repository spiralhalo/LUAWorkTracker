require "global"
local C = require "const"
local Util = require "util"
local GUI = require "gui.gui"
local Button = require "gui.button"
local List = require "gui.list"
local TextField = require "gui.textfield"
local Label = require "gui.label"

local mainGUI = nil
local newTaskBtn = nil
local endTaskBtn = nil
local historyList = nil
local newTaskGUI = nil
local newTaskTxt = nil
local newTaskOKBtn = nil
local newTaskHistoryList = nil

local ActiveGUI = {}
local CurrentActivity = {
  running = false,
  name = "",
  startTime = 0
}

function LoadData()
  temp, e = love.filesystem.read(C.FILENAME.labelHistory)
  if temp ~= nil then
    ProgramData.labelHistory = ParseDataString(temp)
  end
  temp, e = love.filesystem.read(C.FILENAME.timeTable)
  temp1 = nil
  if temp ~= nil then
    ProgramData.timeTable = ParseDataString(temp)
  end
end

function SaveData()
  love.filesystem.write(C.FILENAME.labelHistory, ComposeDataString(ProgramData.labelHistory))
  love.filesystem.write(C.FILENAME.timeTable, ComposeDataString(ProgramData.timeTable))
end

function ParseDataString(string)
  temp0 = Util.strSplit(string, "\n")
  temp3 = {}
  for k,v in pairs(temp0) do
    temp2 = {}
    temp1 = Util.strSplit(v, ",")
    for k1,v1 in pairs(temp1) do
      table.insert(temp2,v1)
    end
    if #temp2 == 1 then
      temp2 = temp2[1]
    end
    table.insert(temp3, temp2)
  end
  return temp3
end

function ComposeDataString(data)
  last_row = #data
  temp0 = {}
  for i,v in ipairs(data) do
    temp1 = nil
    if type(v) == 'table' then
      temp1 = {}
      for i1,v1 in ipairs(v) do
        temp1[i1] = tostring(v1)
      end
      temp1 = table.concat(temp1, ",")
    else
      temp1 = tostring(v)
    end
    table.insert(temp0,temp1)
  end
  temp0 = table.concat(temp0, "\n")
  return temp0
end

function AddActiveGUI(gui)
  for k,v in pairs(ActiveGUI) do
    v.active = false
  end
  gui.x = C.PADDING*2*#ActiveGUI
  gui.width = C.WINDOW_W-C.PADDING*4*#ActiveGUI
  gui.y = C.PADDING*2*#ActiveGUI
  gui:refresh()
  table.insert(ActiveGUI, gui)
end

function RemoveActiveGUI()
  table.remove(ActiveGUI,#ActiveGUI)
  ActiveGUI[#ActiveGUI].active = true
end

function NewTaskCB()
  AddActiveGUI(newTaskGUI)
  newTaskTxt.active = true
  TextField.activeTF = newTaskTxt
  newTaskBtn.disabled = true
  endTaskBtn.disabled = false
end

function EndTaskCB()
  newTaskBtn.disabled = false
  endTaskBtn.disabled = true
  EndActivity()
end

function StartActivity(name)
  CurrentActivity.running = true
  CurrentActivity.name = name
  CurrentActivity.startTime = os.time()
  table.insert(ProgramData.timeTable,{Util.dateString(CurrentActivity.startTime),'start',name})
  SaveData()
end

function EndActivity()
  if not CurrentActivity.running then return end
  CurrentActivity.running = false
  elapsed = os.time() - CurrentActivity.startTime
  table.insert(ProgramData.timeTable,{Util.dateString(os.time()),'END',CurrentActivity.name,'worked '..Util.hourstring(elapsed)})
  SaveData()
end

function NewTaskOKCB()
  text = newTaskTxt.content
  if text == "" then
    text = "-- unspecified --"
  elseif ProgramData.labelHistory[1] ~= text then
    table.insert(ProgramData.labelHistory,1,text)
    i = 2
    while i <= #ProgramData.labelHistory do
      if ProgramData.labelHistory[i] == text then
        table.remove(ProgramData.labelHistory, i)
      else
        i = i+1
      end
    end
  end
  StartActivity(text)
  newTaskTxt.content = ""
  RemoveActiveGUI()
end

function HistoryListCB(i)
  newTaskTxt.content = ProgramData.labelHistory[i]
  newTaskTxt.active = true
end

function love.load()
  love.window.setTitle ("Productivity App")
	love.window.setMode(C.WINDOW_W, C.WINDOW_H)
	love.graphics.setDefaultFilter("nearest","nearest")
  love.keyboard.setKeyRepeat(true)
  love.filesystem.setIdentity("luapunchtime")
  LoadData()
  mainGUI = GUI.new()
  newTaskBtn = Button.new(nil, "start new task", NewTaskCB)
  mainGUI:addWidget(newTaskBtn, nil)
  endTaskBtn = Button.new(nil, "end task", EndTaskCB)
  endTaskBtn.disabled = true
  mainGUI:addWidget(endTaskBtn, nil)
  historyList = List.new(C.WINDOW_H-mainGUI.height-C.PADDING, ProgramData.timeTable)
  historyList.reversed = true
  mainGUI:addWidget(historyList, nil)
  AddActiveGUI(mainGUI)
  newTaskGUI = GUI.new(nil, nil, "Start a new task")
  newTaskTxt = TextField.new(nil, nil)
  newTaskOKBtn = Button.new(nil, "confirm", NewTaskOKCB)
  newTaskHistoryList = List.new(200, ProgramData.labelHistory, HistoryListCB)
  newTaskGUI:addWidget(Label.new(nil, "What are you doing right now?"), nil)
  newTaskGUI:addWidget(newTaskTxt, nil)
  newTaskGUI:addWidget(newTaskOKBtn, nil)
  newTaskGUI:addWidget(Label.new(nil, "Or choose from recent tasks:"), nil)
  newTaskGUI:addWidget(newTaskHistoryList, nil)
end

function love.quit()
  EndActivity()
  return false
end

function love.draw()
  for k,v in pairs(ActiveGUI) do
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, C.WINDOW_W, C.WINDOW_H)
    v:draw()
  end
end

function love.update(dt)
  for k,v in pairs(ActiveGUI) do
    v:update(dt)
  end
end

function love.textinput(t)
  TextField.receiveText(t)
end

function love.keypressed(key, scancode, isrepeat)
  TextField.receiveKey(key)
end
