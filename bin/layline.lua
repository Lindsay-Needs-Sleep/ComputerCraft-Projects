local arguments = require("/lib/args")
local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")

local args = arguments.parse({
  flags = {
    wants = "string",
    help = "boolean",
  },
  required = {
    { name = "forward", type = "number" },
    { name = "right", type = "number" },
    -- { name = "width", type = "number" },
  },
  optional = {
    { name = "goHome", type = "boolean" }
  }
},
{...})

if args.help then
  print("Will place whatever block is in the inventory 'up' or 'down'")
  return
end

inventory.setAutoRefill(true)
local slot = 1
turtle.select(slot)


local startPos = location.getPos()
local startHeading = location.getHeading()

local success, error = pcall(function()
  path.horizontalDiagLine(args.forward, args.right, function ()
    turtle.digDown()

    while turtle.getItemCount() == 0 and slot < 16 do
      slot = slot + 1
      turtle.select(slot)
    end
    if turtle.getItemCount() == 0 then error("Ran out of items to place") end
    turtle.placeDown()
    return true

  end)
end)
if error then print(error) end

if (args.goHome) then
  move.goTo(startPos)
  move.turnTo(startHeading)
end
