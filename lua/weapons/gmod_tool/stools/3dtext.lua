TOOL.Category = "Construction"
TOOL.Name = "#tool.3dtext.name"

cleanup.Register("3dtext")

TOOL.ClientConVar["text"] = "Cool Text"

function TOOL:LeftClick(tr)
    if CLIENT then return true end

    local sign = ents.Create("3d_textscreen")
    local ang = tr.HitNormal:Angle()
    ang:RotateAroundAxis(tr.HitNormal:Angle():Right(), -90)
    ang:RotateAroundAxis(tr.HitNormal:Angle():Forward(), 90)
    sign:SetPos(tr.HitPos)
    sign:SetAngles(ang)
    sign:Spawn()
    sign:Activate()

    sign:SetNWString("SignText", self:GetClientInfo("text") or "Cool Text")
    return true
end

function TOOL:RightClick(tr)

end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
        Text = "#tool.3dtext.name",
        Description = "#tool.textscreen.desc"
    })

    local textbox = vgui.Create("DTextEntry")
    textbox:SetUpdateOnType(true)
    textbox:SetEnterAllowed(true)
    textbox:SetConVar("3dtext_text")
    textbox:SetValue(GetConVar("3dtext_text"):GetString())
    panel:AddItem(textbox)
end