local _, ns = ...

ns.Notification = CreateFrame("Frame", "AnsweringMachineNotification", UIParent)
ns.Notification:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 64,
	edgeSize = 16,
	insets = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 4
    }
})
ns.Notification:SetBackdropColor(0.09, 0.09, 0.09)
ns.Notification:SetSize(225, 64)
ns.Notification:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT")
ns.Notification:SetScript("OnMouseDown", function()
	ns.UI:ShowUI()
	ns.Notification:Hide()
end)
ns.Notification:Hide()
ns.Notification.Margin = 8

ns.Notification.Icon = ns.Notification:CreateTexture(nil, "ARTWORK")
ns.Notification.Icon:SetTexture("Interface\\TUTORIALFRAME\\TutorialFrame-QuestionMark")
ns.Notification.Icon:SetPoint("TOPLEFT")
ns.Notification.Icon:SetPoint("BOTTOMLEFT", 64, 0)

ns.Notification.Headline = ns.Notification:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
ns.Notification.Headline:SetPoint("TOPLEFT", ns.Notification.Icon, "TOPRIGHT", ns.Notification.Margin, -ns.Notification.Margin)
ns.Notification.Headline:SetPoint("RIGHT", -ns.Notification.Margin, 0)
ns.Notification.Headline:SetJustifyH("CENTER")
ns.Notification.Headline:SetJustifyV("CENTER")
ns.Notification.Headline:SetText("Unread whispers")

ns.Notification.Msg = ns.Notification:CreateFontString(nil, "ARTWORK", "GameFontNormal")
ns.Notification.Msg:SetPoint("TOPLEFT", ns.Notification.Headline, "BOTTOMLEFT", ns.Notification.Margin, 0)
ns.Notification.Msg:SetPoint("BOTTOMRIGHT", -ns.Notification.Margin, ns.Notification.Margin)
ns.Notification.Msg:SetJustifyH("CENTER")
ns.Notification.Msg:SetJustifyV("CENTER")
ns.Notification.Msg:SetText("Click to open Answering Machine")

function ns.Notification:FadeComplete()
	ns.Notification:Hide()
end

function ns.Notification:Fade()
	local fadeInfo = {
		mode = "OUT",
		timeToFade = 2,
		startAlpha = 1,
		endAlpha = 0,
		finishedFunc = ns.Notification.FadeComplete
	}
	UIFrameFade(ns.Notification, fadeInfo)
end