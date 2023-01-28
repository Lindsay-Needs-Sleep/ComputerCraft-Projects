local arguments = require("/lib/args")
local bore = require("/lib/bore")
local location = require("/lib/location")
local path = require("/lib/path")

local args = arguments.parse({
    flags = { help = "boolean" },
    required = {
      { name = "clearance", type = "number" },
      { name = "forward", type = "number" },
      { name = "rightWidth", type = "number" },
    },
  },
  {...})

if args.help then
  print("To build stairs upwards, place turtle at bottom-most left step (assuming all positive values)")
  print("To build stairs downwards, use a negative clearance, and place turtle just below at the top-most, left ceiling block.")
  return
end

local dim = bore.dimensionsToVector(args.forward, args.clearance, args.rightWidth)

local startTime = os.clock()

local ops = {}
if args.clearance > 0 then
  ops.main = "Up"
  ops.reverse = "Down"
else
  ops.main = "Down"
  ops.reverse = "Up"
end
local clearing = ops.main --reset, main, reverse


local success, error = pcall(function()
  path.horizontalLayer(dim.x, dim.z, function (direction)
    -- ensure the stairs have a floor
    if clearing == "Up" then turtle.placeDown() end

    -- clear the column
    for i = 1, math.abs(dim.y), 1 do
      turtle["dig"..clearing]()
      turtle[string.lower(clearing)]()
    end

    -- ensure the stairs have a floor
    if clearing == "Down" then turtle.placeDown() end

    -- Switch the clearing for next column
    clearing = (clearing == ops.main and ops.reverse) or ops.main

    -- handle reseting to the right height for the next row
    if math.abs(location.getHeading().x) == 1 then
      if clearing == ops.reverse then
        for i = 1, math.abs(dim.y) - 1, 1 do
          turtle[string.lower(ops.reverse)]()
        end
      else
        turtle[string.lower(ops.main)]()
      end
      clearing = ops.main
    end

    -- Clear the way for the turtle to move forward
    turtle["dig"..direction]()

  end, true)
end)
if error then print(error) end

local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
