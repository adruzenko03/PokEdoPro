--Raihan
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetTurnPlayer()
    for tc in aux.Next(eg) do
        if tc:GetOwner()==1-p then
			Duel.RegisterFlagEffect(1-p,id,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
        end
    end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)~=0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.filtPoke,tp,LOCATION_MZONE,0,1,nil) 
        and Duel.IsExistingTarget(s.filtEn,tp,LOCATION_GRAVE,0,1,nil) end 
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
    local g=Duel.GetMatchingGroup(s.filtEn, tp,LOCATION_GRAVE,0,nil)
    local sg=g:Select(tp,1,1,nil)
    local tc=Duel.GetFirstTarget()
    local tco=tc:GetOverlayCount()
    if tc:IsRelateToEffect(e) then
        Duel.Overlay(tc,sg)
    end
    if tco ~= tc:GetOverlayCount() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end
    end
end

function s.filtEn(c)
    return c:IsSetCard(0x1700)
end