-- Handles tilling, seeding and harvesting of a flat farm field
-- Simple crops only (wheat, carrots, potatoes, beets)

local arguments = require("/lib/args")
local bore = require("/lib/bore")
local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")
local blocks = require("/lib/blocks")

local args = arguments.parse({
  flags = {
    help = "boolean",
  },
  required = {
    { name = "forward", type = "number" },
    { name = "right", type = "number" },
  },
  optional = {
    { name = "placeDirection", type = "string" }
  }
},
{...})

if args.help then
  print("Leave at least 1 item of the planting ingredient in slot #1")
  return
end

local dimensionVector = bore.dimensionsToVector(args.forward, 1, args.right)

local startPos = location.getPos()
local startHeading = location.getHeading()

bore.setChest(startPos)
bore.setReservedSlots({[1] = true})
inventory.setAutoRefill(true)
local plantingSlot = 1 -- slot 1 should stay full
turtle.select(plantingSlot)

local success, error = pcall(function()
  path.rectangleSimple(dimensionVector, function (direction)

    if turtle.getSelectedSlot() ~= plantingSlot then turtle.select(plantingSlot) end
    if turtle.getItemCount() == 0 then error("Ran out of items to place") end
    bore.fuelAndInventoryCheck(startPos, startHeading)
    local found, block = turtle.inspectDown()
    if not found or blocks.isSimpleCrop(block) and blocks.isHarvestable(block) then
      turtle.digDown() -- till or harvest
    end
    turtle.placeDown() -- attempt planting

  end)
end)
if error then print(error) end

move.goTo(startPos)
move.turnTo(startHeading)
bore.transferToChest()
