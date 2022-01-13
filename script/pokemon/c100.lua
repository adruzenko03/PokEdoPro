--Pokemon TCG
--Scripted by adruzenko03
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.init)
end

function s.init(c)
    --Cannot Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	Duel.RegisterEffect(e1,0)
    --Cannot Conduct Battle Phase
    local e14=Effect.CreateEffect(c)
    e14:SetType(EFFECT_TYPE_FIELD)
    e14:SetCode(EFFECT_CANNOT_BP)
    e14:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e14:SetTargetRange(1,1)
    Duel.RegisterEffect(e14,0)


    --Attack Position Only
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetValue(POS_FACEUP_ATTACK)
	Duel.RegisterEffect(e2,0)
    --Cannot Change Battle Positions
    local e13=Effect.CreateEffect(c)
    e13:SetType(EFFECT_TYPE_FIELD)
    e13:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e13:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e13:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    Duel.RegisterEffect(e13,0)
    --Cannot Summon in Defense
    local e15=Effect.CreateEffect(c)
    e15:SetType(EFFECT_TYPE_FIELD)
    e15:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
    e15:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e15:SetTargetRange(1,1)
    e15:SetValue(POS_ATTACK)
    Duel.RegisterEffect(e15,0)


    --No Hand Size Limit
    local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_HAND_LIMIT)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetTargetRange(1,1)
	e9:SetValue(100)
	Duel.RegisterEffect(e9,0)
    -- Infinite Summons
    local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e12:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e12:SetTargetRange(1,1)
	e12:SetValue(2147483647)
	Duel.RegisterEffect(e12,0)


    --predraw
	local e8=Effect.CreateEffect(c)	
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_PREDRAW)
	e8:SetCountLimit(1)
	e8:SetRange(0xff)
	e8:SetCondition(s.con)
	e8:SetOperation(s.op)
	Duel.RegisterEffect(e8,0)


    --On card Destruction
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.destcon)
	e3:SetTarget(s.desttg)
	e3:SetOperation(s.desttp)
	Duel.RegisterEffect(e3,0)
    --Move Pokemon to Active
    local e16=Effect.CreateEffect(c)
	e16:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e16:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e16:SetCode(EVENT_LEAVE_FIELD)
    e16:SetCondition(s.pivcon)
	e16:SetTarget(s.pivtg)
	e16:SetOperation(s.pivop)
	Duel.RegisterEffect(e16,0)
end


function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumpos&POS_FACEDOWN)>0
end


function s.poscon(e)
	return e:GetHandler():IsAttackPos()
end
function s.postg(e,c)
	return c:IsFaceup()
end


function s.destcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsReason,1,nil,REASON_DESTROY)
end

function s.desttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsFacedown() end
	if chk==0 then 
        return Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    end
end

function s.desttp(e,tp,eg,ep,ev,re,r,rp)
    s.destop(tp,eg)
    s.destop(1-tp,eg)
end

function s.destop(tp,eg)
    local p=eg:FilterCount(s.filtdest,nil,tp)
    local bancount
    local ind
    local g
    
    if p>0 then
        while (p~=0)
        do
            g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
            bancount=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
            if bancount<=p then
                Duel.SendtoHand(g,nil,REASON_EFFECT+REASON_RETURN)
                p=0
            else
                ind=Duel.AnnounceNumberRange(tp,1,bancount)
                g=Duel.GetMatchingGroup(s.filterseq,tp,LOCATION_REMOVED,0,nil,ind)
                Duel.SendtoHand(g,nil,REASON_EFFECT+REASON_RETURN)
                p=p-1
            end
        end
    end
end


function s.pivcon(e,tp,eg,ep,ev,re,r,rp)
    local upper=2
    if Duel.GetMatchingGroupCount(s.spdfilter,1-tp,LOCATION_DECK,0,nil) then
        upper=1
    end

    return Duel.GetMatchingGroupCount(s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil) < upper

end

