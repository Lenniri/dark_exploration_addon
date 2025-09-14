-- Weapon for searching (visible in spawn menu but not actually used)
SWEP.PrintName = "Search Tool"
SWEP.Author = "Dark Exploration"
SWEP.Purpose = "Search your surroundings for weapons"
SWEP.Instructions = "Press PRIMARY ATTACK to search"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Dark Exploration"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""

function SWEP:PrimaryAttack()
    if CLIENT then return end
    net.Start("DarkExp_PlayerSearch")
    net.SendToServer()
    self:SetNextPrimaryFire(CurTime() + 2)
end

function SWEP:SecondaryAttack()
    -- Do nothing
end