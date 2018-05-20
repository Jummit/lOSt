-- intended global, so every program can modify the processes
processes = require "apis.processes"
processes:start("autostart")

while true do
  -- update
  local event, var1, var2, var3 = os.pullEventRaw()
  term.setBackgroundColor(colors.white)
  term.clear()
  processes:update(processes, event, var1, var2, var3)
end
