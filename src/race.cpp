// by Godness. discord: godness.sh


#include "otpch.h"

#include "race.h"

#include <boost/algorithm/string.hpp>

#include "pugicast.h"
#include "tools.h"

bool Races::loadFromXml()
{
	pugi::xml_document doc;
	pugi::xml_parse_result result = doc.load_file("data/xml/elements.xml");
	if (!result) {
		printXMLError("Error - Races::loadFromXml", "data/xml/elements.xml", result);
		return false;
	}

	for (auto raceNode : doc.child("elements").children()) {
		pugi::xml_attribute attr;
		if (!(attr = raceNode.attribute("id"))) {
			std::cout << "[Warning - Races::loadFromXml] Missing race id" << std::endl;
			continue;
		}

		uint16_t id = pugi::cast<uint16_t>(attr.value());

		auto it = races.find(id);
		if (it != races.end()) {
			std::cout << "[Warning - Races::loadFromXml] Duplicate race id: " << id << std::endl;
			continue;
		}

		races.emplace(id, id);
		Race& race = races[id];

		if ((attr = raceNode.attribute("name"))) {
			race.name = attr.as_string();
		}

		if ((attr = raceNode.attribute("description"))) {
			race.description = attr.as_string();
		}

		if ((attr = raceNode.attribute("racetype"))) {
			std::string tmpStrValue = boost::algorithm::to_lower_copy<std::string>(attr.as_string());
			if (tmpStrValue == "none") {
				race.raceType = RACE_NONE;
			} else if (tmpStrValue == "venom") {
				race.raceType = RACE_VENOM;
			} else if (tmpStrValue == "blood") {
				race.raceType = RACE_BLOOD;
			} else if (tmpStrValue == "undead") {
				race.raceType = RACE_UNDEAD;
			} else if (tmpStrValue == "fire") {
				race.raceType = RACE_FIRE;
			} else if (tmpStrValue == "energy") {
				race.raceType = RACE_ENERGY;
			} else if (tmpStrValue == "katon") {
				race.raceType = RACE_KATON;
			} else if (tmpStrValue == "suiton") {
				race.raceType = RACE_SUITON;
			} else if (tmpStrValue == "doton") {
				race.raceType = RACE_DOTON;
			} else if (tmpStrValue == "raiton") {
				race.raceType = RACE_RAITON;
			} else if (tmpStrValue == "fuuton") {
				race.raceType = RACE_FUUTON;
			} else {
				std::cout << "[Warning - Elements::loadFromXml] Unknown element type: " << attr.as_string() << std::endl;
			}
		}

		for (auto elementNode : raceNode.children()) {
			if (!caseInsensitiveEqual(elementNode.name(), "element")) {
				continue;
			}

			if (!(attr = elementNode.attribute("type"))) {
				std::cout << "[Warning - Races::loadFromXml] Missing element type for race: " << race.name
				          << std::endl;
				continue;
			}

			std::string tmpStrValue = boost::algorithm::to_lower_copy<std::string>(attr.as_string());
			CombatType_t combatType = COMBAT_NONE;

			if (tmpStrValue == "physical") {
				combatType = COMBAT_PHYSICALDAMAGE;
			} else if (tmpStrValue == "energy") {
				combatType = COMBAT_ENERGYDAMAGE;
			} else if (tmpStrValue == "earth") {
				combatType = COMBAT_EARTHDAMAGE;
			} else if (tmpStrValue == "fire") {
				combatType = COMBAT_FIREDAMAGE;
			} else if (tmpStrValue == "ice") {
				combatType = COMBAT_ICEDAMAGE;
			} else if (tmpStrValue == "holy") {
				combatType = COMBAT_HOLYDAMAGE;
			} else if (tmpStrValue == "death") {
				combatType = COMBAT_DEATHDAMAGE;
			} else if (tmpStrValue == "drown") {
				combatType = COMBAT_DROWNDAMAGE;
			} else if (tmpStrValue == "katon") {
				combatType = COMBAT_KATONDAMAGE;
			} else if (tmpStrValue == "fuuton") {
				combatType = COMBAT_FUUTONDAMAGE;
			} else if (tmpStrValue == "suiton") {
				combatType = COMBAT_SUITONDAMAGE;
			} else if (tmpStrValue == "raiton") {
				combatType = COMBAT_RAITONDAMAGE;
			} else if (tmpStrValue == "doton") {
				combatType = COMBAT_DOTONDAMAGE;
			} else {
				std::cout << "[Warning - Races::loadFromXml] Unknown element type: " << attr.as_string() << std::endl;
				continue;
			}

			float defenseFactor = 1.0f;
			if ((attr = elementNode.attribute("defense"))) {
				defenseFactor = attr.as_float();
			}

			float attackFactor = 1.0f;
			if ((attr = elementNode.attribute("attack"))) {
				attackFactor = attr.as_float();
			}

			race.elementModifiers.emplace(combatType, ElementModifier(combatType, defenseFactor, attackFactor));
		}
	}

	return true;
}

Race* Races::getRace(uint16_t id)
{
	auto it = races.find(id);
	if (it == races.end()) {
		return nullptr;
	}
	return &it->second;
}

Race* Races::getRaceByType(RaceType_t raceType)
{
	for (auto& it : races) {
		if (it.second.raceType == raceType) {
			return &it.second;
		}
	}
	return nullptr;
}

int32_t Races::getRaceId(const std::string& name) const
{
	for (const auto& it : races) {
		if (caseInsensitiveEqual(it.second.name.c_str(), name.c_str()) == 0) {
			return it.first;
		}
	}
	return -1;
}


float Race::getAttackFactor(CombatType_t combatType) const
{
	auto it = elementModifiers.find(combatType);
	if (it != elementModifiers.end()) {
		return it->second.attackFactor;
	}
	return 1.0f;
}

float Race::getDefenseFactor(CombatType_t combatType) const
{
	auto it = elementModifiers.find(combatType);
	if (it != elementModifiers.end()) {
		return it->second.defenseFactor;
	}
	return 1.0f;
}

CombatType_t Race::raceTypeToCombatType(RaceType_t race)
{
	switch (race) {
		case RACE_VENOM:
			return COMBAT_EARTHDAMAGE;
		case RACE_FIRE:
			return COMBAT_FIREDAMAGE;
		case RACE_ENERGY:
			return COMBAT_ENERGYDAMAGE;
		case RACE_UNDEAD:
			return COMBAT_DEATHDAMAGE;
		case RACE_BLOOD:
			return COMBAT_PHYSICALDAMAGE;
		case RACE_KATON:
			return COMBAT_HOLYDAMAGE;
		case RACE_SUITON:
			return COMBAT_ICEDAMAGE;
		case RACE_DOTON:
			return COMBAT_DEATHDAMAGE;
		case RACE_RAITON:
			return COMBAT_DROWNDAMAGE;
		case RACE_FUUTON:
			return COMBAT_PHYSICALDAMAGE;
		default:
			return COMBAT_NONE;
	}
}
