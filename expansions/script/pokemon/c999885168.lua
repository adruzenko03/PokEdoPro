--Tool Scrapper
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(s.filt,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local g=Duel.SelectTarget(tp,s.filt,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    for c in g:Iter() do 
        og=c:GetOverlayGroup():Filter(Card.IsSetCard,nil,0x720)
        if og:GetCount()==1 then
           Duel.SendtoGrave(og:GetFirst(), REASON_EFFECT)
        else
            Duel.SendtoGrave(og:Select(tp,val,val,nil), REASON_EFFECT)
        end
    end
end

function s.filt(c)
    return c:GetOverlayGroup():FilterCount(Card.IsSetCard,nil,0x720)~=0
end
