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
ns.UI:SetSize(800, 700)
ns.UI:SetPoint("CENTER")
ns.UI:SetMovable(true)
ns.UI:SetClampedToScreen(true)
ns.UI.Margin = 15
--ns.UI:Hide()

--Header
ns.UI.Header = CreateFrame("Frame", nil, ns.UI)
ns.UI.Header:SetSize(192, 48)
ns.UI.Header:SetPoint("TOP", 0, 12)

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

--Controls
ns.UI.Controls = CreateFrame("Frame", nil, ns.UI)
ns.UI.Controls:SetPoint("TOPLEFT", ns.UI.Margin, -ns.UI.Margin)
ns.UI.Controls:SetPoint("BOTTOMRIGHT", ns.UI, "BOTTOMLEFT", ns.UI.Margin + 150, ns.UI.Margin)
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

--Scrollframe
ns.UI.Scrollbar = CreateFrame("Slider", nil, ns.UI, "UIPanelScrollBarTemplate")
ns.UI.Scrollbar:SetPoint("TOPRIGHT", ns.UI, "TOPRIGHT", -ns.UI.Margin, -ns.UI.Margin)
ns.UI.Scrollbar:SetPoint("BOTTOMRIGHT", ns.UI, "BOTTOMRIGHT", -ns.UI.Margin, ns.UI.Margin)
ns.UI.Scrollbar:SetWidth(16)
ns.UI.Scrollbar:SetMinMaxValues(1,100)
ns.UI.Scrollbar:SetValue(100)

SLASH_ANSWERINGMACHINE1 = '/am'
local function SlashCommandHandler(msg, editBox)
	if ns.UI:IsShown() then
		ns.UI:Hide()
	else
		ns.UI:Show()
	end
end
SlashCmdList["ANSWERINGMACHINE"] = SlashCommandHandler