return {
  w = 5,
  update = function()
    term.write(textutils.formatTime(os.time()))
  end
}
