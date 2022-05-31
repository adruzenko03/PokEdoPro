--Rotom Phone
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
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)~=0 end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local topCount=5
	local deckCount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deckCount<topCount then 
		topCount=deckCount
	end
	Duel.DisableShuffleCheck()
	local g=Duel.GetDecktopGroup(tp,topCount)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg=g:Select(tp,1,1,nil)--,topCount,nil
    Duel.ShuffleDeck(tp)
    Duel.MoveToDeckTop(sg)
end
