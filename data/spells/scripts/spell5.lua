local config = {
storageCd = 685005,
timeCd = 1,
storageCdAll = 684999,
timeCdAll = 1,
----------------------------------------------------------------------------
damageDelay = 150,
----------------------------------------------------------------------------
castText = "Futon: Tatsu no Osu",
castTextColor = 129,
----------------------------------------------------------------------------
areas = {
[DIRECTION_NORTH] = {
{0, 0, 2, 0, 0},
{0, 1, 1, 1, 0},
{0, 1, 1, 1, 0},
{0, 1, 1, 1, 0},
{1, 1, 1, 1, 1},
{1, 1, 1, 1, 1},
{0, 0, 0, 0, 0}
},
[DIRECTION_EAST] = {
{0, 1, 1, 0, 0, 0, 0},
{0, 1, 1, 1, 1, 1, 0},
{0, 1, 1, 1, 1, 1, 2},
{0, 1, 1, 1, 1, 1, 0},
{0, 1, 1, 0, 0, 0, 0}
},
[DIRECTION_SOUTH] = {
{0, 0, 0, 0, 0},
{1, 1, 1, 1, 1},
{1, 1, 1, 1, 1},
{0, 1, 1, 1, 0},
{0, 1, 1, 1, 0},
{0, 1, 1, 1, 0},
{0, 0, 2, 0, 0}
},
[DIRECTION_WEST] = {
{0, 0, 0, 0, 1, 1, 0},
{0, 1, 1, 1, 1, 1, 0},
{2, 1, 1, 1, 1, 1, 0},
{0, 1, 1, 1, 1, 1, 0},
{0, 0, 0, 0, 1, 1, 0}
}
},
----------------------------------------------------------------------------
effectCreature = {
effectHit = 331,
offsetHit = {x = 1, y = 1},
delay = 100
},
----------------------------------------------------------------------------
effects = {
[DIRECTION_NORTH] = {xOffset = 4, yOffset = 1, effect = 315},
[DIRECTION_EAST] = {xOffset = 7, yOffset = 4, effect = 291},
[DIRECTION_SOUTH] = {xOffset = 4, yOffset = 7, effect = 317},
[DIRECTION_WEST] = {xOffset = 1, yOffset = 4, effect = 316}
},
----------------------------------------------------------------------------
hitColor = 129
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

addEvent(function(tid, ePos)
local t = Creature(tid)
if t then
ePos:sendMagicEffect(config.effectCreature.effectHit)
end
end, config.effectCreature.delay, targetId, effectPos)
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

local function executeDamageAndUnlock(playerId, pos, dir)
local player = Creature(playerId)
if not player or not player:isPlayer() then
return
end

local combat = combats[dir]
if combat then
combat:execute(player, Variant(pos))
end

addEvent(function(pid)
doCreatureSetNoMove(pid, false)
end, 50, playerId)
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

local textPos = Position(pos.x, pos.y, pos.z)
Game.sendAnimatedText(config.castText, textPos, config.castTextColor)

showEffectAtPosition(pos, dir)

addEvent(executeDamageAndUnlock, config.damageDelay, playerId, pos, dir)

player:setStorageValue(config.storageCdAll, now + config.timeCdAll)
player:setStorageValue(config.storageCd, now + config.timeCd)

return true
end
