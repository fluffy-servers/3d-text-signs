TOOL.Category = "Construction"
TOOL.Name = "#tool.3dtext.name"

cleanup.Register("3dtext")

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

    return true
end

function TOOL:RightClick(tr)

end