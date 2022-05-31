--File included commonly used function, such as retreat, weaknes/resistance, and attacks
--Scripted by adruzenko03 (10V Battery)
pokeutil={}

function pokeutil.InitRetreat(c,id)	
	--Retreat
	function pokeutil.retcon(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetSequence()>=5
	end
	function pokeutil.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
		local val=e:GetHandler():GetDefense()
		local og=c:GetOverlayGroup():Filter(Card.IsSetCard,nil,0x700)
		if chk==0 then return og:GetCount()>=val end
		Duel.SendtoGrave(og:Select(tp,val,val,nil), REASON_EFFECT)
	end
	function pokeutil.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingTarget(pokeutil.filterM,tp,LOCATION_MZONE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		Duel.SelectTarget(tp,pokeutil.filterM,tp,LOCATION_MZONE,0,1,1,nil)
	end
	function pokeutil.retop(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SwapSequence(tc,e:GetHandler())
		end
	end


	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(100,0))
	e1:SetCategory(CATEGORY_DEFCHANGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(pokeutil.retcon)
	e1:SetCost(pokeutil.retcost)
	e1:SetTarget(pokeutil.rettg)
	e1:SetOperation(pokeutil.retop)
	c:RegisterEffect(e1)
end


function pokeutil.InitWeakRes(c,raceW,modW,countW,raceR,modR,countR)
	function pokeutil.wcon(e,tp,eg,ep,ev,re,r,rp)
		return not re:IsHasCategory(CATEGORY_ATKCHANGE)
	end

	function pokeutil.wop(e,tp,eg,ep,ev,re,r,rp)
		local newev=ev;
		if re:GetHandler():IsRace(raceW) then
			if(modW=="*") then
				for i=2,countW do
					e:GetHandler():AddCounter(0x1300,ev)
					newev=newev+ev
				end
			end
		end
		if(raceR~=nil and re:GetHandler():IsRace(raceR)) then
			if(modR=="-") then 
				if(ev<countR) then
					e:GetHandler():RemoveCounter(tp,0x1300,ev,REASON_ADJUST)
					newev=newev-ev
				else
					e:GetHandler():RemoveCounter(tp,0x1300,countR,REASON_ADJUST)
					newev=newev-countR
				end
			end
		end
		Duel.RaiseEvent(e:GetHandler(), EVENT_BATTLE_END, re, r, rp, ep, newev)
	end

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADD_COUNTER+0x1300)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCondition(pokeutil.wcon)
	e2:SetOperation(pokeutil.wop)
	c:RegisterEffect(e2)
end


function pokeutil.InitAtk(c,id,atkNum,ener,dam,condCust,costCust,tgCust,opCust)
	function pokeutil.dcon(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetTurnCount()==1  or e:GetHandler():GetSequence()<5 then
			return false
		end
		--TODO: Add double energy counting here
		local overlay=e:GetHandler():GetOverlayGroup()
		local energroup=overlay:Filter(Card.IsSetCard,nil,0x1700)
		local specenergroup=overlay:Filter(Card.IsSetCard,nil,0x2700)
		local enerrem=ener
		if string.len(enerrem)>(energroup:GetCount()+specenergroup:GetCount())then
			return false;
		end
		enerrem=enerrem:gsub("%N", "")
		local enerstr=""
		local convtable={[999912041]="G",[999912042]="F",[999912043]="W",[999912044]="L",[999912045]="P",
						 [999912046]="R",[999912047]="K",[999912048]="M",[999912049]="Y"}
		for en in energroup:Iter() do
			enerstr=enerstr..convtable[en:GetCode()]
		end
		for c in enerstr:gmatch"." do
			local ind=ener:find(c)
			if ind then
				enerrem=enerrem:sub(1,ind-1)..enerrem:sub(ind+1)
			end
		end

		local auraCount=overlay:FilterCount(Card.IsCode,nil,991204186)
		if enerrem:len()<=auraCount then
			return true
		end
		return false	
	end

	function pokeutil.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
		local temp= Duel.IsExistingMatchingCard(pokeutil.filterEx,tp,0,LOCATION_MZONE,1,nil)
		if(tgCust~=nil) then
			temp = temp and tgCust(e,tp,eg,ep,ev,re,r,rp,chk)
		end
		return temp
	end

	function pokeutil.dop(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(pokeutil.filterEx,tp,0,LOCATION_MZONE,nil)
		g:GetFirst():AddCounter(0x1300,e:GetValue())	
		if(opCust~=nil) then
			opCust(e,tp,eg,ep,ev,re,r,rp,g)
		end
	end


	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,atkNum))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetValue(dam)
	e3:SetType(EFFECT_TYPE_IGNITION)
	if (costCust~=nil) then
		e3:SetCost(costCust)
	end
	if (condCust~=nil) then
		e1:SetCondition(condCust)
	end
    e3:SetCondition(pokeutil.dcon)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(pokeutil.dtg)
	e3:SetOperation(pokeutil.dop)
	c:RegisterEffect(e3)
end

function pokeutil.resetEff(c,ef)
	if(pokeutil.filterM(c)) then return end
	function pokeutil.mcon(e,tp,eg,ep,ev,re,r,rp)
		return pokeutil.filterM(e:GetHandler()) 
	end
	function pokeutil.mop(e,tp,eg,ep,ev,re,r,rp)
		if not ef:IsDeleted() then
			ef:Reset()
		end
		e:Reset()
	end

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_MOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(pokeutil.mcon)
	e4:SetOperation(pokeutil.mop)
	c:RegisterEffect(e4)
end

function pokeutil.energyAttach(c,condCust,costCust,tgCust,opCust)

	function pokeutil.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if(tgCust~=nil) then
			tgCust(e,tp,eg,ep,ev,re,r,rp,chk)
		else
			if chkc then return chkc:IsLocation(LOCATION_MZONE) end
			if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			Duel.SelectTarget(tp,Card.IsFaceUp,tp,LOCATION_MZONE,0,1,1,nil)
		end

	end
	function pokeutil.activate(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
			c:CancelToGrave()
			Duel.Overlay(tc,Group.FromCards(c))
			if(opCust~=nil) then
				opCust(e,tp,eg,ep,ev,re,r,rp)
			end
		end
		
	end
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	if (costCust~=nil) then
		e1:SetCost(costCust)
	end
	if (condCust~=nil) then
		e1:SetCondition(condCust)
	end
	e1:SetTarget(pokeutil.target)
	e1:SetOperation(pokeutil.activate)
	c:RegisterEffect(e1)

end

function pokeutil.toolAttach(c,condCust,costCust,tgCust,opCust)

	function pokeutil.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if(tgCust~=nil) then
			tgCust(e,tp,eg,ep,ev,re,r,rp,chk)
		else
			if chkc then return chkc:IsLocation(LOCATION_MZONE) end
			if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(pokeutil.toolfilt,tp,LOCATION_MZONE,0,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			Duel.SelectTarget(tp,pokeutil.toolfilt,tp,LOCATION_MZONE,0,1,1,nil)
		end

	end
	function pokeutil.activate(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
			c:CancelToGrave()
			Duel.Overlay(tc,Group.FromCards(c))
			if(opCust~=nil) then
				opCust(e,tp,eg,ep,ev,re,r,rp)
			end
		end
		
	end
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	if (costCust~=nil) then
		e1:SetCost(costCust)
	end
	if (condCust~=nil) then
		e1:SetCondition(condCust)
	end
	e1:SetTarget(pokeutil.target)
	e1:SetOperation(pokeutil.activate)
	c:RegisterEffect(e1)

end

function pokeutil.stadcon(e,tp,eg,ep,ev,re,r,rp)
	function pokeutil.stadfilt(c)
		return c:IsCode(e:GetHandler():GetCode()) 
	end
    return Duel.GetMatchingGroupCount(pokeutil.stadfilt,tp, LOCATION_FZONE, LOCATION_FZONE,nil)==0
end

function pokeutil.filterM(c)
	return c:GetSequence()<5
end

function pokeutil.filterEx(c)
	return c:GetSequence()>=5
end
function pokeutil.toolfilt(c)
	return c:GetOverlayGroup():FilterCount(Card.IsSetCard,nil,0x720)==0
end
return pokeutil