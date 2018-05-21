local userEvents = {"mouse_click", "mouse_up", "mouse_drag", "char", "key", "monitor_touch", "key_up", "paste", "terminate"}
local parentTerm = term.current()
local parentWidth, parentHeight = parentTerm.getSize()
local defaultProperties = {
  x = math.ceil(parentWidth/2-parentWidth/4),
  y = math.ceil(parentHeight/2-parentHeight/4),
  w = math.ceil(parentWidth/2), h = math.ceil(parentHeight/2),
  noWindow = false, noBar = false, noInteraction = false,
  name = "Unnamed Window"
}

local isUserEvent = function(event)
  for userEventNum = 1, #userEvents do
    local userEvent = userEvents[userEventNum]
    if event == userEvent then
      return true
    end
  end
end

local createProcessCoroutine = function(func)
  return coroutine.create(function()
    local succ, mess = pcall(func)
    if not succ and mess then
      while true do
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.orange)
        term.clear()
        term.setCursorPos(1, 1)
        print("The program crashed!")
        write(mess)
        coroutine.yield()
      end
    end
  end)
end

return {
  getEventsForProcess = function(processNum, event, var1, var2, var3)

  end,
  drawWindowDecorations = function(self, processNum, event, var1, var2, var3)
    local process = self[processNum]

    paintutils.drawLine(process.x, process.y-1, process.x+process.w-1, process.y-1, colors.lightGray)
    term.setTextColor(colors.gray)

    term.setCursorPos(process.x+process.w-1, process.y-1)
    term.write("x")
    term.setCursorPos(process.x, process.y-1)
    term.write(process.name)
  end,
  handleInputOfProcess = function(self, processNum, event, var1, var2, var3)
    local process = self[processNum]
    local px, py = process.term.getPosition()
    local pw, ph = process.term.getSize()
    local mx, my
    if var3 then
      mx, my = var2-px+1, var3-py+1
    end

    if event == "mouse_click" then
      if mx>0 and my==0 and mx<pw+1 then
        if mx == pw then
          table.remove(self, processNum)
        else
          process.clickedX, process.clickedY = mx, my
          process.barClicked = true
        end
      else
        process.barClicked = false
      end
    elseif event == "mouse_drag" and process.barClicked then
      process:reposition(process.x-(process.clickedX-mx), process.y-(process.clickedY-my))
    elseif event == "mouse_up" then
      process.barClicked = false
    end
  end,
  updateProgramOfProcess = function(self, processNum, event, var1, var2, var3)
    local process = self[processNum]
    local pw, ph = process.term.getSize()
    local px, py = process.term.getPosition()
    local var1, var2, var3 = var1, var2, var3


    if string.sub(event, 1, #"mouse") == "mouse" then
      var2 = var2-px+1
      var3 = var3-py+1
    end

    -- redirect to process window and update it
    local oldTerm = term.redirect(process.term)
    coroutine.resume(process.coroutine, event, var1, var2, var3 )

    -- redirect to the old term and redraw the process window
    term.redirect(oldTerm)
    process.term.redraw()
  end,
  updateProcess = function(self, processNum, event, var1, var2, var3)
    local process = self[processNum]

    -- check if process is still running, if not, remove it
    if coroutine.status(process.coroutine) == "dead" then
      table.remove(self, processNum)
      return
    end

    self:handleInputOfProcess(processNum, event, var1, var2, var3)
    if self[processNum] then
      self:drawWindowDecorations(processNum, event, var1, var2, var3)
      self:updateProgramOfProcess(processNum, event, var1, var2, var3)
    end
  end,
  -- start process with command as function
  run = function(self, command)
    self:new(function() shell.run(command) end, {name = command})
  end,
  -- start process from directory
  start = function(self, programName)
    local programPath = "/programs/"..programName.."/"
    local width, height = term.getSize()
    local programProperties = {}

    if fs.exists(programPath.."properties.lua") then
      programProperties = dofile(programPath.."properties.lua")
    end

    local program = loadfile(programPath.."init.lua", _ENV)
    self:new(program, programProperties)
  end,
  -- start a new process
  new = function(self, func, properties)
    local process = {
      coroutine = createProcessCoroutine(func),
      reposition = function(self, x, y)
        self.x, self.y = x, y
        self.term.reposition(x, y)
      end,
      resize = function(self, w, h)
        local oldX, oldY = self.term.getPosition()
        self.term.reposition(oldX, oldY, w, h)
        os.queueEvent("term_resize")
      end
    }

    for k, v in pairs(defaultProperties) do
      process[k] = properties[k] or v
    end

    process.term = window.create(
      parentTerm, process.x, process.y, process.w, process.h
    )

    table.insert(self, process)
  end,
  -- update all processes
  update = function(self, event, var1, var2, var3)
    for processNum, process in ipairs(self) do
      self:updateProcess(processNum, event, var1, var2, var3)
    end
  end
}
