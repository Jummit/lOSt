local updateProgram = function(programs, programNum, event, var1, var2, var3, isUserEvent)
  local program = programs[programNum]
  local event, var1, var2, var3 = event, var1, var2, var3

  -- redirect to programs terminal
  local oldTerm = term.redirect(program.term)

  -- give the mouse click as seen from the program window
  if string.sub(event, 1, #"mouse") == "mouse" then
    var2 = var2-program.x+1
    var3 = var3-program.y+1
  end

  -- find out if the program window is clicked
  if event == "mouse_click" and var2>=0 and var3>=0 and var2<=program.w and var3<=program.h then
    -- select this program and deselect every other one
    for programNum = 1, #programs do
      programs[programNum].selected = false
    end
    program.selected = true
    if var3 == 0 then
      if program.barSelectedTime and os.clock()-program.barSelectedTime<0.2 then
        if program.big then
          program.big = false
          program:reset(program.oldX, program.oldY, program.oldW, program.oldH)
        else
          program.oldW, program.oldH = program.term.getSize()
          program.oldX, program.oldY = program.term.getPosition()
          local w, h = parentTerm.getSize()
          program:reset(1, 3, w, h-2)
          program.big = true
        end
      end
      program.barSelectedTime = os.clock()
      program.barSelected = true
      program.barSelectedX = var2
      if var2 == 1 then
        program.resizeIconSelected = true
      end
      if var2 == program.w then
        table.remove(programs, programNum)
        term.redirect(oldTerm)
        return true
      end
    end

    -- resort program table

    local selectedProgram
    for i = 1, #programs do
      if programs[i].selected then
        selectedProgram = programs[i]
        table.remove(programs, i)
        break
      end
    end
    table.insert(programs, selectedProgram)
  end

  -- move window when mouse is dragged
  if event == "mouse_drag" and program.barSelected then
    if program.resizeIconSelected then
      program:reset(program.x + var2-program.barSelectedX, program.y+var3, program.w-var2+1, program.h-var3)
    else
      program:reposition(program.x + var2-program.barSelectedX, program.y+var3)
    end
  end

  -- deselect bar if mouse is released
  if event == "mouse_up" then
    program.barSelected = false
    program.resizeIconSelected = false
  end

  -- only give program user events if selected
  if isUserEvent and not program.selected then
    event, var1, var2, var3 = ""
  end

  -- resume program
  coroutine.resume(program.coroutine, event, var1, var2, var3)

  -- delete program if it is finished
  if coroutine.status(program.coroutine) == "dead" then
    table.remove(programs, programNum)
    term.redirect(oldTerm)
    return true
  end

  program.term.redraw()
  term.redirect(oldTerm)

  -- draw line above program
  if program.selected then
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.gray)
  else
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lightGray)
  end
  paintutils.drawLine(program.x, program.y-1, program.x+program.w-1, program.y-1)

  -- draw resize icon
  term.setCursorPos(program.x, program.y-1)
  term.write("/")

  -- draw close icon
  term.setCursorPos(program.x+program.w-1, program.y-1)
  term.setTextColor(colors.orange)
  term.write("x")
end

return {
  new = function(self, func, x, y, w, h)
    local x = x or 1
    local y = y or 1
    local w = w or widht
    local h = h or height
    local program = {
      x = x, y = y, w = w, h = h,
      term = window.create(
        parentTerm, x, y, w, h
      ),
      selected = false,
      coroutine = coroutine.create(func),
      reposition = function(self, x, y)
        self.x, self.y = x, y
        self.term.reposition(x, y)
      end,
      resize = function(self, w, h)
        oldX, oldY = self.term.getPosition()
        self.term.reposition(oldX, oldY, w, h)
        os.queueEvent("term_resize")
      end,
      reset = function(self, x, y, w, h)
        self.big = false
        self.x, self.y, self.w, self.h = x, y, w, h
        self.term.reposition(x, y, w, h)
        os.queueEvent("term_resize")
      end
    }
    table.insert(self, program)
  end,
  update = function(self, event, var1, var2, var3)
    -- check if event is made from the user
    local isUserEvent = false
    for userEventNum = 1, #userEvents do
      local userEvent = userEvents[userEventNum]
      if event == userEvent then
        isUserEvent = true
        break
      end
    end

    -- update every program
    for programNum = 1, #programs do
      local x, y = programs[programNum].term.getPosition()
      if updateProgram(programs, programNum, event, var1, var2, var3, isUserEvent) then break end
    end
  end
}
