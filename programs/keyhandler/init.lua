keyboard = {}

while true do
  local event, key = os.pullEvent()
  if event == "char" then
    keyboard.lastChar = key
  elseif event == "key" then
    keyboard[keys.getName(key)] = true
  elseif event == "key_up" then
    keyboard[key] = false
  end
end
