NTOX_CLAN = {
	STORAGE_CLAN = 51000,
	STORAGE_REWARD = 51001,
	STORAGE_SHARINGAN = 51002,

	NONE = 0,
	UCHIHA = 1,
	SENJU = 2,
	UZUMAKI = 3,

	SHARINGAN_ITEM_ID = 3007,
	SHARINGAN_ACTION_ID = 45100,

	SENJU_SPELL = "Senju Healing",
	UZUMAKI_SPELL = "Uzumaki Seal"
}

NTOX_CLAN.names = {
	[NTOX_CLAN.UCHIHA] = "Uchiha",
	[NTOX_CLAN.SENJU] = "Senju",
	[NTOX_CLAN.UZUMAKI] = "Uzumaki"
}

NTOX_CLAN.byName = {
	uchiha = NTOX_CLAN.UCHIHA,
	senju = NTOX_CLAN.SENJU,
	uzumaki = NTOX_CLAN.UZUMAKI
}

local function isSharingan(item)
	return item and item:getId() == NTOX_CLAN.SHARINGAN_ITEM_ID and item:getActionId() == NTOX_CLAN.SHARINGAN_ACTION_ID
end

local function findSharinganInContainer(container)
	if not container or not container:isContainer() then
		return nil
	end

	for i = 0, container:getSize() - 1 do
		local item = container:getItem(i)
		if isSharingan(item) then
			return item
		end
		if item and item:isContainer() then
			local found = findSharinganInContainer(item)
			if found then
				return found
			end
		end
	end
	return nil
end

function NTOX_CLAN.getClan(player)
	local clan = player:getStorageValue(NTOX_CLAN.STORAGE_CLAN)
	if clan < 0 then
		return NTOX_CLAN.NONE
	end
	return clan
end

function NTOX_CLAN.getClanName(clanId)
	return NTOX_CLAN.names[clanId] or "Nenhum"
end

function NTOX_CLAN.isSharinganItem(item)
	return isSharingan(item)
end

function NTOX_CLAN.hasSharingan(player)
	for slot = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(slot)
		if isSharingan(item) then
			return true
		end
		if item and item:isContainer() and findSharinganInContainer(item) then
			return true
		end
	end
	return false
end

function NTOX_CLAN.giveSharingan(player)
	if NTOX_CLAN.hasSharingan(player) then
		return true
	end

	local item = player:addItem(NTOX_CLAN.SHARINGAN_ITEM_ID, 1, false, 1, CONST_SLOT_RING)
	if not item then
		item = player:addItem(NTOX_CLAN.SHARINGAN_ITEM_ID, 1)
	end
	if not item then
		return false
	end

	item:setActionId(NTOX_CLAN.SHARINGAN_ACTION_ID)
	item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Sharingan do clan Uchiha. Este item fica preso ao personagem e sera usado para liberar poderes futuros.")
	player:setStorageValue(NTOX_CLAN.STORAGE_SHARINGAN, 1)
	return true
end

function NTOX_CLAN.ensureClanRewards(player)
	local clan = NTOX_CLAN.getClan(player)
	if clan == NTOX_CLAN.NONE then
		return true
	end

	if clan == NTOX_CLAN.UCHIHA then
		return NTOX_CLAN.giveSharingan(player)
	end

	if player:getStorageValue(NTOX_CLAN.STORAGE_REWARD) == 1 then
		return true
	end

	if clan == NTOX_CLAN.SENJU then
		player:learnSpell(NTOX_CLAN.SENJU_SPELL)
		player:setStorageValue(NTOX_CLAN.STORAGE_REWARD, 1)
		return true
	end

	if clan == NTOX_CLAN.UZUMAKI then
		player:learnSpell(NTOX_CLAN.UZUMAKI_SPELL)
		player:setStorageValue(NTOX_CLAN.STORAGE_REWARD, 1)
		return true
	end

	return true
end

function NTOX_CLAN.setClan(player, clanId)
	if not NTOX_CLAN.names[clanId] then
		return false, "Clan invalido. Use: uchiha, senju ou uzumaki."
	end

	local currentClan = NTOX_CLAN.getClan(player)
	if currentClan ~= NTOX_CLAN.NONE then
		return false, "Voce ja pertence ao clan " .. NTOX_CLAN.getClanName(currentClan) .. "."
	end

	player:setStorageValue(NTOX_CLAN.STORAGE_CLAN, clanId)
	player:setStorageValue(NTOX_CLAN.STORAGE_REWARD, -1)
	NTOX_CLAN.ensureClanRewards(player)
	return true, "Voce entrou no clan " .. NTOX_CLAN.getClanName(clanId) .. "."
end

function NTOX_CLAN.canCast(player, clanId)
	return NTOX_CLAN.getClan(player) == clanId
end
