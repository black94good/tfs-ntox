local config = {
storageActive = 80002,
storageCd = 685006,
timeCd = 5,
----------------------------------------------------------------------------
duration = 10,
----------------------------------------------------------------------------
regenInterval = 3000,
regen = {hp = 5, mp = 5},
----------------------------------------------------------------------------
buffStartEffect = {id = 306},
loopEffect = {id = 303, offset = {x = 0, y = 0}, interval = 1000},
buffEndEffect = {id = 306, offset = {x = 0, y = 0}, delayBeforeEnd = 200},
----------------------------------------------------------------------------
animatedText = {text = "Futon: Keikai no Kaze!", color = 129, offset = {x = -0, y = -0}}
}

local skillCondition = Condition(CONDITION_ATTRIBUTES)
skillCondition:setParameter(CONDITION_PARAM_TICKS, config.duration * 1000)
skillCondition:setParameter(CONDITION_PARAM_SUBID, 999)
skillCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
skillCondition:setParameter(CONDITION_PARAM_SKILL_FIST, 1)
skillCondition:setParameter(CONDITION_PARAM_SKILL_SWORD, 1)
skillCondition:setParameter(CONDITION_PARAM_SKILL_CLUB, 1)
skillCondition:setParameter(CONDITION_PARAM_SKILL_AXE, 1)
skillCondition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 1)
skillCondition:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 2)

local regenCondition = Condition(CONDITION_REGENERATION)
regenCondition:setParameter(CONDITION_PARAM_TICKS, config.duration * 1000)
regenCondition:setParameter(CONDITION_PARAM_HEALTHGAIN, config.regen.hp)
regenCondition:setParameter(CONDITION_PARAM_HEALTHTICKS, config.regenInterval)
regenCondition:setParameter(CONDITION_PARAM_MANAGAIN, config.regen.mp)
regenCondition:setParameter(CONDITION_PARAM_MANATICKS, config.regenInterval)
regenCondition:setParameter(CONDITION_PARAM_SUBID, 998)
regenCondition:setParameter(CONDITION_PARAM_BUFF, true)

local combat = Combat()
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
combat:addCondition(skillCondition)
combat:addCondition(regenCondition)

local function loopMagicEffect(playerId, effectId, offset, interval, endTime)
local player = Player(playerId)
if not player then
return
end

if player:getStorageValue(config.storageActive) ~= 1 then
return
end

local now = os.mtime()
if now >= endTime then
return
end

local playerPos = player:getPosition()
local effectPos = Position(
playerPos.x + offset.x,
playerPos.y + offset.y,
playerPos.z
)

effectPos:sendMagicEffect(effectId)

addEvent(loopMagicEffect, interval, playerId, effectId, offset, interval, endTime)
end

local function showBuffEndEffect(playerId)
local player = Player(playerId)
if not player then
return
end

if player:getStorageValue(config.storageActive) ~= 1 then
return
end

local playerPos = player:getPosition()
local offset = config.buffEndEffect.offset
local effectPos = Position(
playerPos.x + offset.x,
playerPos.y + offset.y,
playerPos.z
)
effectPos:sendMagicEffect(config.buffEndEffect.id)

local now = os.time()
local remaining = math.max(0, player:getStorageValue(config.storageCd) - now)
sendSpellCooldown(player, "spell6", remaining)

player:setStorageValue(config.storageActive, -1)
end

function onCastSpell(creature, variant)
if not creature or not creature:isPlayer() then
return false
end

local player = creature
local playerId = player:getId()

local now = os.time()
local cdValue = player:getStorageValue(config.storageCd)
local remaining = cdValue - now

if remaining > 0 then
player:sendCancelMessage(string.format("Espere %.2f segundos para usar esta habilidade novamente.", remaining))
player:getPosition():sendMagicEffect(CONST_ME_POFF)
return false
end

if player:getStorageValue(config.storageActive) == 1 then
player:sendCancelMessage("Seu buff já está ativado.")
player:getPosition():sendMagicEffect(CONST_ME_POFF)
return false
end

player:setStorageValue(config.storageActive, 1)

if not combat:execute(player, variant) then
player:setStorageValue(config.storageActive, -1)
return false
end

local playerPos = player:getPosition()

playerPos:sendMagicEffect(config.buffStartEffect.id)

local textOffset = config.animatedText.offset
local textPos = Position(
playerPos.x + textOffset.x,
playerPos.y + textOffset.y,
playerPos.z
)
Game.sendAnimatedText(config.animatedText.text, textPos, config.animatedText.color)

local endTime = os.mtime() + (config.duration * 1000)
loopMagicEffect(playerId, config.loopEffect.id, config.loopEffect.offset, config.loopEffect.interval, endTime)

local endEffectDelay = config.duration * 1000 - config.buffEndEffect.delayBeforeEnd
if endEffectDelay > 0 then
addEvent(showBuffEndEffect, endEffectDelay, playerId)
end

sendSpellCooldown(player, "spell6", config.duration)
player:setStorageValue(config.storageCd, now + config.timeCd)

return true
end
