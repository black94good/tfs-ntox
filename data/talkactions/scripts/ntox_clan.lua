function onSay(player, words, param)
	local clanName = param:lower():trim()
	if clanName == "" then
		local currentClan = NTOX_CLAN.getClan(player)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Seu clan atual: " .. NTOX_CLAN.getClanName(currentClan) .. ". Use !clan uchiha, !clan senju ou !clan uzumaki para escolher.")
		return false
	end

	local clanId = NTOX_CLAN.byName[clanName]
	local ok, message = NTOX_CLAN.setClan(player, clanId)
	player:sendTextMessage(ok and MESSAGE_EVENT_ADVANCE or MESSAGE_STATUS_SMALL, message)
	return false
end
