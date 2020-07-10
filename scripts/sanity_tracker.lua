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
	end
end

---	Return a consistent value for nodePC and rActor.
--	This is accomplished by parsing node for a number of expected relationships.
--	@param node The databasenode to be queried for relationships.
--	@return nodePC This is the charsheet databasenode of the player character
--	@return rActor This is a table containing database paths and identifying data about the player character
local function handleArgs(node)
	local nodePC
	local rActor

	if node.getChild('...').getName() == 'charisma' then
		nodePC = node.getChild('....')
	elseif node.getChild('...').getName() == 'wisdom' then
		nodePC = node.getChild('....')
	elseif node.getChild('...').getName() == 'intelligence' then
		nodePC = node.getChild('....')
	elseif node.getChild('...').getName() == 'effects' then
		rActor = ActorManager.getActor('ct', node.getChild('....'))
		nodePC = DB.findNode(rActor['sCreatureNode'])
	end

	if not rActor then
		rActor = ActorManager.getActor("pc", nodePC)
	end

	return nodePC, rActor
end

---	Calculate total sanity score and write that value to the character's database node
--	@param node the initiating databasenode
function updateSanityScore(node)
	nodeChar, rActor = handleArgs(node)

	Debug.chat(nodeChar, rActor)
end