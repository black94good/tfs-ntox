local config = {
storageCd = 685002, -- Storage do cooldown específico da spell
timeCd = 1, -- Tempo de cooldown em segundos
storageCdAll = 684999, -- Storage do cooldown global de habilidades
timeCdAll = 1, -- Tempo de cooldown global em segundos
----------------------------------------------------------------------------
damageDelay = 100, -- Delay em ms antes de aplicar o dano
----------------------------------------------------------------------------
-- Área de dano
area = {
{1, 1, 1},
{1, 3, 1},
{1, 1, 1},
},
----------------------------------------------------------------------------
effectCreature = { --- Efeito ao acertar o alvo
effectHit = 1, -- ID do efeito visual
offsetHit = {x = 0, y = 0}, -- Offset da posição do efeito
delay = 100 -- Delay em ms para mostrar o efeito
},
----------------------------------------------------------------------------
effect = { --- Efeito visual da área 
effect = 57, -- ID do efeito visual
xOffset = 2, -- Offset X da posição do efeito
yOffset = 1 -- Offset Y da posição do efeito
},
----------------------------------------------------------------------------
--castText = "Futon: Kazeguruma!", -- Texto animado ao castar
--castTextColor = 129, -- Cor do texto animado
----------------------------------------------------------------------------
hitColor = 129 -- Cor do texto de dano
}

local function doEffectCreature(targetId, casterId)
local target = Creature(targetId)
local caster = Creature(casterId)
if not target or not caster then
return
end

local pos = target:getPosition()
local effectPos = Position(
pos.x + config.effectCreature.offsetHit.x,
pos.y + config.effectCreature.offsetHit.y,
pos.z
)
effectPos:sendMagicEffect(config.effectCreature.effectHit)
end

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_HITCOLOR, config.hitColor)
combat:setArea(createCombatArea(config.area))

function onGetFormulaValues(player, level, magicLevel)
local minDmg = ((level * 0.20) + (magicLevel * 0.60) + 1)
local maxDmg = minDmg
return -minDmg, -maxDmg
end
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onTargetCreature(caster, target)
doEffectCreature(target:getId(), caster:getId())
end
combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

local function showEffectAtPosition(pos)
local effectPos = Position(
pos.x + config.effect.xOffset,
pos.y + config.effect.yOffset,
pos.z
)
effectPos:sendMagicEffect(config.effect.effect)
end

local function doDamage(creatureId, pos)
local player = Creature(creatureId)
if not player or not player:isPlayer() then
return
end

combat:execute(player, Variant(pos))
end

local function executeDamageAndUnlock(playerId, pos)
local player = Creature(playerId)
if not player or not player:isPlayer() then
return
end

doDamage(playerId, pos)
addEvent(doCreatureSetNoMove, 50, playerId, false)
end

function onCastSpell(creature, variant)
if not creature or not creature:isPlayer() then
return false
end

local player = creature
local playerId = player:getId()
local now = os.time()

local remainingAll = player:getStorageValue(config.storageCdAll) - now
if remainingAll > 0 then
player:sendCancelMessage(string.format("Espere %.2f segundos para usar outra habilidade.", remainingAll))
return false
end

local remaining = player:getStorageValue(config.storageCd) - now
if remaining > 0 then
player:sendCancelMessage(string.format("Espere %.2f segundos para usar esta habilidade novamente.", remaining))
return false
end

local pos = player:getPosition()

doCreatureSetNoMove(playerId, true)
showEffectAtPosition(pos)

--local textPos = Position(pos.x, pos.y, pos.z)
--Game.sendAnimatedText(config.castText, textPos, config.castTextColor)

addEvent(executeDamageAndUnlock, config.damageDelay, playerId, pos)

player:setStorageValue(config.storageCdAll, now + config.timeCdAll)
player:setStorageValue(config.storageCd, now + config.timeCd)

return true
end
