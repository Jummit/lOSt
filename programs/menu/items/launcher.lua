local programs = {
  {
    exec = "worm",
    icon = {"\141\136", "de", "ff"}
  },
  {
    exec = "paint image",
    icon = {"\152\135", "ce", "ff"}
  },
  {
    exec = "edit text",
    icon = {"ed", "44", "ff"}
  }
}

return {
  w = 10,
  update = function(event, var1, var2, var3)
    for programNum, program in ipairs(programs) do

      if event == "mouse_click" and var3 == 1 and (var2 == (programNum-1)*3+1 or var2 == (programNum-1)*3+2) then
        processes:run(program.exec)
      end
      term.blit(program.icon[1], program.icon[2], program.icon[3])
      term.write(" ")
    end
  end
}
