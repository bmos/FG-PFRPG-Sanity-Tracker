--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

---	This function returns a consistent value for rActor.
--	This is accomplished by parsing node for a number of expected relationships.
--	@param node This is the databasenode that is to be queried for relationships.
--	@return rActor This is a table containing database paths and identifying data about the player character.
local function handleArgs(node)
	local rActor

	if node.getParent().getName() == 'charsheet' then
		rActor = ActorManager.resolveActor(node)
	elseif node.getParent().getName() == 'abilities' then
		rActor = ActorManager.resolveActor(node.getChild('...'))
	elseif node.getChild('...').getName() == 'effects' then
		rActor = ActorManager.resolveActor(node.getChild('....'))
	end

	return rActor
end

---	This function calculates the sums of all values in a table.
--	@param t This is a table (which should contain only numbers).
--	@return nSum This is the numerical sum of all values in table t.
function tableSum(t)
	local nSum = 0

	for _,v in pairs(t) do
		nSum = nSum + v
	end

	return nSum
end

---	This function calculates sanity score, edge, and threshold.
--	@param node the initiating databasenode
function updateSanityScore(node)
	local rActor = handleArgs(node)
	if rActor then
		local nodeChar = ActorManager.getCreatureNode(rActor);
		local tMentalScores = {}

		tMentalScores['cha'] = DB.getValue(nodeChar, 'abilities.charisma.score', 0)
		tMentalScores['wis'] = DB.getValue(nodeChar, 'abilities.wisdom.score', 0)
		tMentalScores['int'] = DB.getValue(nodeChar, 'abilities.intelligence.score', 0)

		tMentalScores['cha_effect'] = EffectManager35EDS.getEffectsBonus(rActor, 'CHA', true)
		tMentalScores['wis_effect'] = EffectManager35EDS.getEffectsBonus(rActor, 'WIS', true)
		tMentalScores['int_effect'] = EffectManager35EDS.getEffectsBonus(rActor, 'INT', true)

		tMentalScores['cha_dmg'] = -1 * DB.getValue(nodeChar, 'abilities.charisma.damage', 0)
		tMentalScores['wis_dmg'] = -1 * DB.getValue(nodeChar, 'abilities.wisdom.damage', 0)
		tMentalScores['int_dmg'] = -1 * DB.getValue(nodeChar, 'abilities.intelligence.damage', 0)

		local nSanityScore = tableSum(tMentalScores)
		local nSanityEdge = (nSanityScore / 2) - (nSanityScore / 2) % 1

		local tThreshold = {}
		tThreshold['cha'] = tMentalScores.cha + tMentalScores.cha_effect + tMentalScores.cha_dmg
		tThreshold['wis'] = tMentalScores.wis + tMentalScores.wis_effect + tMentalScores.wis_dmg
		tThreshold['int'] = tMentalScores.int + tMentalScores.int_effect + tMentalScores.int_dmg

		local nHighestMentalStat = math.max(tThreshold.cha, tThreshold.wis, tThreshold.int)
		local nSanityThreshold = (nHighestMentalStat - 10 ) / 2

		DB.setValue(nodeChar, 'sanity.score', 'number', nSanityScore)
		DB.setValue(nodeChar, 'sanity.edge', 'number', nSanityEdge)
		DB.setValue(nodeChar, 'sanity.threshold', 'number', nSanityThreshold - nSanityThreshold % 1)
	end
end

--- Allow dragging and dropping madnesses between players
--	@return nodeChar This is the databasenode of the player character within charsheet.
--	@return sClass 
--	@return sRecord 
--	@return nodeTargetList 
function addMadness(nodeChar, sClass, sRecord, nodeTargetList)
	if not nodeChar then
		return false;
	end
	
	if sClass == 'referencemadness' then
		local nodeSource = CharManager.resolveRefNode(sRecord)
		if not nodeSource then
			return
		end
		
		if not nodeTargetList then
			return
		end
		
		local nodeEntry = nodeTargetList.createChild()
		DB.copyNode(nodeSource, nodeEntry)
	else
		return false
	end
	
	return true
end

---	This function rolls the save specified in the madness information
function rollSave(rActor, sSave, nDC)
	if sSave == 'fort' then
		sSave = 'fortitude'
	elseif sSave == 'ref' then
		sSave = 'reflex'
	elseif sSave == 'none' then
		sSave = nil
	end

	local rRoll = ActionSave.getRoll(rActor, sSave)

	if nDC == 0 then
		nDC = nil
	end
	rRoll.nTarget = nDC
	rRoll.tags = 'sanitytracker'

	ActionsManager.performAction(nil, rActor, rRoll)
end

function onInit()
	if Session.IsHost then
		DB.addHandler(DB.getPath('charsheet.*.abilities.charisma'), 'onChildUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('charsheet.*.abilities.wisdom'), 'onChildUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('charsheet.*.abilities.intelligence'), 'onChildUpdate', updateSanityScore)
		DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH .. '.effects.*.label'), 'onUpdate', updateSanityScore)
		DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH .. '.effects.*.isactive'), 'onUpdate', updateSanityScore)
		DB.addHandler(DB.getPath(CombatManager.CT_COMBATANT_PATH .. '.effects'), 'onChildDeleted', updateSanityScore)
	end
end