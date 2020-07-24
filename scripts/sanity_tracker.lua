--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

function onInit()
	if User.isHost() then
		DB.addHandler(DB.getPath('charsheet.*.abilities.charisma'), 'onChildUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('charsheet.*.abilities.wisdom'), 'onChildUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('charsheet.*.abilities.intelligence'), 'onChildUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('combattracker.list.*.effects.*.label'), 'onUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('combattracker.list.*.effects.*.isactive'), 'onUpdate', updateSanityScore)
		DB.addHandler(DB.getPath('combattracker.list.*.effects'), 'onChildDeleted', updateSanityScore)
	end
end

---	This function returns a consistent value for nodeChar and rActor.
--	This is accomplished by parsing node for a number of expected relationships.
--	@param node This is the databasenode that is to be queried for relationships.
--	@return nodeChar This is the databasenode of the player character within charsheet.
--	@return rActor This is a table containing database paths and identifying data about the player character.
local function handleArgs(node)
	local nodeChar
	local rActor

	if node.getName() == 'charisma' then
		nodeChar = node.getChild('...')
	elseif node.getName() == 'wisdom' then
		nodeChar = node.getChild('...')
	elseif node.getName() == 'intelligence' then
		nodeChar = node.getChild('...')
	elseif node.getName() == 'effects' then
		nodeChar = node.getParent()
	elseif node.getChild('...').getName() == 'effects' then
		rActor = ActorManager.getActor('ct', node.getChild('....'))
		nodeChar = DB.findNode(rActor['sCreatureNode'])
	end

	if not rActor then
		rActor = ActorManager.getActor('pc', nodeChar)
	end

	return nodeChar, rActor
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
	local nodeChar, rActor = handleArgs(node)

	local tMentalScores = {}

	tMentalScores['cha'] = DB.getValue(nodeChar, 'abilities.charisma.score', 0)
	tMentalScores['wis'] = DB.getValue(nodeChar, 'abilities.wisdom.score', 0)
	tMentalScores['int'] = DB.getValue(nodeChar, 'abilities.intelligence.score', 0)

	tMentalScores['cha_effect'] = EffectManagerST.getEffectsBonus(rActor, 'CHA', true)
	tMentalScores['wis_effect'] = EffectManagerST.getEffectsBonus(rActor, 'WIS', true)
	tMentalScores['int_effect'] = EffectManagerST.getEffectsBonus(rActor, 'INT', true)

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