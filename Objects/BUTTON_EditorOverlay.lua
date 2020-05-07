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
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2019.


---The functions in this file are part of the ACTIONBUTTON class.
---It was just easier to put them all in their own file for organization.

local BUTTON = Neuron.BUTTON

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


----------------------------------------------------------------------------
--------------------------Button Editor Overlay-----------------------------
----------------------------------------------------------------------------

function BUTTON:EditorOverlay_CreateEditFrame()
	local editFrame = CreateFrame("Button", self:GetName().."EditFrame", self, "NeuronOverlayFrameTemplate")
	setmetatable(editFrame, { __index = CreateFrame("Button") })

	editFrame:EnableMouseWheel(true)
	editFrame:RegisterForClicks("AnyDown")
	editFrame:SetAllPoints(self)
	editFrame:SetScript("OnShow", function() self:EditorOverlay_OnShow() end)
	editFrame:SetScript("OnEnter", function() self:EditorOverlay_OnEnter() end)
	editFrame:SetScript("OnLeave", function() self:EditorOverlay_OnLeave() end)
	editFrame:SetScript("OnClick", function(_, btn) self:EditorOverlay_OnClick(btn) end)

	editFrame.label:SetText(L["Edit"])

	if self.objType == "ACTIONBUTTON" then
		editFrame.select.Left:SetTexture("")
		editFrame.select.Right:SetTexture("")
	else
		editFrame.select.Left:ClearAllPoints()
		editFrame.select.Left:SetPoint("RIGHT", editFrame.select, "LEFT", 4, 0)
		editFrame.select.Left:SetTexture("Interface\\AddOns\\Neuron\\Images\\flyout.tga")
		editFrame.select.Left:SetTexCoord(0.71875, 1, 0, 1)
		editFrame.select.Left:SetWidth(16)
		editFrame.select.Left:SetHeight(55)

		editFrame.select.Right:ClearAllPoints()
		editFrame.select.Right:SetPoint("LEFT", editFrame.select, "RIGHT", -4, 0)
		editFrame.select.Right:SetTexture("Interface\\AddOns\\Neuron\\Images\\flyout.tga")
		editFrame.select.Right:SetTexCoord(0, 0.28125, 0, 1)
		editFrame.select.Right:SetWidth(16)
		editFrame.select.Right:SetHeight(55)

		editFrame.select.Reticle:SetTexture("")
	end

	self.editFrame = editFrame

	editFrame:Hide()
end

function BUTTON:EditorOverlay_OnShow()
end

function BUTTON:EditorOverlay_OnEnter()
	self.editFrame.select:Show()
	GameTooltip:SetOwner(self.editFrame, "ANCHOR_RIGHT")
	GameTooltip:Show()
end

function BUTTON:EditorOverlay_OnLeave()
	if self ~= Neuron.currentButton then
		self.editFrame.select:Hide()
	end
	GameTooltip:Hide()
end

function BUTTON:EditorOverlay_OnClick()
	Neuron.BUTTON.ChangeSelectedButton(self)
	if NeuronEditor then
		Neuron.NeuronGUI:RefreshEditor()
	end
end