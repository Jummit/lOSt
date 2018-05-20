local userEvents = {"mouse_click", "mouse_up", "mouse_drag", "char", "key", "monitor_touch", "key_up", "paste", "terminate"}
local parentTerm = term.current()
local parentWidth, parentHeight = parentTerm.getSize()
local defaultProperties = {
  x = math.ceil(parentWidth/2-parentWidth/4),
  y = math.ceil(parentHeight/2-parentHeight/4),
  w = math.ceil(parentWidth/2), h = math.ceil(parentHeight/2),
  noWindow = false, noBar = false, noInteraction = false
}

local isUserEvent = function(event)
  for userEventNum = 1, #userEvents do
    local userEvent = userEvents[userEventNum]
    if event == userEvent then
      return true
    end
  end
end

return {
  updateProcess = function(self, processNum, event, var1, var2, var3)
    local process = self[processNum]
    -- check if process is still running, if not, remove it
    if coroutine.status(process.coroutine) == "dead" then
      table.remove(self, processNum)
    end

    -- redirect to process window and update it
    local oldTerm = term.redirect(process.term)
    coroutine.resume(process.coroutine)

    -- redirect to the old term and redraw the process window
    term.redirect(oldTerm)
    process.term.redraw()
  end,
  start = function(self, programName, event, var1, var2, var3)
    local programPath = "/programs/"..programName.."/"
    local width, height = term.getSize()
    local programProperties = {}

    if fs.exists(programPath.."properties.lua") then
      local programProperties = dofile(programPath.."properties.lua")
    end
    
    self:new(function() dofile(programPath.."init.lua") end, programProperties)
  end,
  new = function(self, func, properties)
    local process = {
      coroutine = coroutine.create(function()
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
      end),
      reposition = function(self, x, y)
        self.x, self.y = x, y
        self.term.reposition(x, y)
      end,
      resize = function(self, w, h)
        oldX, oldY = self.term.getPosition()
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
  update = function(self, event, var1, var2, var3)
    -- check if event is made from the user
    local userEvent = isUserEvent(event)

    -- update every program
    for processNum, process in ipairs(self) do
      self:updateProcess(processNum)
    end
  end
}
