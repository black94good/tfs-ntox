local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)

local condition = Condition(CONDITION_PARALYZE)
condition:setParameter(CONDITION_PARAM_TICKS, 3500)
condition:setFormula(-0.65, 0, -0.65, 0)
combat:addCondition(condition)

function onCastSpell(creature, variant)
	if not creature:isPlayer() or not NTOX_CLAN.canCast(creature, NTOX_CLAN.UZUMAKI) then
		creature:sendCancelMessage("Apenas shinobis do clan Uzumaki podem usar este jutsu.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	return combat:execute(creature, variant)
end
