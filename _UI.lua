local _, ns = ...

--Window
ns.UI = CreateFrame("Frame", "AnsweringMachineUI", UIParent)
tinsert(UISpecialFrames,"AnsweringMachineUI");
ns.UI:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
ns.UI:SetSize(800, 650)
ns.UI:SetPoint("CENTER")
ns.UI:SetMovable(true)
ns.UI:SetClampedToScreen(true)
ns.UI:EnableMouseWheel(true)
ns.UI:SetScript("OnMouseWheel", function(self, delta)
	ns.UI.Scrollbar:SetValue(ns.UI.Scrollbar:GetValue() - delta)
end)
ns.UI.Margin = 16
ns.UI.ItemSpacingVertical = 8
ns.UI.ItemSpacingHorizontal = 16
ns.UI.ItemMargin = 8
ns.UI.ItemsShownAtATime = 5
ns.UI.ItemList = {}
-- ns.UI.ClassColors = {
-- 	DEATHKNIGHT = { 0.77, 0.12, 0.23 },
-- 	DEMONHUNTER = { 0.64, 0.19, 0.79 },
-- 	DRUID = { 1.00, 0.49, 0.04 },
-- 	HUNTER = { 0.67, 0.83, 0.45 },
-- 	MAGE = { 0.41, 0.80, 0.94 },
-- 	MONK = { 0.00, 1.00, 0.59 },
-- 	PALADIN = { 0.96, 0.55, 0.73 },
-- 	PRIEST = { 1.00, 1.00, 1.00 },
-- 	ROGUE = { 1.00, 0.96, 0.41 },
-- 	SHAMAN = { 0.00, 0.44, 0.87 },
-- 	WARLOCK = { 0.58, 0.51, 0.79 },
-- 	WARRIOR = { 0.78, 0.61, 0.43 }
-- }
ns.UI.ClassColors = {
	DEATHKNIGHT = "C41F3B",
	DEMONHUNTER = "A330C9",
	DRUID = "FF7D0A",
	HUNTER = "ABD473",
	MAGE = "69CCF0",
	MONK = "00FF96",
	PALADIN = "F58CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF569",
	SHAMAN = "0070DE",
	WARLOCK = "9482C9",
	WARRIOR = "C79C6E",

	BNET = "00FFFF"
}
ns.UI:Hide()

function ns.UI:ShowUI()
	ns.UI:Invalidate()
	ns.UI:Show()
end

function ns.UI:HideUI()
	ns.UI:Hide()
end

function ns.UI:ToggleUI()
	if ns.UI:IsShown() then
		ns.UI:HideUI()
	else
		ns.UI:ShowUI()
	end
end

function ns.UI:ClearSelected()
	for i = 1, ns.UI.ItemsShownAtATime, 1 do
		ns.UI["Item" .. i].selected = true
		ns.UI.ItemOnClick(ns.UI["Item" .. i])
	end
end

function ns.UI:PopulateItem(item, msg)
	item.reference = msg
	item.Author:SetText("Author: |cFF" .. self.ClassColors[msg.authorClass] .. msg.author .. "|r")
	item.Recipient:SetText("Recipient: |cFF" .. self.ClassColors[msg.recipientClass] .. msg.recipient .. "|r")
	item.Timestamp:SetText(date("%Y-%m-%d %H:%M:%S", msg.timestamp))
	item.Rationale:SetText(msg.rationale)
	item.Msg:SetText(msg.msg)
end

function ns.UI:OnScrollValueChanged(value)
	ns.UI:ClearSelected()

	for i = 1, ns.UI.ItemsShownAtATime, 1 do
		if ns.UI.ItemList[value + i - 1] ~= nil then
			ns.UI:PopulateItem(ns.UI["Item" .. i], ns.UI.ItemList[value + i - 1])
		else return end
	end
end

