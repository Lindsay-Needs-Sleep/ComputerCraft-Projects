local args = {...}

if #args ~= 0 then
  print("Usage: red")
  return
end

print("hold ctrl+T to end")

turtle.select(1)

while true do
  os.pullEvent("redstone")
  turtle.dig()
  turtle.place()
  os.pullEvent("redstone")
end
