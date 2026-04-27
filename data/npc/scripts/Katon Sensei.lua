local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local SPELL_NAME = "Katon Blast"

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	local message = msg:lower()

	if msgcontains(message, "katon blast") or msgcontains(message, "spell") then
		if player:hasLearnedSpell(SPELL_NAME) then
			npcHandler:say("Voce ja conhece o Katon Blast.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		if not player:canLearnSpell(SPELL_NAME) then
			npcHandler:say("Voce ainda nao atende os requisitos para aprender o Katon Blast.", cid)
			npcHandler.topic[cid] = 0
			return true
		end

		npcHandler:say("Deseja aprender o Katon Blast?", cid)
		npcHandler.topic[cid] = 1
		return true
	end

	if msgcontains(message, "yes") and npcHandler.topic[cid] == 1 then
		if player:hasLearnedSpell(SPELL_NAME) then
			npcHandler:say("Voce ja conhece essa spell.", cid)
		elseif not player:canLearnSpell(SPELL_NAME) then
			npcHandler:say("Voce nao atende os requisitos para aprender o Katon Blast.", cid)
		elseif player:learnSpell(SPELL_NAME) then
			npcHandler:say("Muito bem. Agora voce aprendeu o Katon Blast.", cid)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		else
			npcHandler:say("Nao foi possivel ensinar essa spell agora.", cid)
		end

		npcHandler.topic[cid] = 0
		return true
	end

	if msgcontains(message, "no") and npcHandler.topic[cid] == 1 then
		npcHandler:say("Tudo bem. Volte quando quiser aprender.", cid)
		npcHandler.topic[cid] = 0
		return true
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