function ns.UI.Invalidate()
	ns.UI.Controls.TimeToReplyEditBox:SetText(Store.Settings.timeToReply)
	ns.UI.Controls.ConfineAFK:SetChecked(Store.Settings.Confines.AFK)
	ns.UI.Controls.ConfineDND:SetChecked(Store.Settings.Confines.DND)
	ns.UI.Controls.ConfineBattleground:SetChecked(Store.Settings.Confines.Battleground)
	ns.UI.Controls.ConfineArena:SetChecked(Store.Settings.Confines.Arena)
	ns.UI.Controls.ConfineDungeon:SetChecked(Store.Settings.Confines.Dungeon)
	ns.UI.Controls.ConfineRaid:SetChecked(Store.Settings.Confines.Raid)
	ns.UI.Controls.ConfineScenario:SetChecked(Store.Settings.Confines.Scenario)

	wipe(ns.UI.ItemList)

	for _,v in pairs(Store.Messages) do
		table.insert(ns.UI.ItemList, v)
	end

	for _,v in pairs(ns.Controller.recentMessages) do
		table.insert(ns.UI.ItemList, v)
	end

	table.sort(ns.UI.ItemList, function(a, b)
		return a.timestamp < b.timestamp
	end)

	ns.UI:ClearSelected()

	local itemListCount = #ns.UI.ItemList
	for i = 1, ns.UI.ItemsShownAtATime, 1 do
		ns.UI["Item" .. i]:Show()
	end

	if itemListCount <= ns.UI.ItemsShownAtATime then
		ns.UI.Scrollbar:Hide()
		ns.UI:OnScrollValueChanged(1)

		if itemListCount < ns.UI.ItemsShownAtATime then
			for i = itemListCount + 1, ns.UI.ItemsShownAtATime, 1 do
				ns.UI["Item" .. i]:Hide()
			end
		end

		if itemListCount == 0 then
			ns.UI.NoMessagesText:Show()
		else
			ns.UI.NoMessagesText:Hide()
		end
	else
		ns.UI.Scrollbar:SetMinMaxValues(1, itemListCount - ns.UI.ItemsShownAtATime + 1)
		ns.UI.Scrollbar:SetValue(1)
		ns.UI:OnScrollValueChanged(1)
		ns.UI.Scrollbar:Show()

		ns.UI.NoMessagesText:Hide()
	end
end

function ns.UI:OnCheckedChanged()
	Store.Settings.Confines[self.value] = self:GetChecked()
end

--Header
ns.UI.Header = CreateFrame("Frame", nil, ns.UI)
ns.UI.Header:SetSize(192, 48)
ns.UI.Header:SetPoint("TOP", 0, 16)

function ns.UI.Header:OnMouseDown()
	self:GetParent():StartMoving()
	self:GetParent():SetUserPlaced(false)
end

function ns.UI.Header:OnMouseUp()
	self:GetParent():StopMovingOrSizing()
end

ns.UI.Header:RegisterForDrag("LeftButton")
ns.UI.Header:SetScript("OnMouseDown", ns.UI.Header.OnMouseDown)
ns.UI.Header:SetScript("OnMouseUp", ns.UI.Header.OnMouseUp)

ns.UI.Header.Texture = ns.UI.Header:CreateTexture(nil, "ARTWORK")
ns.UI.Header.Texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
ns.UI.Header.Texture:SetTexCoord(0.23, 0.77, 0, 0.63)
ns.UI.Header.Texture:SetAllPoints()

ns.UI.Header.Title = ns.UI.Header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.Header.Title:SetPoint("CENTER")
ns.UI.Header.Title:SetJustifyH("CENTER")
ns.UI.Header.Title:SetText("Answering Machine")

--No Messages
ns.UI.NoMessagesText = ns.UI:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.NoMessagesText:SetPoint("TOP", 0, -50)
ns.UI.NoMessagesText:SetJustifyH("CENTER")
ns.UI.NoMessagesText:SetJustifyV("CENTER")
ns.UI.NoMessagesText:SetText("No messages")

--Controls
ns.UI.Controls = CreateFrame("Frame", nil, ns.UI)
ns.UI.Controls.Margin = 8
ns.UI.Controls.Spacing = 8
ns.UI.Controls:SetPoint("TOPLEFT", ns.UI.Margin, -ns.UI.Margin)
ns.UI.Controls:SetPoint("BOTTOMRIGHT", ns.UI, "BOTTOMLEFT", ns.UI.Margin + 200, ns.UI.Margin)
ns.UI.Controls:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 4
    }
})
ns.UI.Controls:SetBackdropColor(0.09, 0.09, 0.09)
ns.UI.Controls:SetBackdropBorderColor(0.5, 0.5, 0.5)

--Controls.TimeToReply
ns.UI.Controls.TimeToReplyText = ns.UI.Controls:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.Controls.TimeToReplyText:SetPoint("TOP", 0, -ns.UI.Controls.Margin - ns.UI.Controls.Spacing)
ns.UI.Controls.TimeToReplyText:SetJustifyH("CENTER")
ns.UI.Controls.TimeToReplyText:SetText("Time to reply (in sec):")