function s.pivtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local p1=eg:FilterCount(s.filterpivot,nil,tp)
    local p2=eg:FilterCount(s.filterpivot,nil,1-tp)
    if p1>0 then 
        if chk==0 then return Duel.IsExistingTarget(Card.IsInMainMZone,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
        Duel.SelectTarget(tp,Card.IsInMainMZone,tp,LOCATION_MZONE,0,1,1,nil)
    end

    if p2>0 then
        if chk==0 then return Duel.IsExistingTarget(Card.IsInMainMZone,1-tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
        Duel.SelectTarget(1-tp,Card.IsInMainMZone,1-tp,LOCATION_MZONE,0,1,1,nil)
    end
    if p1 & p2==0 then
        return false
    end
end

function s.pivop(e,tp,eg,ep,ev,re,r,rp)
    local tc,sc=Duel.GetFirstTarget()
    local p1=eg:FilterCount(s.filterpivot,nil,tp)
    local p2=eg:FilterCount(s.filterpivot,nil,1-tp)
    if p1>0 then
        Duel.MoveSequence(tc,5)
        tc=sc
    end

    if p2>0 then
        Duel.MoveSequence(tc,5)
    end
end


function s.con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==1
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
    --todeck
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE)
    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1-tp)
    --draw
    Duel.Draw(tp,7,REASON_EFFECT)
    Duel.Draw(1-tp,7,REASON_EFFECT)

    --Check if at least 1 basic is in deck
    local g1=Duel.GetMatchingGroupCount(s.spdfilter,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroupCount(s.spdfilter,1-tp,LOCATION_DECK,0,nil)
    local wtp=g1==0
	local wntp=g2==0
    if wtp and not wntp then
		Duel.Win(1-tp,0x62)
	elseif not wtp and wntp then
        s.pl1op(e,tp)
		Duel.Win(tp,0x62)
        return
	elseif wtp and wntp then
		Duel.Win(PLAYER_NONE,0x62)
    end
    if wtp or wntp then
        Debug.Message("No Pokemon in deck, skipping mulligan phase")
        s.seteff(e)
        return
    end


   --Mulligan
    local extra=Duel.GetMatchingGroupCount(s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)

    local mull,mulltp,mulltp1,mulltp2,end1,end2=0,0,0,0,false,false

    while(extra<2)
    do
        if not end1 then
            mulltp,mulltp1,end1=s.mullhelp(tp)
        end

        if not end2 then
            mulltp,mulltp2,end2=s.mullhelp(1-tp)
        end

        if mulltp1 & mulltp2 == 1 then
            g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
            Duel.ConfirmCards(1-tp,g1)
            Duel.ConfirmCards(tp,g2)
            Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_RULE)
            Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_RULE)
            Duel.ShuffleDeck(tp)
            Duel.ShuffleDeck(1-tp)
            Duel.Draw(tp,7,REASON_EFFECT)
            Duel.Draw(1-tp,7,REASON_EFFECT)
        elseif mulltp1==1 then
            g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            Duel.ConfirmCards(1-tp,g)
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE)
            Duel.ShuffleDeck(tp)
            Duel.Draw(tp,7,REASON_EFFECT)
        
        elseif mulltp2==1 then
            g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
            Duel.ConfirmCards(tp,g)
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE)
            Duel.ShuffleDeck(1-tp)
            Duel.Draw(1-tp,7,REASON_EFFECT)
        end
        mull=mull+ (mulltp1 ~ mulltp2)
        extra=Duel.GetMatchingGroupCount(s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    end
    

    --Mulligan Draw+Add to bench
    if mull>0 then

        local deckSize=Duel.GetFieldGroupCount(1-mulltp,LOCATION_DECK,0)
        if deckSize<mull then
            mull=deckSize
        end
        local drawNum=Duel.AnnounceNumberRange(1-mulltp,0,mull)
        Duel.Draw(1-mulltp,drawNum,REASON_EFFECT)

        g=Duel.GetMatchingGroup(s.sphfilter,1-mulltp,LOCATION_HAND,0,nil)
        local sg=g:Select(1-mulltp,0,5,nil)
        for c in sg:Iter() do
            Duel.MSet(1-mulltp,c,true,nil)
        end
    end
    local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)

    s.seteff(e)

end

