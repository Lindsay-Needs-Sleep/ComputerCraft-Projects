local args = {...}

if _G and _G._turtle and _G._turtle[args[1]] then
    print("using global _G._turtle."..args[1].."()")
    _G._turtle[args[1]]()
else
    print("using turtle."..args[1].."()")
    turtle[args[1]]()
end
