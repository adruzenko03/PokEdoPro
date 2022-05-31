--Zacian V (Sword & Shield)
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Intrepid Sword
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Brave Blade
	pokeutil.InitAtk(c,id,1,"MMM",23,nil,nil,nil,s.atop)

	pokeutil.InitRetreat(c,id)

	pokeutil.InitWeakRes(c,RACE_PYRO,"*",2,RACE_PLANT,"-",3)

end


function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)~=0 end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local topCount=3
	local deckCount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deckCount<topCount then 
		topCount=deckCount
	end
	Duel.DisableShuffleCheck()
	local g=Duel.GetDecktopGroup(tp,topCount)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(s.filter,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=g:FilterSelect(tp,s.filter,0,topCount,nil)
		Duel.Overlay(e:GetHandler(),sg)
		Duel.SendtoHand(g:RemoveCard(sg),nil,REASON_EFFECT)
	else Duel.SendtoHand(g,nil,REASON_EFFECT) end

	Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
    Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
end


function s.atop(e,tp,eg,ep,ev,re,r,rp,tg)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
	pokeutil.resetEff(e:GetHandler(),e1)


end

function s.filter(c)
	return c:IsCode(999912048)
end

function s.atlimit(e,re)
	return e:GetHandler()==re:GetHandler() and re:IsHasCategory(CATEGORY_DAMAGE)
end
