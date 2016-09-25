local _, ns = ...

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("ADDON_LOADED")

function frame:ADDON_LOADED(addonName)
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

function frame:CHAT_MSG_WHISPER(...)
	local msg, author, _, _, _, flags = ...

	self:NewMessage(author, flags, msg)
	self:UpdateRecentMessages()
end

function frame:CHAT_MSG_WHISPER_INFORM(...)
	local _, otherPlayer = ...

	self:UpdateRecentMessages()

	for k,v in pairs(self.recentMessages) do
		if v.author == otherPlayer then
			table.remove(self.recentMessages, k)
			print("Message reply:")
			self:PrintMessage(v)
		end
	end
end

function frame:UpdateSettings()
	Store.Settings.timeToReply = Store.Settings.timeToReply or 1
end

function frame:UpdateRecentMessages()
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

function frame:NewMessage(Author, Rationale, Msg)
	local playername = UnitName("player")
	local playerrealm = GetRealmName()

	local entry = {
		author = Author,
		recipient = playername .. "-" .. playerrealm,
		timestamp = GetServerTime(),
		rationale = Rationale,
		msg = Msg,
	}

	table.insert(self.recentMessages, entry)
	print("Msg added")
	self:PrintMessage(entry)
end

function frame:PrintMessage(msg)
	print("Author: " .. msg.author)
	print("recipient: " .. msg.recipient)
	print("timestamp: " .. msg.timestamp)
	print("rationale: " .. msg.rationale)
	print("msg: " .. msg.msg)
end