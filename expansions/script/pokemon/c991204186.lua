--Aurora Energy
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	pokeutil.energyAttach(c,s.condition,s.cost)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=1 end
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>ct
end	