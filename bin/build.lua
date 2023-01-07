local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")
local blueprint = require("/lib/blueprint")

--[[

Load a build file, and build
the structure, bottom up. Any blocks
in the way will be dug. One layer of
blocks above will also be dug, to give
the turtle the room it needs.

Each build file should be formatted in
the following way (replace <...> with
value, use symbols in blueprint):

  <width> <depth> <height>
  <symbol1>
  <symbol2>
  ...
  <symbolN>
  Blueprint:
  <blueprint goes here>

A blueprint must match the defined
width, depth, and height. Each layer is
separated by a new line. The build file
may look something like this (note: "."
is the symbol for nothing):

  4 3 2
  A Comment for A
  B Comment for B
  Blueprint:
  AAAA
  AAAA
  BAAA

  AAAA
  A..A
  AAAA

The starting location of the turtle
happends to coincide with the single
"B" block, but as a rule, the turtle
builds forward, right, and up. Note,
that the first layer is the bottom,
and the next layer is the top.

--]]

--[[
Read and return a blueprint
--]]
local function readBlueprint(fileName)
  local bp = blueprint.new()
  local lineNumber = 0
  local file = fs.open(fileName, "r")
  if not file
  then
    return nil
  end

  -- read dimensions
  local dimensions = file.readLine()
  lineNumber = lineNumber + 1
  local dimStrings = {}
  dimensions:gsub("%d+", function(i) table.insert(dimStrings, i) end)

  bp.width = tonumber(dimStrings[1])
  bp.depth = tonumber(dimStrings[2])
  bp.height = tonumber(dimStrings[3])

  local invSlot = 1
  -- read all symbol and slot pairs
  local symbolLine = nil
  bp.symbols = {}
  while true do
    symbolLine = file.readLine()
    lineNumber = lineNumber + 1

    if not symbolLine or symbolLine == "Blueprint:" then
      break
    end

    local symbol, comment = symbolLine:match("(.) (.*)")

    bp.symbols[symbol] = {
      slot = invSlot,
      comment = comment,
    }

    invSlot = invSlot + 1
  end

  -- read blueprint
  local blueprintLine = nil

  for y = 0, bp.height - 1 do
    for z = 0, bp.depth - 1 do
      blueprintLine = file.readLine()
      lineNumber = lineNumber + 1
      if not blueprintLine
      then
        error("at line " .. lineNumber .. ": number of lines in block does not match depth")
      elseif blueprintLine:len() ~= bp.width
      then
        error("at line " .. lineNumber .. ":" ..
          "\nline is not the same as <width>" ..
          "\nExpected: " .. bp.width ..
          "\nGot: " .. blueprintLine:len())
      end
      for x = 0, bp.width - 1 do
        local symbol = blueprintLine:sub(x + 1, x + 1)

        bp.blocks:set(symbol, x, y, z)
      end

    end
    -- read newline after block
    blueprintLine = file.readLine()
    lineNumber = lineNumber + 1
  end

  return bp
end

--[[

Build the blueprint, going forward,
to complete a line, right to do the
next lines and complete a plane, and
up to complete the next planes and
complete the structure

--]]
local function build(bp)
  local start = location.getPos()
  local forward = location.getHeading()
  turtle.turnRight()
  local right = location.getHeading()
  local up = vector.new(0, 1, 0)

  --print("init done")

  local invertX = false
  local invertZ = false
  local xi, yi, zi = 0, 0, 0

  for y = 0, bp.height - 1 do
    local yi = y
    for x = 0, bp.width - 1 do
      if invertX then
        xi = bp.width - 1 - x
      else
        xi = x
      end

      for z = 0, bp.depth - 1 do
        if invertZ then
          zi = bp.depth - 1 - z
        else
          zi = z
        end

        -- move to location above block
        local buildPos = start + (forward * zi) + (right * xi) + (up * (yi + 1))
        move.digTo(buildPos)

        -- remove block underneath
        turtle.digDown()

        -- select correct inventory slot
        local block = bp.blocks:get(xi, yi, zi)

        if block ~= nil and block ~= blueprint.AIR then
          local slot = bp.symbols[block].slot
          turtle.select(slot)

          -- place a block down
          while not turtle.placeDown() do turtle.digDown() end
        end
      end -- end z
      -- we are on the other side, so
      -- switch directions
      invertZ = not invertZ

    end -- end x
    -- we are on the other side, so
    -- switch directions
    invertX = not invertX
  end -- end y
end

-- First, let's turn autofill on
local initAutoRefill = inventory.getAutoRefill()
inventory.setAutoRefill(true)

-- Now, let's see what file we're
-- using
local args = { ... }
if #args ~= 1
then
  print("Usage: <fileName>")
  return
end

local fileName = args[1]
local bp = readBlueprint(fileName)

if not bp then
  error("Unable to read blueprint "..fileName)
end

print("Loaded blueprint:")
print("  width=  " .. bp.width + 1)
print("  depth=  " .. bp.depth + 1)
print("  height= " .. bp.height + 1)
print("  inventory:")
local counts = bp:counts()
local i = 1
while i <= 16 do
  for symbol, info in pairs(bp.symbols) do
    if info.slot == i then
      local text = "    " .. symbol .. "->" .. info.slot .. " " .. info.comment
        .. " x" .. counts[symbol]

      if counts[symbol] > 64 then
        text = text .. " ("
          .. math.floor(counts[symbol] / 64) .. "x64 + "
          .. counts[symbol] % 64
        .. ")"
      end

      print(text)
      break
    end
  end
  i = i + 1
end

-- wait for user confirmation
print("Press any key to continue...")
os.pullEvent("key")

-- now, let's build
build(bp)

-- Let's turn autorefill to its
-- previous setting.
inventory.setAutoRefill(initAutoRefill)
