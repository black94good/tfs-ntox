local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_POFF)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_WHIRLWINDAXE)
combat:setArea(createCombatArea(AREA_SQUARE1X1))

combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, -10, -10, -10, -10)

function onCastSpell(creature, variant)
    return combat:execute(creature, variant)
end