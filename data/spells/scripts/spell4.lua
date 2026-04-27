local config = {
missileEffect = 80, -- Efeito do míssil
areaEffect = 310, -- Efeito ao atingir
areaEffectOffset = {x = 3, y = 3}, -- Offset visual
hitColor = 129, -- Cor do dano
----------------------------------------------------------------------------
multiHit = {
enabled = true, -- Multi-hit ativado?
hitCount = 3, -- Número de hits
delayBetweenHits = 150 -- Intervalo entre hits
},
----------------------------------------------------------------------------
missileDelay = 100, -- Delay base do míssil
missileDelayPerSqm = 50, -- Delay adicional por distância
damageDelay = 100, -- Delay antes do dano
----------------------------------------------------------------------------
castText = "Futon: Kazekiri Impact!", -- Texto animado
castTextColor = 129, -- Cor do texto
----------------------------------------------------------------------------
storageCd = 685004, -- Storage de cooldown
cdTime = 1, -- Tempo de cooldown
----------------------------------------------------------------------------
area = { -- Área de dano do impacto no alvo
{1, 1, 1},
{1, 3, 1},
{1, 1, 1}
}
}

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_HITCOLOR, config.hitColor)
combat:setArea(createCombatArea(config.area))

function onGetFormulaValues(player, level, maglevel)
if config.multiHit.enabled then
local min = ((level * 0.20) + (maglevel * 0.60) + 11) / config.multiHit.hitCount
local max = min + 1
return -min, -max
end
local min = ((level * 0.20) + (maglevel * 0.60) + 11)
local max = min + 1
return -min, -max
end
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local function applyDamageOnly(cid, tx, ty, tz)
local caster = Creature(cid)
if not caster then return end
combat:execute(caster, Variant(Position(tx, ty, tz)))
end

local function sendAreaEffect(tx, ty, tz)
local pos = Position(tx + config.areaEffectOffset.x, ty + config.areaEffectOffset.y, tz)
pos:sendMagicEffect(config.areaEffect)
end

local function executeSpell(cid, cx, cy, cz, tx, ty, tz)
local caster = Creature(cid)
if not caster then return end

Position(cx, cy, cz):sendDistanceEffect(Position(tx, ty, tz), config.missileEffect)

local dist = math.max(math.abs(cx - tx), math.abs(cy - ty))
local totalMissileDelay = config.missileDelay + (dist * config.missileDelayPerSqm)

addEvent(sendAreaEffect, totalMissileDelay, tx, ty, tz)

local hits = config.multiHit.enabled and config.multiHit.hitCount or 1
local baseDelay = totalMissileDelay + config.damageDelay

for i = 1, hits do
local delay = baseDelay + ((i - 1) * config.multiHit.delayBetweenHits)
addEvent(applyDamageOnly, delay, cid, tx, ty, tz)
end
end

function onCastSpell(player, variant)
if not player or not player:isPlayer() then return false end

local now = os.time()
local cdEnd = player:getStorageValue(config.storageCd)

if cdEnd > now then
player:sendCancelMessage("Aguarde " .. (cdEnd - now) .. " segundos para usar novamente.")
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

local cPos = player:getPosition()
local tPos = target:getPosition()
local cid = player:getId()

Game.sendAnimatedText(config.castText, cPos, config.castTextColor)

executeSpell(
cid,
cPos.x, cPos.y, cPos.z,
tPos.x, tPos.y, tPos.z
)

return true
end
