local _, ns = ...

local classColors = {
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
}

local function SetTilingArtwork(frame, bgFile, edgeFile, edgeSize, insets)
	if type(bgFile) == "table" and edgeFile == nil then --It's a wrapped table. Unwrap it!
		if bgFile.bgFile == nil and bgFile.edgeFile == nil then
			bgFile, edgeFile, edgeSize, insets = unpack(bgFile)
		else
			edgeFile = bgFile.edgeFile
			edgeSize = bgFile.edgeSize
			insets = bgFile.insets
			bgFile = bgFile.bgFile
		end
	end

	local tex = frame:CreateTexture(nil, "BACKGROUND")
	tex:SetTexture(bgFile, true, true)
	tex:SetVertTile(true)
	tex:SetHorizTile(true)
	tex:SetPoint("TOPLEFT", insets.left, -insets.top)
	tex:SetPoint("BOTTOMRIGHT", -insets.right, insets.bottom)
	frame.bgTex = tex

	frame:SetBackdrop({
		edgeFile = edgeFile,
		edgeSize = edgeSize,
		insets = insets
	})
end

local function CreateCheckBox(value, parent, point)
	local chk = CreateFrame("CheckButton", "CheckBox" .. value, parent, "ChatConfigCheckButtonTemplate")
	chk:SetPoint(unpack(point))
	chk.value = value

	chk:SetScript("OnClick", function(self)
		Store.Settings.Confines[self.value] = self:GetChecked()
	end)

	_G[chk:GetName() .. "Text"]:SetText(value)
	_G[chk:GetName() .. "Text"]:SetPoint("LEFT", chk, "RIGHT", parent.Margin, 0)
	_G[chk:GetName() .. "Text"]:SetPoint("RIGHT", parent, "RIGHT", -parent.Margin, 0)

	return chk
end

