local itemNames = fs.list("/programs/menu/items")
local items = {}
local nextX = 2

for _, itemName in ipairs(itemNames) do
  local itemFunc = loadfile("/programs/menu/items/"..itemName, _ENV)
  local item = itemFunc()
  local itemWindow = window.create(term.current(), nextX, 1, item.w, 1)

  table.insert(items, {
    term = itemWindow,
    update = function(self, event, var1, var2, var3)
      local oldTerm = term.redirect(self.term)

      term.setBackgroundColor(colors.gray)
      term.setTextColor(colors.black)
      term.clear()
      term.setCursorPos(1, 1)
      item.update(event, var1, var2, var3)

      term.redirect(oldTerm)
    end
  })

  nextX = nextX+item.w+1
end

while true do
  local event, var1, var2, var3 = os.pullEvent()


  term.setBackgroundColor(colors.gray)
  term.clear()
  term.setCursorPos(1, 1)
  for _, item in ipairs(items) do
    local var1, var2, var3 = var1, var2, var3

    if string.sub(event, 1, #"mouse") == "mouse" then
      local x, y = item.term.getPosition()
      var2 = var2-x+1
      var3 = var3-y+1
    end
    item:update(event, var1, var2, var3)
  end
end
