local succ, mess = pcall(function()
-- intended global, so every program can modify the processes
processes = require "apis.processes"
processes:start("autostart")

while true do
  -- update
  local timer = os.startTimer(0.001)
  local event, var1, var2, var3 = os.pullEventRaw()
  os.cancelTimer(timer)

  --if var1 ~= timer then
    processes:update(event, var1, var2, var3)
  --end
end
end)

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
if not succ and mess then
  term.setTextColor(colors.orange)
  print(mess)
end
