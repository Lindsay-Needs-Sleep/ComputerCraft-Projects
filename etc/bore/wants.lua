local blocks = require("/lib/blocks")

local name, tag, mtag = blocks.filter.name, blocks.filter.tag, blocks.filter.mtag

local mybase = {
  -- bedrock is always unmineable
  {false, name, "minecraft:bedrock"},

  -- liquids can't be mined
  {false, name, "minecraft:water"},
  {false, name, "minecraft:lava"},
  {false, name, "minecraft:flowing_water"},
  {false, name, "minecraft:flowing_lava"},

  -- don't mine inventories
  {false, name, "minecraft:.*chest"},
  {false, name, "minecraft:.*barrel"},
  {false, name, "minecraft:furnace"},
  {false, name, "minecraft:blast_furnace"},
  {false, name, "minecraft:smoker"},
}

return {
  defaultProfile = {
    default = true,
    table.unpack(mybase),
  },
  all = {
    default = true,
    table.unpack(mybase),
  },
  trees = {
    default = false,
    {true, tag, "minecraft:logs"},
    {true, tag, "minecraft:leaves"},
    table.unpack(mybase),
  },
  treesc = {
    default = false,
    {true, tag, "minecraft:logs"},
    {true, tag, "minecraft:leaves"},
    {true, name, "minecraft:stone"},
    table.unpack(mybase),
  },
  m = {
    default = true,

    -- common overworld
    {false, name, "minecraft:dirt"},
    {false, name, "minecraft:farmland"},
    {false, name, "minecraft:dirt_path"},
    {false, name, "minecraft:gravel"},
    {false, tag, "minecraft:sand"},
    {false, name, "minecraft:sandstone"},
    -- {false, tag, "minecraft:base_stone_overworld"}, -- stone, granite, tuff, deepslate, etc
    {false, name, "minecraft:stone"},
    {false, name, "minecraft:cobblestone"}, -- required for inventory checks
    {false, name, "minecraft:deepslate"},
    {false, name, "minecraft:cobbled_deepslate"},
    {false, name, "minecraft:tuff"},
    {false, name, "minecraft:andesite"},
    {false, name, "minecraft:diorite"},
    {false, name, "minecraft:granite"},

    -- common nether
    {false, name, "minecraft:netherrack"},
    -- {false, name, "minecraft:basalt"},
    {false, name, "minecraft:nether_wart_block"},
    {false, name, "minecraft:magma_block"},

    table.unpack(mybase),
  }
}
