local _, ns = ...

ns.Controller = CreateFrame("Frame")
ns.Controller:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
ns.Controller:RegisterEvent("ADDON_LOADED")

function ns.Controller:ADDON_LOADED(addonName)
	if addonName == "AnsweringMachine" then
		self:RegisterEvent("CHAT_MSG_WHISPER")
		self:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
		
		Store = Store or {}
		Store.Messages = Store.Messages or {}
		Store.Settings = Store.Settings or {}
		self:UpdateSettings()

		self.recentMessages = {}
		self:UpdateRecentMessages()
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
	Store.Settings.timeToReply = Store.Settings.timeToReply or 30
end

function ns.Controller:UpdateRecentMessages()
	local serverTime = GetServerTime()

	for k,v in pairs(self.recentMessages) do
		if v.timestamp < serverTime - Store.Settings.timeToReply then
			print("Message timed out:")
			self:PrintMessage(v)
			table.remove(self.recentMessages, k)
			table.insert(Store.Messages, v)
		end
	end
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
	print("Msg added")
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