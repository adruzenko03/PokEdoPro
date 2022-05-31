--Cape of Toughness
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	pokeutil.toolAttach(c)--Add cond to not attach to GX also test
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.condition)
	e1:SetValue(50)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLevelBelow(4) and not e:GetHandler():IsSetCard(0x749)
end