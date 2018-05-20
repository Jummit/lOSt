-- clear screen white as quick as possible
term.setBackgroundColor(colors.white)
term.clear()

-- intended global, so every program can modify the processes
processes = require "apis.processes"
processes:start("autostart")

while true do
  -- update
  local timer = os.startTimer(0.001)
  local event, var1, var2, var3 = os.pullEventRaw()
  os.cancelTimer(timer)
  
  if var1 ~= timer then
    processes:update(processes, event, var1, var2, var3)
  end
end
