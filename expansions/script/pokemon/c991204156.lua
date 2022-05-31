--Air Balloon
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	pokeutil.toolAttach(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(-2)
	c:RegisterEffect(e1)
end