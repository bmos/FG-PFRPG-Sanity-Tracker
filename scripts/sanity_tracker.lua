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

---	Return a consistent value for nodeChar and rActor.
--	This is accomplished by parsing node for a number of expected relationships.
--	@param node The databasenode to be queried for relationships.
--	@return nodeChar This is the charsheet databasenode of the player character
--	@return rActor This is a table containing database paths and identifying data about the player character
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
		rActor = ActorManager.getActor("pc", nodeChar)
	end

	return nodeChar, rActor
end

---	Calculate the sums of all values in a table
--	@param t A table containing numbers
--	@return nSum The sum of all values in table t
function tableSum(t)
	local nSum = 0

	for _,v in pairs(t) do
		nSum = nSum + v
	end

	return nSum
end

---	Calculate total sanity score and write that value to the character's database node
--	@param node the initiating databasenode
function updateSanityScore(node)
	local nodeChar, rActor = handleArgs(node)

	local tMentalScores = {}

	tMentalScores['cha'] = DB.getValue(nodeChar, 'abilities.charisma.score', nil)
	tMentalScores['wis'] = DB.getValue(nodeChar, 'abilities.wisdom.score', nil)
	tMentalScores['int'] = DB.getValue(nodeChar, 'abilities.intelligence.score', nil)

	tMentalScores['cha_effect'] = EffectManagerST.getEffectsBonus(rActor, 'CHA', true)
	tMentalScores['wis_effect'] = EffectManagerST.getEffectsBonus(rActor, 'WIS', true)
	tMentalScores['int_effect'] = EffectManagerST.getEffectsBonus(rActor, 'INT', true)

	tMentalScores['cha_dmg'] = -1 * DB.getValue(nodeChar, 'abilities.charisma.damage', nil)
	tMentalScores['wis_dmg'] = -1 * DB.getValue(nodeChar, 'abilities.wisdom.damage', nil)
	tMentalScores['int_dmg'] = -1 * DB.getValue(nodeChar, 'abilities.intelligence.damage', nil)

	local nSanityScore = tableSum(tMentalScores)
	local nSanityEdge = (nSanityScore / 2) - (nSanityScore / 2) % 1

	DB.setValue(nodeChar, 'sanity.score', 'number', nSanityScore)
	DB.setValue(nodeChar, 'sanity.edge', 'number', nSanityEdge)
end