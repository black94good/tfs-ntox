local config = {
areaEffect = 309, -- Efeito visual da área
areaEffectOffset = {x = 5, y = 5}, -- Offset do efeito da área
areaEffectDelay = 200, -- Delay para mostrar o efeito da área
hitColor = 129, -- Cor do hit color
----------------------------------------------------------------------------
effectCreature = {
effectHit = 333, -- Efeito visual no alvo
offsetHit = {x = 1, y = 1}, -- Offset do efeito no alvo
delay = 100 -- Delay entre efeitos nos alvos
},
----------------------------------------------------------------------------
paralyze = {
enabled = true, -- Ativa paralyze
duration = 3000 -- Duração da paralisia em ms
},
----------------------------------------------------------------------------
multiHit = {
enabled = true, -- Ativa múltiplos hits
hitCount = 7, -- Quantidade de hits
delayBetweenHits = 250 -- Delay entre hits
},
----------------------------------------------------------------------------
jump = {
enabled = true, -- Ativa o salto
duration = 1600, -- Duração do salto em ms
height = 10 -- Altura do salto
},
----------------------------------------------------------------------------
damageDelay = 150, -- Delay antes do dano
----------------------------------------------------------------------------
castText = "Futon: Daien Kazan!", -- Texto exibido ao castar
castTextColor = 129, -- Cor do texto do cast
----------------------------------------------------------------------------
storageCd = 685008, -- Storage do cooldown
cdTime = 1, -- Tempo de cooldown
----------------------------------------------------------------------------
area = { -- Área da spell
{0, 0, 1, 1, 1, 0, 0},
{0, 1, 1, 1, 1, 1, 0},
{1, 1, 1, 1, 1, 1, 1},
{1, 1, 1, 3, 1, 1, 1},
{1, 1, 1, 1, 1, 1, 1},
{0, 1, 1, 1, 1, 1, 0},
{0, 0, 1, 1, 1, 0, 0}
}
}

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_HITCOLOR, config.hitColor)
combat:setArea(createCombatArea(config.area))

function onGetFormulaValues(player, level, maglevel)
local min = ((level * 0.20) + (maglevel * 0.60) + 2) / (config.multiHit.hitCount - 2)
local max = min + 1
return -min, -max
end
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local function doJumpCreature(targetId, casterId)
if not config.jump.enabled then
return
end

local caster = Creature(casterId)
local target = Creature(targetId)
if not caster or not target then return end

local AreaX = 13
local AreaY = 8

local spectators = Game.getSpectators(Creature(casterId):getPosition(), false, true, AreaX, AreaX, AreaY, AreaY)
if #spectators == 0 then
return nil
end

for index, spectator in ipairs(spectators) do
if spectator:getId() ~= Creature(casterId) then
local targetID = Creature(targetId):getId()
spectator:JumpCreature(targetID, config.jump.height, config.jump.duration, 1)
end
end
end

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

function onTargetCreature(caster, target)
doEffectCreature(target:getId(), caster:getId())

if config.jump.enabled then
doJumpCreature(target:getId(), caster:getId())
end
end
combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

local function executeDamageHit(creatureId, targetPosition)
local caster = Creature(creatureId)
if not caster then
return
end

combat:execute(caster, Variant(targetPosition))
end

local function executeMultiHitDamage(creatureId, targetPosition, targetId)
local hitCount = config.multiHit.enabled and config.multiHit.hitCount or 1

for i = 1, hitCount do
addEvent(function(cid, tPos, tid, hitNum, totalHits)
executeDamageHit(cid, tPos)
end, (i - 1) * config.multiHit.delayBetweenHits, creatureId, targetPosition, targetId, i, hitCount)
end
end

function onCastSpell(creature, variant)
if not creature or not creature:isPlayer() then
return false
end

local player = creature
local now = os.time()

local cdEnd = player:getStorageValue(config.storageCd)
if cdEnd > now then
player:sendCancelMessage(string.format("Aguarde %d segundos para usar novamente.", cdEnd - now))
player:getPosition():sendMagicEffect(CONST_ME_POFF)
return false
end

local target = player:getTarget()
if not target or not target:isCreature() then
player:sendCancelMessage("Você precisa ter um alvo.")
player:getPosition():sendMagicEffect(CONST_ME_POFF)
return false
end

player:setStorageValue(config.storageCd, now + config.cdTime)

local casterPos = player:getPosition()
local targetPos = target:getPosition()
local targetId = target:getId()
local playerId = player:getId()

local textPos = Position(casterPos.x, casterPos.y, casterPos.z)
Game.sendAnimatedText(config.castText, textPos, config.castTextColor)

if config.paralyze.enabled then
local condition = Condition(CONDITION_PARALYZE)
condition:setParameter(CONDITION_PARAM_TICKS, config.paralyze.duration)
condition:setFormula(-1, 0, -1, 0)
target:addCondition(condition)
end

addEvent(function(tid, pid)
local tgt = Creature(tid)
if not tgt then
return
end

local tgtPos = tgt:getPosition()
local effectPos = Position(
tgtPos.x + config.areaEffectOffset.x,
tgtPos.y + config.areaEffectOffset.y,
tgtPos.z
)
effectPos:sendMagicEffect(config.areaEffect)

addEvent(function(cid, tPos, tId)
executeMultiHitDamage(cid, tPos, tId)
end, config.damageDelay, pid, tgtPos, tid)
end, config.areaEffectDelay, targetId, playerId)

return true
end
