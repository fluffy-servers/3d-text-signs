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
    self:SetNWVector("Color", Vector(255, 255, 255))
end

if CLIENT then
    ENT.ClientsideModels = {}
    ENT.Invalid = false

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

        local lpos = Vector(0, 10, 0)
        local spacing = 5
        for i = 1, #text do
            local char = text:sub(i, i)

            local pos, ang = LocalToWorld(lpos, Angle(-90, 90, 0), self:GetPos(), self:GetAngles())
            local m = self:CreateLetterModel(font, char)
            self.ClientsideModels[i] = {m, lpos}

            local mins, maxs = m:GetModelBounds()
            if self:GetNWBool("Vertical", false) then
                 lpos = lpos + Vector(0, (maxs[2] - mins[2]) * 1.5, 0)
            else
                lpos = lpos + Vector((maxs[1] - mins[1]) * -4, 0, 0)
            end
        end

        return true
    end

    function ENT:Draw()
        self:DrawModel()
        if self.Invalid then return end

        local font = self:GetNWString("Font", "")
        local text = self:GetNWString("SignText", "")
        if font == "" or text == "" then return end

        local skin = self:GetNWInt("Skin", 0)
        local cvector = self:GetNWVector("Color", Vector(255, 255, 255))
        local color = Color(cvector[1], cvector[2], cvector[3])

        if #self.ClientsideModels != #text then
            self:CleanupClientsideModels()

            local valid = self:CreateClientsideModels(font, text)
            if not valid then return end
        end

        -- Update positions
        for i = 1, #text do
            local m = self.ClientsideModels[i][1]
            local lpos = self.ClientsideModels[i][2]

            local pos, ang = LocalToWorld(lpos, Angle(-90, 90, 0), self:GetPos(), self:GetAngles())
            m:SetPos(pos)
            m:SetAngles(ang)
            m:SetSkin(skin)
            m:SetColor(color)
        end
    end
end