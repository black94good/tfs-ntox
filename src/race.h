// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_RACE_H
#define FS_RACE_H

#include "enums.h"

struct ElementModifier
{
	CombatType_t combatType;
	float defenseFactor;
	float attackFactor;

	ElementModifier(CombatType_t type, float defFactor, float atkFactor) :
	    combatType(type), defenseFactor(defFactor), attackFactor(atkFactor)
	{}
};

class Race
{
public:
	Race() = default;
	explicit Race(uint16_t id) : id(id) {}

	const std::string& getName() const { return name; }
	uint16_t getId() const { return id; }
	RaceType_t getRaceType() const { return raceType; }

	float getAttackFactor(CombatType_t combatType) const;
	float getDefenseFactor(CombatType_t combatType) const;

private:
	friend class Races;

	std::string name;
	std::string description;

	std::map<CombatType_t, ElementModifier> elementModifiers;

	uint16_t id = 0;
	RaceType_t raceType = RACE_NONE;

	static CombatType_t raceTypeToCombatType(RaceType_t race);
};

class Races
{
public:
	bool loadFromXml();

	Race* getRace(uint16_t id);
	Race* getRaceByType(RaceType_t raceType);
	int32_t getRaceId(const std::string& name) const;

private:
	std::map<uint16_t, Race> races;
};

#endif // FS_RACE_H
