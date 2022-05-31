--Metal Saucer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.filtPoke,tp,LOCATION_MZONE,0,1,nil) 
        and Duel.IsExistingTarget(s.filtEn,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    Duel.SelectTarget(tp,s.filtPoke,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local te=Duel.GetMatchingGroup(s.filtEn, tp,LOCATION_GRAVE,0,nil):GetFirst()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Overlay(tc,Group.FromCards(te))
    end
end

function s.filtPoke(c)
    return c:GetSequence()<5 and c:IsRace(RACE_MACHINE)
end
function s.filtEn(c)
    return c:IsCode(999912048)
end