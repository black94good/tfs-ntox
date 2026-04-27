local BOMB_SCROLL_ITEM = 10527
local PLACED_BOMB_ITEM = 10527
local BOMB_DURATION = 60 * 1000
local MAX_BOMBS = 3
local EXPLODE_DELAY = 500
local CHAIN_DELAY = 200

local bombs = {}
local playerBombCount = {}

local function posKey(pos)
	return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function getNinjutsu(player)
	return player:getNinjutsu()
end

local function getDamage(level, ninjutsu)
	local min = -((level * 2) + (ninjutsu * 4))
	local max = -((level * 4) + (ninjutsu * 6))
	return min, max
end

local function decreaseOwnerBombCount(ownerGuid)
	playerBombCount[ownerGuid] = math.max((playerBombCount[ownerGuid] or 1) - 1, 0)
	if playerBombCount[ownerGuid] == 0 then
		playerBombCount[ownerGuid] = nil
	end
end

local function removePlacedBombItem(position)
	local tile = Tile(position)
	if not tile then
		return
	end

	local item = tile:getItemById(PLACED_BOMB_ITEM)
	if item then
		item:remove()
	end
end

local function canPlaceBomb(player, position)
	local tile = Tile(position)
	if not tile then
		return false, "Posicao invalida."
	end

	if not tile:getGround() then
		return false, "Voce so pode armar a bomba no chao."
	end

	if tile:getCreatureCount() > 0 then
		return false, "Nao pode armar a bomba em cima de uma criatura."
	end

	local previewBomb = Game.createItem(PLACED_BOMB_ITEM, 1)
	if not previewBomb then
		return false, "Nao foi possivel preparar a bomba."
	end

	local query = tile:queryAdd(previewBomb)
	previewBomb:remove()

	if query ~= RETURNVALUE_NOERROR then
		return false, "Nao pode armar a bomba nesse local."
	end

	return true
end

local function explode(position)
	local key = posKey(position)
	local bomb = bombs[key]
	if not bomb then
		return
	end

	bombs[key] = nil

	position:sendMagicEffect(CONST_ME_EXPLOSIONAREA)

	local min, max = getDamage(bomb.level, bomb.ninjutsu)
	for _, creature in ipairs(Game.getSpectators(position, false, true, 1, 1, 1, 1)) do
		if creature:isPlayer() then
			if creature:getGuid() ~= bomb.ownerGuid then
				doTargetCombatHealth(0, creature, COMBAT_PHYSICALDAMAGE, min, max, CONST_ME_HITAREA)
			end
		else
			doTargetCombatHealth(0, creature, COMBAT_PHYSICALDAMAGE, min, max, CONST_ME_HITAREA)
		end
	end

	for x = -1, 1 do
		for y = -1, 1 do
			if not (x == 0 and y == 0) then
				local nearPos = Position(position.x + x, position.y + y, position.z)
				local nearKey = posKey(nearPos)
				local nearBomb = bombs[nearKey]
				if nearBomb and not nearBomb.exploding then
					nearBomb.exploding = true
					addEvent(explode, CHAIN_DELAY, nearPos)
				end
			end
		end
	end

	removePlacedBombItem(position)
	decreaseOwnerBombCount(bomb.ownerGuid)
end

local function removeBomb(position)
	local key = posKey(position)
	local bomb = bombs[key]
	if not bomb then
		return
	end

	bombs[key] = nil
	removePlacedBombItem(position)
	position:sendMagicEffect(CONST_ME_POFF)
	decreaseOwnerBombCount(bomb.ownerGuid)
end

local paperbomb = Action()

function paperbomb.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local playerGuid = player:getGuid()
	local key = posKey(toPosition)

	if (playerBombCount[playerGuid] or 0) >= MAX_BOMBS then
		player:sendCancelMessage("Voce ja colocou o maximo de papeis bomba.")
		return true
	end

	if bombs[key] then
		player:sendCancelMessage("Ja existe uma bomba nessa posicao.")
		return true
	end

	local canPlace, message = canPlaceBomb(player, toPosition)
	if not canPlace then
		player:sendCancelMessage(message)
		return true
	end

	local placedBomb = Game.createItem(PLACED_BOMB_ITEM, 1, toPosition)
	if not placedBomb then
		player:sendCancelMessage("Nao foi possivel posicionar a bomba.")
		return true
	end

	bombs[key] = {
		ownerGuid = playerGuid,
		level = player:getLevel(),
		ninjutsu = getNinjutsu(player),
		exploding = false,
	}

	playerBombCount[playerGuid] = (playerBombCount[playerGuid] or 0) + 1

	item:remove(1)
	toPosition:sendMagicEffect(CONST_ME_FIREAREA)
	addEvent(removeBomb, BOMB_DURATION, Position(toPosition.x, toPosition.y, toPosition.z))
	return true
end

paperbomb:id(BOMB_SCROLL_ITEM)
paperbomb:allowFarUse(true)
paperbomb:register()

local stepBomb = MoveEvent()
stepBomb:type("stepin")

function stepBomb.onStepIn(creature, item, position, fromPosition)
	if not creature or not creature:isCreature() then
		return true
	end

	local key = posKey(position)
	local bomb = bombs[key]
	if not bomb or bomb.exploding then
		return true
	end

	bomb.exploding = true
	addEvent(explode, EXPLODE_DELAY, Position(position.x, position.y, position.z))
	return true
end

stepBomb:id(PLACED_BOMB_ITEM)
stepBomb:register()

local bombLook = Event()

function bombLook.onLook(self, thing, position, distance, description)
	if thing:isItem() and thing:getId() == PLACED_BOMB_ITEM then
		local bomb = bombs[posKey(position)]
		if bomb and bomb.ownerGuid ~= self:getGuid() then
			return "You see nothing special."
		end
	end

	return description
end

bombLook:register()
