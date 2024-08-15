--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals onValueChanged
function onInit()
	onValueChanged()
end

function onValueChanged()
	local nodeSanity = DB.getParent(getDatabaseNode())
	local nSanityDamage = DB.getValue(nodeSanity, "damage", 0)
	local nSanityEdge = DB.getValue(nodeSanity, "edge", 0)

	if nSanityDamage ~= 0 and nSanityDamage >= nSanityEdge then
		window.sanitydamage.setColor(ColorManager.getUIColor("health_wounds_critical"))
	else
		window.sanitydamage.setColor(ColorManager.getUIColor("usage_full"))
	end
end