local function CreateButton(text, parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetHeight(25)
	btn:SetNormalFontObject(GameFontNormal)
	btn:SetText(text)

	btn.ntex = btn:CreateTexture()
	btn.ntex:SetTexture("Interface\\BUTTONS\\UI-Panel-Button-Up")
	btn.ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	btn.ntex:SetAllPoints()
	btn:SetNormalTexture(btn.ntex)

	btn.htex = btn:CreateTexture()
	btn.htex:SetTexture("Interface\\BUTTONS\\UI-Panel-Button-Highlight")
	btn.htex:SetTexCoord(0, 0.625, 0, 0.6875)
	btn.htex:SetAllPoints()
	btn:SetHighlightTexture(btn.htex)

	btn.dtex = btn:CreateTexture()
	btn.dtex:SetTexture("Interface\\BUTTONS\\UI-Panel-Button-Down")
	btn.dtex:SetTexCoord(0, 0.625, 0, 0.6875)
	btn.dtex:SetAllPoints()
	btn:SetPushedTexture(btn.dtex)

	return btn
end

local function CreateItemContainer(p1, p2)
	local frameHeight = 110
	local frame = CreateFrame("CheckButton", nil, ns.UI)
	frame:SetPoint(unpack(p1))
	frame:SetPoint(unpack(p2))
	frame:SetHeight(frameHeight)

	SetTilingArtwork(frame, {
		bgFile = "Interface\\FontStyles\\FontStyleParchment",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 80,
		edgeSize = 24,
		insets = { left = 6, right = 6, top = 6, bottom = 6 }})
	frame.bgTex:SetVertexColor(0.5, 0.5, 0.5)
	frame:SetBackdropBorderColor(0.227, 0.117, 0)

	frame.htex = frame:CreateTexture(nil, "ARTWORK")
	frame.htex:SetTexture("Interface\\CHATFRAME\\ChatFrameTab-NewMessage")
	frame.htex:SetTexCoord(0.05, 0.95, 0.25, 1)
	frame.htex:SetVertexColor(0.5, 0.5, 0, 0.25)
	frame.htex:SetPoint("TOPLEFT")
	frame.htex:SetPoint("TOPRIGHT")
	frame.htex:SetPoint("BOTTOM", 0, frame:GetBackdrop().insets.bottom)
	frame:SetHighlightTexture(frame.htex)

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

	hooksecurefunc(frame, "SetChecked", function(self)
		if self:GetChecked() then
			frame:SetBackdropBorderColor(1, 0.815, 0)
		else
			frame:SetBackdropBorderColor(0.227, 0.117, 0)
		end
	end)

	frame:SetScript("OnClick", function (self)
		if self:GetChecked() then
			frame:SetBackdropBorderColor(1, 0.815, 0)
		else
			frame:SetBackdropBorderColor(0.227, 0.117, 0)
		end
	end)

	return frame
end

ns.UI = CreateFrame("Frame", "AnsweringMachineUI", UIParent)
ns.UI.Controls = CreateFrame("Frame", nil, ns.UI)

ns.UI.ItemList = {}
ns.UI.ItemsShownAtATime = 5

--Spacing
ns.UI.Margin = 16
ns.UI.ItemMargin = 14
ns.UI.ItemSpacingVertical = 8
ns.UI.ItemSpacingHorizontal = 16
ns.UI.Controls.Margin = 8
ns.UI.Controls.Spacing = 8

function ns.UI:ShowUI()
	self:Update()
	self:Show()
end

function ns.UI:HideUI()
	self:Hide()
end

function ns.UI:ToggleUI()
	if self:IsShown() then
		self:HideUI()
	else
		self:ShowUI()
	end
end

function ns.UI:Update()
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

	if itemListCount == 0 then
		ns.UI.NoMessagesText:Show()
	elseif itemListCount > 0 then
		ns.UI.NoMessagesText:Hide()

		if itemListCount > ns.UI.ItemsShownAtATime then
			ns.UI.Scrollbar:SetMinMaxValues(1, itemListCount - ns.UI.ItemsShownAtATime + 1)
			ns.UI.Scrollbar:SetValue(1)
			ns.UI.Scrollbar:Show()
		else
			ns.UI.Scrollbar:SetMinMaxValues(1,1)
			ns.UI.Scrollbar:SetValue(1)
			ns.UI.Scrollbar:Hide()
		end

		for i = 1, ns.UI.ItemsShownAtATime do
			if i > itemListCount then
				ns.UI["Item" .. i]:Hide()
			else
				ns.UI["Item" .. i]:Show()
				ns.UI:PopulateItem(ns.UI["Item" .. i], ns.UI.ItemList[i])
			end
		end
	end
end

function ns.UI:ClearSelected()
	for i = 1, ns.UI.ItemsShownAtATime do
		self["Item" .. i]:SetChecked(false)
	end
end

function ns.UI:PopulateItem(item, msg)
	item.reference = msg
	item.Author:SetText("Author: |cFF" .. classColors[msg.authorClass] .. msg.author .. "|r")
	item.Recipient:SetText("Recipient: |cFF" .. classColors[msg.recipientClass] .. msg.recipient .. "|r")
	item.Timestamp:SetText(date("%Y-%m-%d %H:%M:%S", msg.timestamp))
	item.Rationale:SetText(msg.rationale)
	item.Msg:SetText(msg.msg)
end

--Window
tinsert(UISpecialFrames, ns.UI:GetName())
ns.UI:SetSize(800, 650)
ns.UI:SetPoint("CENTER")
ns.UI:SetMovable(true)
ns.UI:SetClampedToScreen(true)
ns.UI:EnableMouseWheel(true)

SetTilingArtwork(ns.UI, {
	bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 256,
	edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }})

ns.UI:SetScript("OnMouseWheel", function(self, delta)
	self:ClearSelected()
	ns.UI.Scrollbar:SetValue(ns.UI.Scrollbar:GetValue() - delta)
end)

