--Neuron, a World of Warcraft® user interface addon.

---Class BAGBTN inherits from class BUTTON
---@class BAGBTN : BUTTON
local BAGBTN = setmetatable({}, {__index = Neuron.BUTTON})
Neuron.BAGBTN = BAGBTN

local SKIN = LibStub("Masque", true)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local bagElements = {CharacterBag3Slot, CharacterBag2Slot, CharacterBag1Slot, CharacterBag0Slot, MainMenuBarBackpackButton}



---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return BUTTON @ A newly created BUTTON object
function BAGBTN:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronAnchorButtonTemplate")
	setmetatable(object, {__index = BAGBTN})
	return object
end

-------------------------------------------------
-----Base Methods that all buttons have----------
---These will often be overwritten per bar type--
------------------------------------------------

function BAGBTN:SetSkinned()

	if (SKIN) then

		local bar = self.bar

		if (bar) then
			local btnData = {
				Normal = self.normaltexture,
				Icon = self.icontexture,
				Count = self.count,
			}


			SKIN:Group("Neuron", bar.data.name):AddButton(self, btnData)

			self.skinned = true

			Neuron.SKINIndex[self] = true
		end
	end
end

function BAGBTN:SetData(bar)

	if (bar) then

		self.bar = bar

		self:SetFrameStrata(bar.data.objectStrata)
		self:SetScale(bar.data.scale)

	end

	self:SetFrameLevel(4)
end

function BAGBTN:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if not DB.bagbtn[id] then
		DB.bagbtn[id] = {}
	end

	self.DB = DB.bagbtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data
end


function BAGBTN:SetType(save)

	if (bagElements[self.id]) then

		if self.id == 5 then --this corrects for some large ass margins on the main backpack button
			self:SetWidth(bagElements[self.id]:GetWidth()-5)
			self:SetHeight(bagElements[self.id]:GetHeight()-5)
		else
			self:SetWidth(bagElements[self.id]:GetWidth()+3)
			self:SetHeight(bagElements[self.id]:GetHeight()+3)
		end

		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = bagElements[self.id]

		local objects = Neuron:GetParentKeys(self.element)

		for k,v in pairs(objects) do
			local name = v:gsub(self.element:GetName(), "")
			self[name:lower()] = _G[v]
		end

		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("CENTER", self, "CENTER")
		self.element:SetScale(1)

		self:SetSkinned()
	end
end