--Marnie
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local s=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)+Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
	if e:GetHandler():IsLocation(LOCATION_HAND) then
		s=s-1
	end
	if chk==0 then
		return (s~=0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local g2=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	Duel.SendtoDeck(g1:Clone():Merge(g2), nil, SEQ_DECKBOTTOM, REASON_EFFECT)
	while (#g1>0) do
		dg=g1:TakeatPos(Duel.GetRandomNumber(g1:GetCount()-1))
		g1:Sub(dg)
		Duel.MoveSequence(dg,SEQ_DECKBOTTOM)
	end
	while (#g2>0) do
		dg=g2:TakeatPos(Duel.GetRandomNumber(g2:GetCount()-1))
		g2:Sub(dg)
		Duel.MoveSequence(dg,SEQ_DECKBOTTOM)
	end

    local s1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local s2=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)

    if s1>5 then
        s1=5
    end
	if s2>4 then
        s2=4
    end
	Duel.BreakEffect()
	Duel.Draw(tp,s1,REASON_EFFECT)
	Duel.Draw(1-tp,s2,REASON_EFFECT)
end