-- Header
ns.UI.Header = CreateFrame("Frame", nil, ns.UI)
ns.UI.Header:SetSize(192, 48)
ns.UI.Header:SetPoint("TOP", 0, 16)
ns.UI.Header:RegisterForDrag("LeftButton")

ns.UI.Header.Texture = ns.UI.Header:CreateTexture(nil, "ARTWORK")
ns.UI.Header.Texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
ns.UI.Header.Texture:SetTexCoord(0.23, 0.77, 0, 0.63)
ns.UI.Header.Texture:SetAllPoints()

ns.UI.Header.Title = ns.UI.Header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.Header.Title:SetPoint("CENTER")
ns.UI.Header.Title:SetJustifyH("CENTER")
ns.UI.Header.Title:SetText("Answering Machine")

ns.UI.Header:SetScript("OnMouseDown", function(self)
	self:GetParent():StartMoving()
	self:GetParent():SetUserPlaced(false)
end)

ns.UI.Header:SetScript("OnMouseUp", function(self)
	self:GetParent():StopMovingOrSizing()
end)

-- No Messages
ns.UI.NoMessagesText = ns.UI:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.NoMessagesText:SetPoint("TOP", 0, -50)
ns.UI.NoMessagesText:SetJustifyH("CENTER")
ns.UI.NoMessagesText:SetJustifyV("CENTER")
ns.UI.NoMessagesText:SetText("No messages")

-- Controls
ns.UI.Controls:SetPoint("TOPLEFT", ns.UI.Margin, -ns.UI.Margin)
ns.UI.Controls:SetPoint("BOTTOMLEFT", ns.UI.Margin, ns.UI.Margin)
ns.UI.Controls:SetWidth(200)

SetTilingArtwork(ns.UI.Controls, {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 4 }})
ns.UI.Controls.bgTex:SetVertexColor(0.09, 0.09, 0.09)
ns.UI.Controls:SetBackdropBorderColor(0.5, 0.5, 0.5)

-- Controls.TimeToReply
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
	ns.UI:Update()
end)

-- Controls.BtnRemoveSelected
ns.UI.Controls.BtnRemoveSelected = CreateButton("Remove Selected", ns.UI.Controls)
ns.UI.Controls.BtnRemoveSelected:SetPoint("TOP", ns.UI.Controls.TimeToReplyEditBox, "BOTTOM", 0, -ns.UI.Controls.Spacing * 3)
ns.UI.Controls.BtnRemoveSelected:SetPoint("LEFT", ns.UI.Controls.Margin, 0)
ns.UI.Controls.BtnRemoveSelected:SetPoint("RIGHT", -ns.UI.Controls.Margin, 0)

ns.UI.Controls.BtnRemoveSelected:SetScript("OnClick", function()
	for i = 1, ns.UI.ItemsShownAtATime do
		if ns.UI["Item" .. i]:GetChecked() then
			ns.Controller:RemoveMsg(ns.UI["Item" .. i].reference)
		end
	end

	ns.UI:Update()
end)

-- Controls.ConfineTrackingTo
ns.UI.Controls.ConfineTrackingTo = ns.UI.Controls:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.UI.Controls.ConfineTrackingTo:SetPoint("TOP", ns.UI.Controls.BtnRemoveSelected, "BOTTOM", 0, -ns.UI.Controls.Spacing * 3)
ns.UI.Controls.ConfineTrackingTo:SetPoint("LEFT", ns.UI.Controls.Margin, 0)
ns.UI.Controls.ConfineTrackingTo:SetPoint("Right", -ns.UI.Controls.Margin, 0)
ns.UI.Controls.ConfineTrackingTo:SetJustifyH("LEFT")
ns.UI.Controls.ConfineTrackingTo:SetText("Confine Tracking To:")