function s.pl1op(e,tp)
    local extra=Duel.GetMatchingGroupCount(s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local mulltp

    while(extra<1)
    do
        
        unimp,mulltp=s.mullhelp(tp)
        if mulltp==1 then
            g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            Duel.ConfirmCards(1-tp,g)
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE)
            Duel.ShuffleDeck(tp)
            Duel.Draw(tp,7,REASON_EFFECT)

        end
        extra=Duel.GetMatchingGroupCount(s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    end
    

    local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)

    s.seteff(e)
end

function s.mullhelp(tp)
    local g=Duel.GetMatchingGroup(s.sphfilter,tp,LOCATION_HAND,0,nil)
    local mulltp,mullcurr,endnew=0,0,false
    
    if #g==0 then
        mullcurr=1
        mulltp=tp
    else
        --Active
        local sc=g:Select(tp,1,1,nil):GetFirst()
        Duel.MSet(tp,sc,true,nil,0,0x1f)--Setting it to 0x20 would be ideal but crashes as of now
        Duel.MoveSequence(sc,5)
        endnew=true
        --Bench
        g=Duel.GetMatchingGroup(s.sphfilter,tp,LOCATION_HAND,0,nil)
        local sg=g:Select(tp,0,5,nil)
        for c in sg:Iter() do
            Duel.MSet(tp,c,true,nil)
        end
        --Prize Cards
        local g=Duel.GetDecktopGroup(tp,6)
        Duel.DisableShuffleCheck()
        Duel.Remove(g,POS_FACEDOWN,REASON_COST)
        Duel.DisableShuffleCheck(false)
    end
    return mulltp,mullcurr,endnew
end

function s.seteff(e)
        --no set
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_CANNOT_MSET)
        e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET)
        e4:SetRange(LOCATION_MZONE)
        e4:SetTargetRange(1,1)
        e4:SetTarget(aux.TRUE)
        Duel.RegisterEffect(e4,0)
        local e5=e4:Clone()
        e5:SetCode(EFFECT_CANNOT_SSET)
        Duel.RegisterEffect(e5,0)
        local e6=e4:Clone()
        e6:SetCode(EFFECT_CANNOT_TURN_SET)
        Duel.RegisterEffect(e6,0)
        local e7=e4:Clone()
        e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e7:SetTarget(s.sumlimit)
        Duel.RegisterEffect(e7,0)
        
        --Win Con:Prize Cards
        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e10:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
        e10:SetCode(EVENT_TO_HAND)
        e10:SetOperation(s.opwin1)
        Duel.RegisterEffect(e10,0)
        --Win Con:Bench Empty
        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e11:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
        e11:SetCode(EVENT_LEAVE_FIELD)
        e11:SetOperation(s.opwin2)
        Duel.RegisterEffect(e11,0)
end


function s.opwin1(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
    local g2=Duel.GetMatchingGroupCount(Card.IsFacedown,1-tp,LOCATION_REMOVED,0,nil)
    local wtp=g1==0
	local wntp=g2==0
    if wtp and not wntp then
		Duel.Win(tp,0x60)
	elseif not wtp and wntp then
		Duel.Win(1-tp,0x60)
	elseif wtp and wntp then
		Duel.Win(PLAYER_NONE,0x60)
    end
end

function s.opwin2(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
    local g2=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
    local wtp=g1==0
	local wntp=g2==0
    if wtp and not wntp then
		Duel.Win(1-tp,0x61)
	elseif not wtp and wntp then
		Duel.Win(tp,0x61)
	elseif wtp and wntp then
		Duel.Win(PLAYER_NONE,0x61)
    end
end


function s.filtdest(c,tp)
    return c:IsReason(REASON_DESTROY) and c:GetPreviousControler()~=tp
end

function s.filterpivot(c,tp)
    return c:GetPreviousControler()==tp
end

function s.filterseq(c,p)
    return c:GetSequence()==p-1
end

function s.sphfilter(c)
    return c:IsLevelBelow(4) and c:IsMSetable(true,nil)
end


function s.spdfilter(c)
    return c:IsLevelBelow(4) and c:IsSummonableCard()
end

function s.extrafilter(c)
    return c:GetSequence()>=5
end