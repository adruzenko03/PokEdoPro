--Crystal Cave
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(pokeutil.stadcon)
	c:RegisterEffect(e1)
	--Heal
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filt,tp,LOCATION_MZONE,0,1,nil) end
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    sg=Duel.GetMatchingGroup(s.filt,tp,LOCATION_MZONE,0,nil)
    for c in sg:Iter() do
        remcount=3
        count=c:GetCounter(0x1300)
        if count<remcount then
            remcount=count
        end
        c:RemoveCounter(tp, 0x1300, remcount, REASON_ADJUST)
    end
end

function s.filt(c)
    return c:GetCounter(0x1300)~=0 and (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_DRAGON))
end