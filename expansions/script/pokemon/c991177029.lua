--Vulpix (Fusion Strike)
Duel.LoadScript("pokeutil.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Smash Kick
	pokeutil.InitAtk(c,id,0,"N",1)

	pokeutil.InitRetreat(c,id)

	pokeutil.InitWeakRes(c,RACE_AQUA,"*",2)
end