-- intended global, so every program can modify the processes
processes = require "apis.processes"
local autostart = require "programs.autostart"

autostart()

while true do
  -- update
  local event, var1, var2, var3 = os.pullEventRaw()
  processes:update(processes, event, var1, var2, var3)

end
