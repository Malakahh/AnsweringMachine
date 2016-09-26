local _, ns = ...

--Window
ns.UI = CreateFrame("Frame", "AnsweringMachineUI", UIParent)
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
	WARRIOR = "C79C6E"
}
ns.UI:Hide()

function ns.UI:ShowUI()
	ns.UI:Invalidate()
	ns.UI:Show()
end

function ns.UI:HideUI()
	ns.UI:Hide()
end

function ns.UI:PopulateItem(item, msg)
	item.Author:SetText("Author: |cFF" .. self.ClassColors[msg.authorClass] .. msg.author .. "|r")
	item.Recipient:SetText("Recipient: |cFF" .. self.ClassColors[msg.recipientClass] .. msg.recipient .. "|r")
	item.Timestamp:SetText(date("%Y-%m-%d %H:%M:%S", msg.timestamp))
	item.Rationale:SetText(msg.rationale)
	item.Msg:SetText(msg.msg)
end

function ns.UI:OnScrollValueChanged(value)
	for i = 1, ns.UI.ItemsShownAtATime, 1 do
		if ns.UI.ItemList[value + i - 1] ~= nil then
			ns.UI:PopulateItem(ns.UI["Item" .. i], ns.UI.ItemList[value + i - 1])
		else return end
	end
end

function ns.UI.Invalidate()
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

	local itemListCount = #ns.UI.ItemList

	print("#: " .. itemListCount)

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
		ns.UI.Scrollbar:Show()

		no.UI.NoMessagesText:Hide()
	end
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

ns.UI.Controls.BtnClose = CreateFrame("Button", nil, ns.UI.Controls)
ns.UI.Controls.BtnClose:SetPoint("BOTTOM", 0, ns.UI.Controls.Margin)
ns.UI.Controls.BtnClose:SetSize(116, 25)
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
function ns.UI:ItemOnClick()
	if self.selected then
		self:SetBackdropColor(0.09, 0.09, 0.09)
		self:SetBackdropBorderColor(1.00, 1.00, 1.00)
		self.selected = false
	else
		self:SetBackdropColor(0.00, 0.3, 0.3)
		self:SetBackdropBorderColor(0.00, 1.00, 1.00)
		self.selected = true
	end
end

