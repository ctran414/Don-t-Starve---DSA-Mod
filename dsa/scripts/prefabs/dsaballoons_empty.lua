local assets =
{
	Asset("ANIM", "anim/balloons_empty.zip"),
	--Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{
	"balloon",
}    

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("balloons_empty")
    anim:SetBuild("balloons_empty")
    anim:PlayAnimation("idle")
    MakeInventoryPhysics(inst)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "balloons_empty.png" )
    
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("balloons_empty")
    -----------------------------------
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "balloons_empty"
	
    inst:AddComponent("balloonmaker")
    return inst
end

return Prefab( "common/dsaballoons_empty", fn, assets, prefabs) 
