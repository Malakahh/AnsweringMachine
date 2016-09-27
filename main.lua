local _, ns = ...

ns.Controller = CreateFrame("Frame")
ns.Controller:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
ns.Controller:RegisterEvent("ADDON_LOADED")

function ns.Controller:ADDON_LOADED(addonName)
	if addonName == "AnsweringMachine" then
		self:RegisterEvent("PLAYER_LOGIN")
		self:RegisterEvent("CHAT_MSG_WHISPER")
		self:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
		self:RegisterEvent("CHAT_MSG_BN_WHISPER")
		self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
		self:RegisterEvent("PLAYER_LOGOUT")
		
		Store = Store or {}
		Store.Messages = Store.Messages or {}
		Store.Settings = Store.Settings or {}
		self:UpdateSettings()

		self.recentMessages = {}
		self:UpdateRecentMessages()
	end
end

function ns.Controller:FadeDelayTimerOnUpdate(elapsed)
	ns.Controller.FadeDelayTimer = ns.Controller.FadeDelayTimer + elapsed

	if not ns.Notification:IsShown() then
		self:SetScript("OnUpdate", nil)
	elseif ns.Controller.FadeDelayTimer >= 10 then
		self:SetScript("OnUpdate", nil)
		ns.Notification:Fade()
	end
end

function ns.Controller:PLAYER_LOGIN()
	if #Store.Messages > 0 or #self.recentMessages > 0 then
		ns.Notification:Show()
		ns.Controller.FadeDelayTimer = 0
		self:SetScript("OnUpdate", self.FadeDelayTimerOnUpdate)
	end
end

function ns.Controller:CHAT_MSG_WHISPER(...)
	local msg, _, _, _, _, flags, _, _, _, _, _, authorGUID = ...

	self:NewMessage(authorGUID, flags, msg)
	self:UpdateRecentMessages()
end

function ns.Controller:CHAT_MSG_WHISPER_INFORM(...)
	local _, otherPlayer = ...

	self:UpdateRecentMessages()

	for k,v in pairs(self.recentMessages) do
		if v.author == otherPlayer then
			table.remove(self.recentMessages, k)
		end
	end
end

function ns.Controller:CHAT_MSG_BN_WHISPER(...)
	local msg, _, flags, _, _, _, _, _, _, _, _, _, presenceID = ...

	self:NewBNETMessage(presenceID, flags, msg)
	self:UpdateRecentMessages()
end

function ns.Controller:CHAT_MSG_BN_WHISPER_INFORM( ... )
	local _, Author = BNGetFriendInfoByID(select(13, ...))

	self:UpdateRecentMessages()

	for k,v in pairs(self.recentMessages) do
		if v.author == Author then
			table.remove(self.recentMessages, k)
		end
	end
end

function ns.Controller:PLAYER_LOGOUT()
	for _,v in pairs(self.recentMessages) do
		table.insert(Store.Messages, v)
	end
end

function ns.Controller:RemoveMsg(msg)
	if tContains(Store.Messages, msg) then
		for k,v in pairs(Store.Messages) do
			if msg == v then
				table.remove(Store.Messages, k)
				return true
			end
		end
	elseif tContains(self.recentMessages, msg) then
		for k,v in pairs(self.recentMessages, msg) do
			if msg == v then
				table.remove(self.recentMessages, k)
				return true
			end
		end
	else 
		return false
	end
end

function ns.Controller:UpdateSettings()
	Store.Settings.timeToReply = Store.Settings.timeToReply or 300
end

function ns.Controller:UpdateRecentMessages()
	local serverTime = GetServerTime()

	for k,v in pairs(self.recentMessages) do
		if v.timestamp < serverTime - Store.Settings.timeToReply then
			table.remove(self.recentMessages, k)
			table.insert(Store.Messages, v)
		end
	end
end

function ns.Controller:NewBNETMessage(presenceID, Rationale, Msg)
	local _, Author = BNGetFriendInfoByID(presenceID)
	local _, Recipient = BNGetInfo()

	local entry = {
		author = Author,
		authorClass = "BNET",
		recipient = Recipient,
		recipientClass = "BNET",
		timestamp = GetServerTime(),
		rationale = Rationale,
		msg = Msg,
	}

	table.insert(self.recentMessages, entry)
end

function ns.Controller:NewMessage(AuthorGUID, Rationale, Msg)
	local playername = UnitName("player")
	local playerrealm = GetRealmName()
	local _, playerClassTAG = UnitClass("player")

	local _, AuthorClassTAG, _, _, _, AuthorName, AuthorRealm = GetPlayerInfoByGUID(AuthorGUID)

	if AuthorRealm == "" then
		AuthorRealm = playerrealm
	end

	local entry = {
		author = AuthorName .. "-" .. AuthorRealm,
		authorClass = AuthorClassTAG,
		recipient = playername .. "-" .. playerrealm,
		recipientClass = playerClassTAG,
		timestamp = GetServerTime(),
		rationale = Rationale,
		msg = Msg,
	}

	table.insert(self.recentMessages, entry)
end

function ns.Controller:PrintMessage(msg)
	print("Author: " .. msg.author)
	print("authorClass: " .. msg.authorClass)
	print("recipient: " .. msg.recipient)
	print("recipientClass: " .. msg.recipientClass)
	print("timestamp: " .. msg.timestamp)
	print("rationale: " .. msg.rationale)
	print("msg: " .. msg.msg)
end