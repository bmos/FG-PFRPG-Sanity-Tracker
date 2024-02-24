--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals update save_string subtype
function onInit()
	update()
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode())

	if bReadOnly then
		local sSubtype = ""
		local sSave = ""

		if subtype.getValue() and subtype.getValue() ~= "" then
			sSubtype = string.format(" (%s)")
		end

		if savedc.getValue() and savedc.getValue() ~= 0 and savetype.getValue() and savetype.getValue() ~= "" then
			sSave = string.format("DC %s ")
		end
		if savetype.getValue() and savetype.getValue() ~= "" then
			sSave = sSave .. savetype.getValue()
		else
			sSave = "none"
		end

		severity_biglabel.setValue("[" .. severity_type.getValue() .. sSubtype .. "]")
		severity_biglabel.setVisible(true)
		severity_label.setVisible(false)
		severity_type_label.setVisible(false)
		severity_type.setVisible(false)

		save_string.setValue(sSave)
		save_string.setVisible(true)
		savetype.setVisible(false)
		savedc_label.setVisible(false)
		savedc.setVisible(false)
		saveroll.setVisible(true)

		severity_type.update(bReadOnly, true)
		subtype.update(bReadOnly, true)
	else
		severity_biglabel.setVisible(false)
		severity_label.setVisible(true)
		severity_type_label.setVisible(true)
		severity_type.setVisible(true)

		save_string.setVisible(false)
		savetype.setVisible(true)
		savedc_label.setVisible(true)
		savedc.setVisible(true)
		saveroll.setVisible(false)

		severity_type.update(bReadOnly)
		subtype.update(bReadOnly)
	end

	onset.update(bReadOnly)
	effect.update(bReadOnly)
	dormancy.update(bReadOnly)
	description.update(bReadOnly)
end
