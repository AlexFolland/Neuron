--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

---@class ZONEABILITYBTN : BUTTON @define class ZONEABILITYBTN inherits from class BUTTON
local ZONEABILITYBTN = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ZONEABILITYBTN = ZONEABILITYBTN


----------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return ZONEABILITYBTN @ A newly created ZONEABILITYBTN object
function ZONEABILITYBTN:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")
	setmetatable(object, {__index = ZONEABILITYBTN})
	return object
end


----------------------------------------------------------

function ZONEABILITYBTN:SetType()

	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("SPELLS_CHANGED", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_CHARGES", "OnEvent")

	self:SetAttribute("type1", "macro")
	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)
	--macro content gets set in UpdateButton
	self:UpdateButton()

	self:SetScript("OnDragStart", function(self) PickupSpell(self.spellID) end)
	self:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	self:SetObjectVisibility()
	self:UpdateIcon()

	self:SetSkinned()
end


function ZONEABILITYBTN:LoadAux()

	Neuron.NeuronBinder:CreateBindFrame(self)
	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)
end


function ZONEABILITYBTN:OnEvent(event, ...)

	self:UpdateButton();
	self:SetObjectVisibility()

	if event == "PLAYER_ENTERING_WORLD" then
		Neuron.NeuronBinder:ApplyBindings(self)
	end
end

---overwrite function in parent class BUTTON
function ZONEABILITYBTN:UpdateButton()

	---update the ZoneAbility spell ID
	self.spellID = GetZoneAbilitySpellInfo();
	self.spellName, _, self.spellIcon = GetSpellInfo(self.spellID);

	if self.spellID then
		self:UpdateIcon()

		if (self.spellName and not InCombatLockdown()) then
			self:SetAttribute("macrotext1", "/cast " .. self.spellName .. "();")
		end

		self:SetSpellCooldown(self.spellID)

		---zone ability button charges (I'm not sure if zone abilities have charges, but this is just in case)
		self:UpdateSpellCount(self.spellID)
	end

	---make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()

end


function ZONEABILITYBTN:SetObjectVisibility(show)

	if (GetZoneAbilitySpellInfo() or show) then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self:SetAlpha(1)
	elseif not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then
		self:SetAlpha(0)
	end
end


---overwrite function in parent class BUTTON
function ZONEABILITYBTN:UpdateIcon()
	self:SetButtonTex()
end

function ZONEABILITYBTN:SetButtonTex()

	self.iconframeicon:SetTexture(self.spellIcon);

	local texture = ZONE_SPELL_ABILITY_TEXTURES_BASE[self.spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK
	self.style:SetTexture(texture)
	self.style:Show() --this actually show/hide the fancy button theme surrounding the bar. If you wanted to do a toggle for the style, it should be here.
end

function ZONEABILITYBTN:OnEnter(...)

	if (self.bar) then
		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (self.tooltips) then

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

			if (self.tooltipsEnhanced and self.spellID) then
				GameTooltip:SetSpellByID(self.spellID)
			elseif (self.spellName) then
				GameTooltip:SetText(self.spellName)
			end

			GameTooltip:Show()
		end
	end
end