ns.UI.Controls.TimeToReplyEditBox = CreateFrame("EditBox", nil, ns.UI.Controls, "InputBoxTemplate")
ns.UI.Controls.TimeToReplyEditBox:SetPoint("TOP", ns.UI.Controls.TimeToReplyText, "BOTTOM", 0, -ns.UI.Controls.Spacing)
ns.UI.Controls.TimeToReplyEditBox:SetPoint("LEFT", ns.UI.Controls.Margin + 8, 0)
ns.UI.Controls.TimeToReplyEditBox:SetPoint("RIGHT", -ns.UI.Controls.Margin, 0)
ns.UI.Controls.TimeToReplyEditBox:SetHeight(20)
ns.UI.Controls.TimeToReplyEditBox:SetFontObject(GameFontWhite)
ns.UI.Controls.TimeToReplyEditBox:SetAutoFocus(false)
ns.UI.Controls.TimeToReplyEditBox:SetNumeric(true)
ns.UI.Controls.TimeToReplyEditBox:SetJustifyH("CENTER")
ns.UI.Controls.TimeToReplyEditBox:SetScript("OnEnterPressed", function(self)
	Store.Settings.timeToReply = self:GetNumber()
	self:ClearFocus()
	ns.UI.Invalidate()
end)

--Controls.BtnRemoveSelected
ns.UI.Controls.BtnRemoveSelected = CreateFrame("Button", nil, ns.UI.Controls)
ns.UI.Controls.BtnRemoveSelected:SetPoint("TOP", ns.UI.Controls.TimeToReplyEditBox, "BOTTOM", 0, -ns.UI.Controls.Spacing * 3)
ns.UI.Controls.BtnRemoveSelected:SetPoint("LEFT", ns.UI.Controls.Margin, 0)
ns.UI.Controls.BtnRemoveSelected:SetPoint("RIGHT", -ns.UI.Controls.Margin, 0)
ns.UI.Controls.BtnRemoveSelected:SetHeight(25)
ns.UI.Controls.BtnRemoveSelected:SetNormalFontObject(GameFontNormal)
ns.UI.Controls.BtnRemoveSelected:SetText("Remove Selected")
ns.UI.Controls.BtnRemoveSelected:SetScript("OnClick", function()
	for i = 1, ns.UI.ItemsShownAtATime, 1 do
		if ns.UI["Item" .. i].selected then
			ns.Controller:RemoveMsg(ns.UI["Item" .. i].reference)
		end
	end

	ns.UI.Invalidate()
end)

ns.UI.Controls.BtnRemoveSelected.ntex = ns.UI.Controls.BtnRemoveSelected:CreateTexture()
ns.UI.Controls.BtnRemoveSelected.ntex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
ns.UI.Controls.BtnRemoveSelected.ntex:SetTexCoord(0, 0.625, 0, 0.6875)
ns.UI.Controls.BtnRemoveSelected.ntex:SetAllPoints()
ns.UI.Controls.BtnRemoveSelected:SetNormalTexture(ns.UI.Controls.BtnRemoveSelected.ntex)

ns.UI.Controls.BtnRemoveSelected.htex = ns.UI.Controls.BtnRemoveSelected:CreateTexture()
ns.UI.Controls.BtnRemoveSelected.htex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
ns.UI.Controls.BtnRemoveSelected.htex:SetTexCoord(0, 0.625, 0, 0.6875)
ns.UI.Controls.BtnRemoveSelected.htex:SetAllPoints()
ns.UI.Controls.BtnRemoveSelected:SetHighlightTexture(ns.UI.Controls.BtnRemoveSelected.htex)

ns.UI.Controls.BtnRemoveSelected.ptex = ns.UI.Controls.BtnRemoveSelected:CreateTexture()
ns.UI.Controls.BtnRemoveSelected.ptex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
ns.UI.Controls.BtnRemoveSelected.ptex:SetTexCoord(0, 0.625, 0, 0.6875)
ns.UI.Controls.BtnRemoveSelected.ptex:SetAllPoints()
ns.UI.Controls.BtnRemoveSelected:SetPushedTexture(ns.UI.Controls.BtnRemoveSelected.ptex)

--Controls.ConfineTrackingTo
ns.UI.Controls.ConfineTrackingTo = ns.UI.Controls:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.Controls.ConfineTrackingTo:SetPoint("TOP", ns.UI.Controls.BtnRemoveSelected, "BOTTOM", 0, -ns.UI.Controls.Spacing * 3)
ns.UI.Controls.ConfineTrackingTo:SetPoint("LEFT", ns.UI.Controls.Margin, 0)
ns.UI.Controls.ConfineTrackingTo:SetPoint("RIGHT", -ns.UI.Controls.Margin, 0)
ns.UI.Controls.ConfineTrackingTo:SetJustifyH("LEFT")
ns.UI.Controls.ConfineTrackingTo:SetText("Confine Tracking To:")

