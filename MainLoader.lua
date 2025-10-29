local SWILL = {
    Version = "2.0",
    Author = "krashlove",
    LastUpdate = "29.10.2025"
}

local AimBot = loadstring(game:HttpGet("https://raw.githubusercontent.com/krashlove/swill/main/AimBot.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/krashlove/swill/main/Movement.lua"))()
local Chilli = loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()

AimBot:Initialize()
Movement:Activate()
Chilli:Load()

warn("SWILL System Activated | krashlove edition")
return SWILL
