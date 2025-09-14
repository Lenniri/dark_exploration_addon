util.AddNetworkString("DarkExp_WeaponFound")
util.AddNetworkString("DarkExp_SoundEvent")
util.AddNetworkString("DarkExp_LambdaFound")
util.AddNetworkString("DarkExp_CheatDetected")

-- Initialize players
hook.Add("PlayerInitialSpawn", "DarkExp_PlayerInit", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            -- Strip all weapons
            ply:StripWeapons()
            ply:SetHealth(100)
            
            -- Send darkness effect
            net.Start("DarkExp_InitDarkness")
            net.Send(ply)
            
            -- Instructions
            DarkExp_SendNotification(ply, "You awaken in darkness... Find your weapons to survive.")
            DarkExp_SendNotification(ply, "Search your surroundings with +USE (E key) to find items.")
        end
    end)
end)

-- Handle player searching for weapons
function DarkExp_PlayerSearch(ply)
    if not IsValid(ply) then return end
    
    -- Check if player already has max weapons
    local weaponCount = 0
    for _, wep in pairs(ply:GetWeapons()) do
        weaponCount = weaponCount + 1
    end
    
    if weaponCount >= DARK_EXPLORATION.CONFIG.MaxWeapons then
        DarkExp_SendNotification(ply, "You cannot carry more weapons.")
        return
    end
    
    -- Chance to find weapon
    if math.random() <= DARK_EXPLORATION.CONFIG.WeaponSpawnChance then
        local weapon = table.Random(DARK_EXPLORATION.WEAPONS)
        ply:Give(weapon)
        
        net.Start("DarkExp_WeaponFound")
        net.WriteString(weapon)
        net.Send(ply)
        
        DarkExp_SendNotification(ply, "You found a " .. weapon:sub(8) .. "!")
    else
        DarkExp_SendNotification(ply, "You found nothing... Keep searching.")
    end
end

-- Create sound events
function DarkExp_CreateSoundEvent()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            -- Get random position away from player
            local offset = Vector(
                math.random(-1000, 1000),
                math.random(-1000, 1000),
                math.random(200, 500)
            )
            
            local soundPos = ply:GetPos() + offset
            local sound = table.Random(DARK_EXPLORATION.SOUNDS)
            
            -- Create falling prop
            local prop = ents.Create("prop_physics")
            if IsValid(prop) then
                prop:SetModel(table.Random(DARK_EXPLORATION.LAMBDA_OBJECTS))
                prop:SetPos(soundPos)
                prop:Spawn()
                
                -- Apply random force
                local phys = prop:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(Vector(0, 0, -phys:GetMass() * 500))
                end
                
                -- Play sound
                sound.Play(sound, soundPos)
                
                -- Remove after time
                timer.Simple(30, function()
                    if IsValid(prop) then prop:Remove() end
                end)
                
                -- Notify player
                net.Start("DarkExp_SoundEvent")
                net.WriteVector(soundPos)
                net.Send(ply)
            end
        end
    end
    
    -- Schedule next event
    timer.Create("DarkExp_SoundTimer", math.random(
        DARK_EXPLORATION.CONFIG.SoundEventInterval.min,
        DARK_EXPLORATION.CONFIG.SoundEventInterval.max
    ), 1, DarkExp_CreateSoundEvent)
end

-- Start sound events after a delay
timer.Simple(60, DarkExp_CreateSoundEvent)

-- Lambda symbol handler
function DarkExp_CreateLambdaRoom(pos)
    local lambda = ents.Create("prop_physics")
    if IsValid(lambda) then
        lambda:SetModel(DARK_EXPLORATION.CONFIG.LambdaSymbol)
        lambda:SetPos(pos)
        lambda:Spawn()
        
        -- Make it non-physical but visible
        lambda:SetMoveType(MOVETYPE_NONE)
        lambda:SetSolid(SOLID_NONE)
        
        -- Glowing effect
        lambda:SetColor(Color(0, 255, 0))
        lambda:SetMaterial("models/debug/debugwhite")
        
        -- Create room around it
        for i = 1, math.random(5, 10) do
            local obj = ents.Create("prop_physics")
            if IsValid(obj) then
                obj:SetModel(table.Random(DARK_EXPLORATION.LAMBDA_OBJECTS))
                obj:SetPos(pos + Vector(
                    math.random(-300, 300),
                    math.random(-300, 300),
                    math.random(-50, 50)
                ))
                obj:SetAngles(Angle(
                    math.random(0, 360),
                    math.random(0, 360),
                    math.random(0, 360)
                ))
                obj:Spawn()
                
                -- Create dead NPCs
                if math.random() < 0.3 then
                    local npc = ents.Create("npc_citizen")
                    if IsValid(npc) then
                        npc:SetModel("models/humans/group01/male_0" .. math.random(1, 9) .. ".mdl")
                        npc:SetPos(pos + Vector(
                            math.random(-200, 200),
                            math.random(-200, 200),
                            10
                        ))
                        npc:Spawn()
                        npc:SetHealth(0) -- Dead
                    end
                end
            end
        end
        
        return lambda
    end
end

-- Cheat detection
hook.Add("PlayerNoClip", "DarkExp_NoClipDetect", function(ply, desiredState)
    if desiredState then -- Trying to enable noclip
        DarkExp_PunishCheater(ply, "noclip")
        return false -- Prevent noclip
    end
end)

-- Spawn menu protection
local oldSpawnFunction = ents.Create
ents.Create = function(class, ...)
    if class and class ~= "predicted_viewmodel" then
        for _, ply in pairs(player.GetAll()) do
            if ply:IsValid() and ply:GetInfo("cl_showspawnmenu") == "1" then
                DarkExp_PunishCheater(ply, "spawnmenu")
                break
            end
        end
    end
    return oldSpawnFunction(class, ...)
end

-- Cheat punishment system
function DarkExp_PunishCheater(ply, cheatType)
    if not ply.DarkExp_CheatCount then
        ply.DarkExp_CheatCount = 0
    end
    
    ply.DarkExp_CheatCount = ply.DarkExp_CheatCount + 1
    
    if ply.DarkExp_CheatCount == 1 then
        -- First offense: kill player
        ply:Kill()
        DarkExp_SendNotification(ply, "Cheating is not allowed! You have been warned.")
    elseif ply.DarkExp_CheatCount >= 2 then
        -- Second offense: kick from server
        ply:Kick("Cheating detected in Dark Exploration mode")
    end
    
    net.Start("DarkExp_CheatDetected")
    net.WriteUInt(ply.DarkExp_CheatCount, 3)
    net.Send(ply)
end

-- Helper function for notifications
function DarkExp_SendNotification(ply, msg)
    net.Start("DarkExp_Notification")
    net.WriteString(msg)
    net.Send(ply)
end

-- Network messages
net.Receive("DarkExp_PlayerSearch", function(len, ply)
    DarkExp_PlayerSearch(ply)
end)

net.Receive("DarkExp_LambdaRequest", function(len, ply)
    local pos = net.ReadVector()
    DarkExp_CreateLambdaRoom(pos)
end)