local function CreateCheckBox(value, point)
	local chk = CreateFrame("CheckButton", "AMConfine" .. value, ns.UI.Controls, "ChatConfigCheckButtonTemplate")
	chk:SetPoint(unpack(point))
	chk.value = value
	chk:SetScript("OnClick", ns.UI.OnCheckedChanged)

	_G[chk:GetName() .. "Text"]:SetText(value)
	_G[chk:GetName() .. "Text"]:SetPoint("LEFT", chk, "RIGHT", ns.UI.Controls.Margin, 0)
	_G[chk:GetName() .. "Text"]:SetPoint("RIGHT", ns.UI.Controls, "RIGHT", -ns.UI.Controls.Margin, 0)

	return chk
end

ns.UI.Controls.ConfineAFK = CreateCheckBox("AFK", { "TOPLEFT", ns.UI.Controls.ConfineTrackingTo, "BOTTOMLEFT", 0, -ns.UI.Controls.Spacing })
ns.UI.Controls.ConfineDND = CreateCheckBox("DND", { "TOP", ns.UI.Controls.ConfineAFK, "BOTTOM" })
ns.UI.Controls.ConfineBattleground = CreateCheckBox("Battleground", { "TOP", ns.UI.Controls.ConfineDND, "BOTTOM" })
ns.UI.Controls.ConfineArena = CreateCheckBox("Arena", { "TOP", ns.UI.Controls.ConfineBattleground, "BOTTOM" })
ns.UI.Controls.ConfineDungeon = CreateCheckBox("Dungeon", { "TOP", ns.UI.Controls.ConfineArena, "BOTTOM" })
ns.UI.Controls.ConfineRaid = CreateCheckBox("Raid", { "TOP", ns.UI.Controls.ConfineDungeon, "BOTTOM" })
ns.UI.Controls.ConfineScenario = CreateCheckBox("Scenario", { "TOP", ns.UI.Controls.ConfineRaid, "BOTTOM" })

--Controls.BtnClose
ns.UI.Controls.BtnClose = CreateFrame("Button", nil, ns.UI.Controls)
ns.UI.Controls.BtnClose:SetPoint("BOTTOM", 0, ns.UI.Controls.Margin)
ns.UI.Controls.BtnClose:SetPoint("LEFT", ns.UI.Controls.Margin, 0)
ns.UI.Controls.BtnClose:SetPoint("RIGHT", -ns.UI.Controls.Margin, 0)
ns.UI.Controls.BtnClose:SetHeight(25)
ns.UI.Controls.BtnClose:SetNormalFontObject(GameFontNormal)
ns.UI.Controls.BtnClose:SetText("Close")
ns.UI.Controls.BtnClose:SetScript("OnClick", ns.UI.HideUI)

ns.UI.Controls.BtnClose.ntex = ns.UI.Controls.BtnClose:CreateTexture()
ns.UI.Controls.BtnClose.ntex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
ns.UI.Controls.BtnClose.ntex:SetTexCoord(0, 0.625, 0, 0.6875)
ns.UI.Controls.BtnClose.ntex:SetAllPoints()
ns.UI.Controls.BtnClose:SetNormalTexture(ns.UI.Controls.BtnClose.ntex)

ns.UI.Controls.BtnClose.htex = ns.UI.Controls.BtnClose:CreateTexture()
ns.UI.Controls.BtnClose.htex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
ns.UI.Controls.BtnClose.htex:SetTexCoord(0, 0.625, 0, 0.6875)
ns.UI.Controls.BtnClose.htex:SetAllPoints()
ns.UI.Controls.BtnClose:SetHighlightTexture(ns.UI.Controls.BtnClose.htex)

ns.UI.Controls.BtnClose.ptex = ns.UI.Controls.BtnClose:CreateTexture()
ns.UI.Controls.BtnClose.ptex:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
ns.UI.Controls.BtnClose.ptex:SetTexCoord(0, 0.625, 0, 0.6875)
ns.UI.Controls.BtnClose.ptex:SetAllPoints()
ns.UI.Controls.BtnClose:SetPushedTexture(ns.UI.Controls.BtnClose.ptex)

