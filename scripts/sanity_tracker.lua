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
--		DB.addHandler(DB.getPath('combattracker.list.*.effects'), 'onChildDeleted', updateSanityScore)
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
	elseif node.getChild('...').getName() == 'effects' then
		rActor = ActorManager.getActor('ct', node.getChild('....'))
		nodeChar = DB.findNode(rActor['sCreatureNode'])
	end

	if not rActor then
		rActor = ActorManager.getActor("pc", nodeChar)
	end

	return nodeChar, rActor
end

---	Calculate total sanity score and write that value to the character's database node
--	@param node the initiating databasenode
function updateSanityScore(node)
	local nodeChar, rActor = handleArgs(node)

	Debug.chat(nodeChar, rActor)
end