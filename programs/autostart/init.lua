local config = require "programs.autostart.config"
for _, programName in ipairs(config) do
  processes:start(programName)
end
term.setBackgroundColor(colors.white)
term.clear()