--Item1
ns.UI.Item1 = CreateFrame("Frame", nil, ns.UI)
ns.UI.Item1:SetPoint("TOPLEFT", ns.UI.Controls, "TOPRIGHT", ns.UI.ItemSpacingHorizontal, -ns.UI.Margin - ns.UI.ItemSpacingVertical)
ns.UI.Item1:SetPoint("TOPRIGHT", ns.UI.Scrollbar, "TOPLEFT", -ns.UI.ItemSpacingHorizontal, -ns.UI.Margin - ns.UI.ItemSpacingVertical)
ns.UI.Item1:SetHeight(110)
ns.UI.Item1:SetBackdrop({
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
ns.UI.Item1:SetBackdropColor(0.09, 0.09, 0.09)
ns.UI.Item1.selected = false
ns.UI.Item1:SetScript("OnMouseDown", ns.UI.ItemOnClick)

ns.UI.Item1.Author = ns.UI.Item1:CreateFontString(nil, "ARTWORK", "SystemFont_Huge1")
ns.UI.Item1.Author:SetPoint("TOPLEFT", ns.UI.ItemMargin, -ns.UI.ItemMargin)
ns.UI.Item1.Author:SetPoint("TOPRIGHT", -ns.UI.ItemMargin, -ns.UI.ItemMargin)
ns.UI.Item1.Author:SetJustifyH("LEFT")

ns.UI.Item1.Recipient = ns.UI.Item1:CreateFontString(nil, "ARTWORK", "SystemFont_Med3")
ns.UI.Item1.Recipient:SetPoint("RIGHT", ns.UI.Item1.Author, "RIGHT")
ns.UI.Item1.Recipient:SetJustifyH("RIGHT")

ns.UI.Item1.Timestamp = ns.UI.Item1:CreateFontString(nil, "ARTWORK", "SystemFont_Small")
ns.UI.Item1.Timestamp:SetPoint("TOPLEFT", ns.UI.Item1.Author, "BOTTOMLEFT")
ns.UI.Item1.Timestamp:SetPoint("TOPRIGHT", ns.UI.Item1.Author, "BOTTOMRIGHT")
ns.UI.Item1.Timestamp:SetJustifyH("LEFT")

ns.UI.Item1.Rationale = ns.UI.Item1:CreateFontString(nil, "ARTWORK", "SystemFont_Small")
ns.UI.Item1.Rationale:SetPoint("RIGHT", ns.UI.Item1.Timestamp, "RIGHT")
ns.UI.Item1.Rationale:SetJustifyH("RIGHT")

ns.UI.Item1.Msg = ns.UI.Item1:CreateFontString(nil, "ARTWORK", "SystemFont_Med3")
ns.UI.Item1.Msg:SetPoint("TOPLEFT", ns.UI.Item1.Timestamp, "BOTTOMLEFT", 0, -ns.UI.ItemMargin)
ns.UI.Item1.Msg:SetPoint("BOTTOMRIGHT", ns.UI.Item1, "BOTTOMRIGHT", -ns.UI.ItemMargin, ns.UI.ItemMargin)
ns.UI.Item1.Msg:SetJustifyH("LEFT")

--Generate remaining items
for i = 2, ns.UI.ItemsShownAtATime, 1 do
	ns.UI["Item" .. i] = CreateFrame("Frame", nil, ns.UI)
	ns.UI["Item" .. i]:SetPoint("TOPLEFT", ns.UI["Item" .. i - 1], "BOTTOMLEFT", 0, -ns.UI.ItemMargin)
	ns.UI["Item" .. i]:SetPoint("TOPRIGHT", ns.UI["Item" .. i - 1], "BOTTOMRIGHT", 0, -ns.UI.ItemMargin)
	ns.UI["Item" .. i]:SetHeight(110)
	ns.UI["Item" .. i]:SetBackdrop({
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
	ns.UI["Item" .. i]:SetBackdropColor(0.09, 0.09, 0.09)
	ns.UI["Item" .. i].selected = false
	ns.UI["Item" .. i]:SetScript("OnMouseDown", ns.UI.ItemOnClick)

	ns.UI["Item" .. i].Author = ns.UI["Item" .. i]:CreateFontString(nil, "ARTWORK", "SystemFont_Huge1")
	ns.UI["Item" .. i].Author:SetPoint("TOPLEFT", ns.UI.ItemMargin, -ns.UI.ItemMargin)
	ns.UI["Item" .. i].Author:SetPoint("TOPRIGHT", -ns.UI.ItemMargin, -ns.UI.ItemMargin)
	ns.UI["Item" .. i].Author:SetJustifyH("LEFT")

	ns.UI["Item" .. i].Recipient = ns.UI["Item" .. i]:CreateFontString(nil, "ARTWORK", "SystemFont_Med3")
	ns.UI["Item" .. i].Recipient:SetPoint("RIGHT", ns.UI["Item" .. i].Author, "RIGHT")
	ns.UI["Item" .. i].Recipient:SetJustifyH("RIGHT")

	ns.UI["Item" .. i].Timestamp = ns.UI["Item" .. i]:CreateFontString(nil, "ARTWORK", "SystemFont_Small")
	ns.UI["Item" .. i].Timestamp:SetPoint("TOPLEFT", ns.UI["Item" .. i].Author, "BOTTOMLEFT")
	ns.UI["Item" .. i].Timestamp:SetPoint("TOPRIGHT", ns.UI["Item" .. i].Author, "BOTTOMRIGHT")
	ns.UI["Item" .. i].Timestamp:SetJustifyH("LEFT")

	ns.UI["Item" .. i].Rationale = ns.UI["Item" .. i]:CreateFontString(nil, "ARTWORK", "SystemFont_Small")
	ns.UI["Item" .. i].Rationale:SetPoint("RIGHT", ns.UI["Item" .. i].Timestamp, "RIGHT")
	ns.UI["Item" .. i].Rationale:SetJustifyH("RIGHT")

	ns.UI["Item" .. i].Msg = ns.UI["Item" .. i]:CreateFontString(nil, "ARTWORK", "SystemFont_Med3")
	ns.UI["Item" .. i].Msg:SetPoint("TOPLEFT", ns.UI["Item" .. i].Timestamp, "BOTTOMLEFT", 0, -ns.UI.ItemMargin)
	ns.UI["Item" .. i].Msg:SetPoint("BOTTOMRIGHT", ns.UI["Item" .. i], "BOTTOMRIGHT", -ns.UI.ItemMargin, ns.UI.ItemMargin)
	ns.UI["Item" .. i].Msg:SetJustifyH("LEFT")
end

SLASH_ANSWERINGMACHINE1 = '/am'
local function SlashCommandHandler(msg, editBox)
	if ns.UI:IsShown() then
		ns.UI:HideUI()
	else
		ns.UI:ShowUI()
	end
end
SlashCmdList["ANSWERINGMACHINE"] = SlashCommandHandler