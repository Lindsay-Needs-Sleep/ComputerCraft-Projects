-- Place inbetween the 2 animals you want to breed, and load the inventory with the breeding material

local inventory = require("/lib/inventory")

local args = require("/lib/args").parse({
  flags = {
    help = "boolean",
  },
},
{...})

if args.help then
  print("Place inbetween the 2 animals you want to breed, and load the inventory with the breeding material")
  return
end

inventory.setAutoRefill(true)
local slot = 1 -- slot 1 should stay full
turtle.select(slot)

while true do
  if turtle.getItemCount() <= 1 then error("Insufficient breeding items") end
    print("Breeding")
    turtle.place()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.place()
    print("Waiting 5 minutes")
    os.sleep(60*5+5)
  end
