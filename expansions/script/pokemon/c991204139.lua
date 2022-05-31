--Zamazenta V (Sword & Shield)
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_END)
	e2:SetCondition(s.immcon)
	e2:SetOperation(s.immop)
	c:RegisterEffect(e2)
	--Assault Tackle
	pokeutil.InitAtk(c,id,1,"MMN",13,nil,nil,nil,s.atop)

	pokeutil.InitRetreat(c,id)

	pokeutil.InitWeakRes(c,RACE_PYRO,"*",2,RACE_PLANT,"-",3)
end

function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==eg:GetFirst() and re:GetHandler():IsSetCard(0x1750)
end

function s.immop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1300,ev,REASON_ADJUST)

end

function s.atop(e,tp,eg,ep,ev,re,r,rp,tg)
	local overlay=tg:GetFirst():GetOverlayGroup():Filter(Card.IsSetCard,nil,0x2700)
	if(overlay:GetCount()~=0) then
		local g=overlay:Select(tp,1,1,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end

end

function s.filter(c)
	return c:IsCode(999912048)
end

function s.atlimit(e,re)
	return e:GetHandler()==re:GetHandler() and re:IsHasCategory(CATEGORY_DAMAGE)
end
