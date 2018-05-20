-- intended global, so every program can modify the processes
processes = require "apis.processes"
processes:start("init")

while true do
  term.setBackgroundColor(colors.white)
  term.clear()
  -- update
  local event, var1, var2, var3 = os.pullEventRaw()
  processes:update(processes, event, var1, var2, var3)
end
