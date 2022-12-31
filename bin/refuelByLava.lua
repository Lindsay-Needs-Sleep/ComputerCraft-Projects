-- Turtle must have an empty bucket, it will run above
-- lava-filled-cauldrons (or a lava lake) and collect+eat the lava

local arguments = require("/lib/args")
local bore = require("/lib/bore")
local bucket = require("/lib/bucket")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")

local args = arguments.parse({
  required = {
    { name = "forward", type = "number" },
    { name = "right", type = "number" },
  },
},
{...})

local dimensionVector = bore.dimensionsToVector(args.forward, 1, args.right)

local startPos = location.getPos()
local startHeading = location.getHeading()

local bucketSlot = bucket.find()
if bucketSlot < 1 then error("Turtle needs a bucket") end
turtle.select(bucketSlot)

print("Starting fuel level: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())

local success, error = pcall(function()
  path.rectangleSimple(dimensionVector, function (direction)

    turtle.placeDown()
    turtle.refuel()
    if turtle.getFuelLevel() == turtle.getFuelLimit() then error("Reached Maximum Fuel") end

  end)
end)
if error then print(error) end

move.goTo(startPos)
move.turnTo(startHeading)
if turtle.getFuelLevel() >= turtle.getFuelLimit() - 100 then
  turtle.back()
  turtle.back()
end

print("Fuel level: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
