-- Dark Exploration Addon for GMod
-- Version 1.0
-- Creates a mysterious, dark experience on any HL2 map

if SERVER then
    AddCSLuaFile("dark_exploration/shared.lua")
    AddCSLuaFile("dark_exploration/cl_init.lua")
    include("dark_exploration/shared.lua")
    include("dark_exploration/sv_init.lua")
else
    include("dark_exploration/shared.lua")
    include("dark_exploration/cl_init.lua")
end