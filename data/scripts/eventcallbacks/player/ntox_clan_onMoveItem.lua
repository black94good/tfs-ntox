local event = Event()

local function destinationBelongsToPlayer(player, toThing, toPosition)
	if toPosition.x ~= CONTAINER_POSITION then
		return false
	end

	if not toThing then
		return true
	end

	local ok, topParent = pcall(function() return toThing:getTopParent() end)
	if ok and topParent then
		return topParent == player
	end

	return true
end

event.onMoveItem = function(self, item, count, fromPosition, toPosition, fromThing, toThing)
	if not NTOX_CLAN or not NTOX_CLAN.isSharinganItem(item) then
		return RETURNVALUE_NOERROR
	end

	if NTOX_CLAN.getClan(self) ~= NTOX_CLAN.UCHIHA then
		self:sendCancelMessage("Somente membros do clan Uchiha podem carregar este Sharingan.")
		return RETURNVALUE_NOTPOSSIBLE
	end

	if not destinationBelongsToPlayer(self, toThing, toPosition) then
		self:sendCancelMessage("O Sharingan esta ligado ao seu personagem e nao pode sair do inventario.")
		return RETURNVALUE_NOTPOSSIBLE
	end

	return RETURNVALUE_NOERROR
end

event:register(100)
