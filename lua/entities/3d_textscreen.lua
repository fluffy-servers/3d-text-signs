AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "3D Text Sign"
ENT.Author = "Fluffy Servers"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    if CLIENT then return end

    self:SetRenderMode(RENDERMODE_NORMAL)
    self:DrawShadow(false)
    self:SetModel("models/hunter/plates/plate1x1.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    self:SetNWString("SignText", "FLUFFY")
    self:SetNWString("Font", "roboto")
    self:SetNWBool("Vertical", false)
end

if CLIENT then
    ENT.ClientsideModels = {}
    ENT.Invalid = false
    ENT.BaseAngle = Angle(0, 0, 0)

    function ENT:OnRemove()
        self:CleanupClientsideModels()
    end

    function ENT:CleanupClientsideModels()
        for _, v in pairs(self.ClientsideModels) do
            v[1]:Remove()
        end

        self.ClientsideModels = {}
    end

    function ENT:CreateLetterModel(font, letter)
        -- Only create letters for valid text
        if not string.find(letter, "%w") then return end

        local m = ClientsideModel("models/alphabet/" .. font .. "/small_" .. letter .. ".mdl")
        return m
    end

    function ENT:CreateClientsideModels(font, text)
        -- Check if the font is installed or not
        if not file.Exists("models/alphabet/" .. font, "GAME") then
            self.Invalid = true
            return false
        end

        local lpos = Vector(0, -10, 2)
        local spacing = 5
        local current = 1
        for i = 1, #text do
            local pos, ang = LocalToWorld(lpos, Angle(-90, -90, 0), self:GetPos(), self:GetAngles())
            local m = self:CreateLetterModel(font, text:sub(i, i))
            if not IsValid(m) then
                lpos = lpos + Vector(12, 0, 0)
                continue
            end
            self.ClientsideModels[current] = {m, lpos}

            local mins, maxs = m:GetModelBounds()
            if self:GetNWBool("Vertical", false) then
                lpos = lpos + Vector(0, (maxs[2] - mins[2]) * 1.5, 0)
            else
                lpos = lpos + Vector((maxs[1] - mins[1]) * 4, 0, 0)
            end

            current = current + 1
        end

        return true
    end

    function ENT:Draw()
        if self.Invalid then return end

        local font = self:GetNWString("Font", "")
        local text = self:GetNWString("SignText", "")
        if font == "" or text == "" then return end

        local skin = self:GetNWInt("Skin", 0)
        local color = self:GetColor()

        if #self.ClientsideModels != #text then
            self:CleanupClientsideModels()

            local valid = self:CreateClientsideModels(font, text)
            if not valid then return end
        end

        -- Update positions if we've moved the base
        if not self.LastPos or self:GetPos() != self.LastPos then
            for _, v in pairs(self.ClientsideModels) do
                local m = v[1]
                local lpos = v[2]

                local pos, ang = LocalToWorld(lpos, Angle(-90, -90, 0), self:GetPos(), self:GetAngles())
                m:SetPos(pos)
                m:SetAngles(ang)
                m:SetSkin(skin)
                m:SetColor(color)
            end

            self.LastPos = self:GetPos()
        end
    end
end