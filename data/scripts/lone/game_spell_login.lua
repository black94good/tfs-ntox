--CREATURESCRIPT--

local loginEvent = CreatureEvent("LoginSpellBar")

function loginEvent.onLogin(player)
	player:registerEvent("CreateSpellBar")
	return true
end

loginEvent:register()

local spellBarEvent = CreatureEvent("CreateSpellBar")

function spellBarEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= 17 then
		return true
	end

	local vocationId = player:getVocation():getId()

	if buffer == "refresh" then
		player:sendExtendedOpcode(17, tostring(vocationId))
		return true
	end
	-- Espera o formato: "check;vocationId;spell1,spell2,spell3"
	if string.sub(buffer, 1, 6) == "check;" then
		
		local parts = {}
		for part in string.gmatch(buffer, "([^;]+)") do
			table.insert(parts, part)
		end
		
		local vocId = parts[2] or tostring(vocationId)
		local spellNamesStr = parts[3] or ""
		
		local learned = {}
		for spellName in string.gmatch(spellNamesStr, "([^,]+)") do
			if player:hasLearnedSpell(spellName) then
				table.insert(learned, spellName)
				
			end
		end

		local payload = vocId .. ";DONE;" .. table.concat(learned, ",")
		
		player:sendExtendedOpcode(17, payload)
	end

	return true
end

spellBarEvent:register()