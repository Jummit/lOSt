local w, h = term.native().getSize()
return {
  x = 1, y = 1,
  w = w, h = h,
  noBar = true, noInteraction = true
}
