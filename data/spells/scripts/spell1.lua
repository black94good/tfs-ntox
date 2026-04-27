local config = {
storageCd = 685001, -- Storage do cooldown específico da spell
timeCd = 1, -- Tempo de cooldown em segundos
storageCdAll = 684999, -- Storage do cooldown global de habilidades
timeCdAll = 1, -- Tempo de cooldown global em segundos
damageDelay = 200, -- Delay em ms antes de aplicar o dano
----------------------------------------------------------------------------
-- Áreas de ataque por direção 
areas = {
[DIRECTION_NORTH] = {
{0, 2, 0},
{0, 1, 0},
{0, 1, 0},
{0, 1, 0},
{0, 0, 0},
},
[DIRECTION_EAST] = {
{0, 0, 0, 0, 0, 0},
{0, 0, 1, 1, 1, 2},
{0, 0, 0, 0, 0, 0},
},
[DIRECTION_SOUTH] = {
{0, 0, 0},
{0, 1, 0},
{0, 1, 0},
{0, 1, 0},
{0, 2, 0},
},
[DIRECTION_WEST] = {
{0, 0, 0, 0, 0},
{2, 1, 1, 1, 0},
{0, 0, 0, 0, 0},
}
},
----------------------------------------------------------------------------
--- Configuração do efeito ao acertar o alvo
effectCreature = {
effectHit = 331, -- ID do efeito visual
offsetHit = {x = 1, y = 1}, -- Offset da posição do efeito
delay = 100 -- Delay em ms para mostrar o efeito
},
----------------------------------------------------------------------------
--- Efeitos visuais direcionais
effects = {
[DIRECTION_NORTH] = {xOffset = 2, yOffset = 0, effect = 311},
[DIRECTION_EAST] = {xOffset = 4, yOffset = 2, effect = 312},
[DIRECTION_SOUTH] = {xOffset = 2, yOffset = 4, effect = 313},
[DIRECTION_WEST] = {xOffset = 0, yOffset = 2, effect = 314}
},
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

local combats = {}

for dir, area in pairs(config.areas) do
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_HITCOLOR, config.hitColor)
combat:setArea(createCombatArea(area))

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

combats[dir] = combat
end

local function showEffectAtPosition(pos, dir)
local info = config.effects[dir]
if not info then
return
end

local effectPos = Position(
pos.x + info.xOffset,
pos.y + info.yOffset,
pos.z
)
effectPos:sendMagicEffect(info.effect)
end

local function doDamage(creatureId, pos, dir)
local player = Creature(creatureId)
if not player or not player:isPlayer() then
return
end

local combat = combats[dir]
if combat then
combat:execute(player, Variant(pos))
end
end

local function executeDamageAndUnlock(playerId, pos, dir)
local player = Creature(playerId)
if not player or not player:isPlayer() then
return
end

doDamage(playerId, pos, dir)
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
local dir = player:getDirection()

doCreatureSetNoMove(playerId, true)
showEffectAtPosition(pos, dir)

addEvent(executeDamageAndUnlock, config.damageDelay, playerId, pos, dir)

player:setStorageValue(config.storageCdAll, now + config.timeCdAll)
player:setStorageValue(config.storageCd, now + config.timeCd)

return true
end
