local userEvents = {"mouse_click", "mouse_up", "mouse_drag", "char", "key", "monitor_touch", "key_up", "paste", "terminate"}
local parentTerm = term.current()
local parentWidth, parentHeight = parentTerm.getSize()
local defaultProperties = {
  x = parentWidth/2-parentWidth/4,
  y = parentHeight/2-parentHeight/4,
  w = parentWidth/4, h = parentWidth/4,
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
  updateProcess = function(self, process)
    local oldTerm = term.redirect(process.term)
    coroutine.resume(process.coroutine)
    term.redirect(oldTerm)
  end,
  start = function(self, programName, event, var1, var2, var3)
    local programPath = "/programs/"..programName.."/"
    local width, height = term.getSize()
    local programProperties = {}

    if fs.exists(programPath.."properties.lua") then
      local programProperties = dofile(programPath.."properties.lua")
    end

    self:new(function() dofile(program) end, programProperties)
  end,
  new = function(self, func, properties)
    local process = {
      coroutine = coroutine.create(func),
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
      self:updateProcess(process)
    end
  end
}
