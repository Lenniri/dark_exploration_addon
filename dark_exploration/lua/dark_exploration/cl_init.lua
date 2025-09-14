-- Initialize darkness
net.Receive("DarkExp_InitDarkness", function()
    hook.Add("RenderScreenspaceEffects", "DarkExp_DarknessEffect", function()
        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.5,
            ["$pp_colour_contrast"] = 1.2,
            ["$pp_colour_colour"] = 0.3,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
        
        DrawMotionBlur(0.1, 0.8, 0.01)
    end)
end)

-- Weapon found effect
net.Receive("DarkExp_WeaponFound", function()
    local weapon = net.ReadString()
    
    -- Flash effect
    surface.PlaySound("items/itempickup.wav")
    
    -- Notification
    chat.AddText(Color(0, 255, 0), "Weapon Found: ", Color(255, 255, 255), weapon:sub(8))
end)

-- Sound event notification
net.Receive("DarkExp_SoundEvent", function()
    local pos = net.ReadVector()
    
    -- Play distant sound effect
    surface.PlaySound("ambient/voices/mumble.wav")
    
    -- Direction indicator (simplified)
    chat.AddText(Color(255, 100, 100), "You hear a strange noise in the distance...")
end)

-- Cheat detection feedback
net.Receive("DarkExp_CheatDetected", function()
    local count = net.ReadUInt(3)
    
    if count == 1 then
        chat.AddText(Color(255, 0, 0), "Cheating detected! This is your first warning.")
    else
        chat.AddText(Color(255, 0, 0), "Cheating detected again! You will be kicked.")
    end
end)

-- Use key detection for searching
local nextSearch = 0
hook.Add("KeyPress", "DarkExp_SearchKey", function(ply, key)
    if key ~= IN_USE or CurTime() < nextSearch then return end
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Check if player is looking at something searchable
    local trace = ply:GetEyeTrace()
    if trace.Hit and trace.HitPos:Distance(ply:GetPos()) < 100 then
        net.Start("DarkExp_PlayerSearch")
        net.SendToServer()
        
        nextSearch = CurTime() + 2 -- Cooldown
    end
end)

-- Lambda symbol detection
hook.Add("PostDrawOpaqueRenderables", "DarkExp_LambdaDetection", function()
    for _, ent in pairs(ents.FindByModel(DARK_EXPLORATION.CONFIG.LambdaSymbol)) do
        if IsValid(ent) then
            -- Draw glow effect
            render.SetColorMaterial()
            render.DrawSphere(ent:GetPos(), 50, 30, 30, Color(0, 255, 0, 100))
            
            -- Check if player is close
            local ply = LocalPlayer()
            if IsValid(ply) and ply:GetPos():Distance(ent:GetPos()) < 150 then
                if not ent.DarkExp_Triggered then
                    net.Start("DarkExp_LambdaRequest")
                    net.WriteVector(ent:GetPos())
                    net.SendToServer()
                    
                    ent.DarkExp_Triggered = true
                    chat.AddText(Color(0, 255, 0), "You found a mysterious symbol... A room appears!")
                end
            end
        end
    end
end)

-- Notification system
net.Receive("DarkExp_Notification", function()
    local msg = net.ReadString()
    chat.AddText(Color(200, 200, 0), msg)
end)