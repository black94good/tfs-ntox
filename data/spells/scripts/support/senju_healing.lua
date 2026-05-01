local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

function onCastSpell(creature, variant)
	if not creature:isPlayer() or not NTOX_CLAN.canCast(creature, NTOX_CLAN.SENJU) then
		creature:sendCancelMessage("Apenas shinobis do clan Senju podem usar este jutsu.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local min = (creature:getLevel() / 5) + (creature:getMagicLevel() * 4) + 35
	local max = (creature:getLevel() / 5) + (creature:getMagicLevel() * 7) + 70
	for _, target in ipairs(combat:getTargets(creature, variant)) do
		local master = target:getMaster()
		if target:isPlayer() or master and master:isPlayer() then
			doTargetCombat(creature, target, COMBAT_HEALING, min, max)
		end
	end
	return true
end