ns.UI.Controls.ConfineAFK = CreateCheckBox("AFK", ns.UI.Controls, { "TOPLEFT", ns.UI.Controls.ConfineTrackingTo, "BOTTOMLEFT", 0, -ns.UI.Controls.Spacing })
ns.UI.Controls.ConfineDND = CreateCheckBox("DND", ns.UI.Controls, { "TOP", ns.UI.Controls.ConfineAFK, "BOTTOM" })
ns.UI.Controls.ConfineBattleground = CreateCheckBox("Battleground", ns.UI.Controls, { "TOP", ns.UI.Controls.ConfineDND, "BOTTOM" })
ns.UI.Controls.ConfineArena = CreateCheckBox("Arena", ns.UI.Controls, { "TOP", ns.UI.Controls.ConfineBattleground, "BOTTOM" })
ns.UI.Controls.ConfineDungeon = CreateCheckBox("Dungeon", ns.UI.Controls, { "TOP", ns.UI.Controls.ConfineArena, "BOTTOM" })
ns.UI.Controls.ConfineRaid = CreateCheckBox("Raid", ns.UI.Controls, { "TOP", ns.UI.Controls.ConfineDungeon, "BOTTOM" })
ns.UI.Controls.ConfineScenario = CreateCheckBox("Scenario", ns.UI.Controls, { "TOP", ns.UI.Controls.ConfineRaid, "BOTTOM" })

-- Controls.BtnClose
ns.UI.Controls.BtnClose = CreateButton("Close", ns.UI.Controls)
ns.UI.Controls.BtnClose:SetPoint("BOTTOM", 0, ns.UI.Controls.Margin)
ns.UI.Controls.BtnClose:SetPoint("LEFT", ns.UI.Controls.Margin, 0)
ns.UI.Controls.BtnClose:SetPoint("RIGHT", -ns.UI.Controls.Margin, 0)

ns.UI.Controls.BtnClose:SetScript("OnClick", function()
	ns.UI:HideUI()
end)

-- Scrollbar
ns.UI.Scrollbar = CreateFrame("Slider", nil, ns.UI, "UIPanelScrollBarTemplate")
ns.UI.Scrollbar:SetPoint("TOPRIGHT", -ns.UI.Margin, -ns.UI.Margin - 16)
ns.UI.Scrollbar:SetPoint("BOTTOMRIGHT", -ns.UI.Margin, ns.UI.Margin + 16)
ns.UI.Scrollbar:SetWidth(16)
ns.UI.Scrollbar:SetValueStep(1)

ns.UI.Scrollbar:SetScript("OnValueChanged", function(self, value)
	ns.UI:ClearSelected()

	for i = 1, ns.UI.ItemsShownAtATime do
		if ns.UI.ItemList[value + i - 1] ~= nil then
			ns.UI:PopulateItem(ns.UI["Item" .. i], ns.UI.ItemList[value + i - 1])
		else return end
	end
end)

ns.UI.Item1 = CreateItemContainer(
	{ "TOPLEFT", ns.UI.Controls, "TOPRIGHT", ns.UI.ItemSpacingHorizontal, -ns.UI.Margin - ns.UI.ItemSpacingVertical },
	{ "TOPRIGHT", ns.UI.Scrollbar, "TOPLEFT", -ns.UI.ItemSpacingHorizontal, -ns.UI.Margin - ns.UI.ItemSpacingVertical })
for i = 2, ns.UI.ItemsShownAtATime do
	ns.UI["Item" .. i] = CreateItemContainer(
		{ "TOPLEFT", ns.UI["Item" .. i - 1], "BOTTOMLEFT", 0, -ns.UI.ItemSpacingVertical },
		{ "TOPRIGHT", ns.UI["Item" .. i - 1], "BOTTOMRIGHT", 0, -ns.UI.ItemSpacingVertical })
end

SLASH_ANSWERINGMACHINE1 = '/am'
local function SlashCommandHandler(msg, editBox)
	ns.UI:ToggleUI()
end
SlashCmdList["ANSWERINGMACHINE"] = SlashCommandHandler