--Scrollbar
ns.UI.Scrollbar = CreateFrame("Slider", nil, ns.UI, "UIPanelScrollBarTemplate")
ns.UI.Scrollbar:SetPoint("TOPRIGHT", ns.UI, "TOPRIGHT", -ns.UI.Margin, -ns.UI.Margin - 16)
ns.UI.Scrollbar:SetPoint("BOTTOMRIGHT", ns.UI, "BOTTOMRIGHT", -ns.UI.Margin, ns.UI.Margin + 16)
ns.UI.Scrollbar:SetWidth(16)
ns.UI.Scrollbar:SetValueStep(1)
ns.UI.Scrollbar:SetScript("OnValueChanged", ns.UI.OnScrollValueChanged)

--Items
function ns.UI.ItemOnClick(item)
	if item.selected then
		item:SetBackdropColor(0.09, 0.09, 0.09)
		item:SetBackdropBorderColor(1.00, 1.00, 1.00)
		item.selected = false
	else
		item:SetBackdropColor(0.00, 0.3, 0.3)
		item:SetBackdropBorderColor(0.00, 1.00, 1.00)
		item.selected = true
	end
end

local function CreateItemFrame(p1, p2, backdrop)
	local frame = CreateFrame("Frame", nil, ns.UI)
	frame:SetPoint(unpack(p1))
	frame:SetPoint(unpack(p2))
	frame:SetHeight(110)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0.09, 0.09, 0.09)
	frame.selected = false
	frame:SetScript("OnMouseDown", ns.UI.ItemOnClick)

	frame.Author = frame:CreateFontString(nil, "ARTWORK", "SystemFont_Huge1")
	frame.Author:SetPoint("TOPLEFT", ns.UI.ItemMargin, -ns.UI.ItemMargin)
	frame.Author:SetPoint("TOPRIGHT", frame, "TOP", 0, -ns.UI.ItemMargin)
	frame.Author:SetJustifyH("LEFT")

	frame.Recipient = frame:CreateFontString(nil, "ARTWORK", "SystemFont_Med3")
	frame.Recipient:SetPoint("LEFT", frame.Author, "RIGHT", ns.UI.ItemMargin, 0)
	frame.Recipient:SetPoint("TOPRIGHT", -ns.UI.ItemMargin, -ns.UI.ItemMargin)
	frame.Recipient:SetJustifyH("RIGHT")

	frame.Timestamp = frame:CreateFontString(nil, "ARTWORK", "SystemFont_Small")
	frame.Timestamp:SetPoint("TOPLEFT", frame.Author, "BOTTOMLEFT", 0, -4)
	frame.Timestamp:SetPoint("TOPRIGHT", frame.Author, "BOTTOMRIGHT", 0, -4)
	frame.Timestamp:SetJustifyH("LEFT")

	frame.Rationale = frame:CreateFontString(nil, "ARTWORK", "SystemFont_Small")
	frame.Rationale:SetPoint("TOPLEFT", frame.Recipient, "BOTTOMLEFT", 0, -4)
	frame.Rationale:SetPoint("TOPRIGHT", frame.Recipient, "BOTTOMRIGHT", 0, -4)
	frame.Rationale:SetJustifyH("RIGHT")

	frame.Msg = frame:CreateFontString(nil, "ARTWORK", "SystemFont_Med3")
	frame.Msg:SetPoint("TOPLEFT", frame.Timestamp, "BOTTOMLEFT", 0, -ns.UI.ItemMargin)
	frame.Msg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -ns.UI.ItemMargin, ns.UI.ItemMargin)
	frame.Msg:SetJustifyH("LEFT")

	return frame
end

ns.UI.Item1 = CreateItemFrame(
	{ "TOPLEFT", ns.UI.Controls, "TOPRIGHT", ns.UI.ItemSpacingHorizontal, -ns.UI.Margin - ns.UI.ItemSpacingVertical },
	{ "TOPRIGHT", ns.UI.Scrollbar, "TOPLEFT", -ns.UI.ItemSpacingHorizontal, -ns.UI.Margin - ns.UI.ItemSpacingVertical },
	{ 
	  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = { left = 5, right = 5, top = 5, bottom = 4 }
    }
)
for i = 2, ns.UI.ItemsShownAtATime, 1 do
	ns.UI["Item" .. i] = CreateItemFrame(
		{ "TOPLEFT", ns.UI["Item" .. i - 1], "BOTTOMLEFT", 0, -ns.UI.ItemMargin },
		{ "TOPRIGHT", ns.UI["Item" .. i - 1], "BOTTOMRIGHT", 0, -ns.UI.ItemMargin },
		ns.UI.Item1:GetBackdrop())
end

SLASH_ANSWERINGMACHINE1 = '/am'
local function SlashCommandHandler(msg, editBox)
	ns.UI:ToggleUI()
end
SlashCmdList["ANSWERINGMACHINE"] = SlashCommandHandler