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
	local msg, _, _, _, _, _, _, _, _, _, _, authorGUID = ...
	local rationale = self:GetRationale()

	if not self:CheckConfinements(rationale) then
		return
	end

	self:NewMessage(authorGUID, rationale, msg)
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
	local msg, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...
	local rationale = self:GetRationale()

	if not self:CheckConfinements(rationale) then
		return
	end

	self:NewBNETMessage(presenceID, rationale, msg)
	self:UpdateRecentMessages()
end

function ns.Controller:CHAT_MSG_BN_WHISPER_INFORM( ... )
	local _, _, BNETTag = BNGetFriendInfoByID(select(13, ...))

	self:UpdateRecentMessages()

	for k,v in pairs(self.recentMessages) do
		if v.author == BNETTag then
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
	Store.Settings.Confines = Store.Settings.Confines or {}

	if Store.Settings.Confines.AFK == nil then
		Store.Settings.Confines.AFK = true
	end

	if Store.Settings.Confines.DND == nil then
		Store.Settings.Confines.DND = true
	end

	if Store.Settings.Confines.Battleground == nil then
		Store.Settings.Confines.Battleground = true
	end

	if Store.Settings.Confines.Arena == nil then
		Store.Settings.Confines.Arena = true
	end

	if Store.Settings.Confines.Dungeon == nil then
		Store.Settings.Confines.Dungeon = true
	end

	if Store.Settings.Confines.Raid == nil then
		Store.Settings.Confines.Raid = true
	end

	if Store.Settings.Confines.Scenario == nil then
		Store.Settings.Confines.Scenario = true
	end
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

function ns.Controller:GetRationale()
	local inInstance, instanceType = IsInInstance()

	if UnitIsAFK("player") then
		return "AFK"
	end

	if UnitIsDND("player") then
		return "DND"
	end

	if inInstance then
		if instanceType == "pvp" then
			return "Battleground"
		elseif instanceType == "arena" then
			return "Arena"
		elseif instanceType == "party" then
			return "Dungeon"
		elseif instanceType == "raid" then
			return "Raid"
		elseif instanceType == "scenario" then
			return "Scenario"
		end
	end
end

function ns.Controller:CheckConfinements(Rationale)
	local c = Store.Settings.Confines

	if Rationale == "AFK" and c.AFK then
		return true
	elseif Rationale == "DND" and c.DND then
		return true
	elseif Rationale == "Battleground" and c.Battleground then
		return true
	elseif Rationale == "Arena" and c.Arena then
		return true
	elseif Rationale == "Dungeon" and c.Dungeon then
		return true
	elseif Rationale == "Raid" and c.Raid then
		return true
	elseif Rationale == "Scenario" and c.Scenario then
		return true
	else 
		return not c.AFK and not c.DND and not c.Battleground and not C.Arena and not C.Dungeon and not C.Raid and not c.Scenario
	end
end

function ns.Controller:NewBNETMessage(presenceID, Rationale, Msg)
	local _, _, BNETTag = BNGetFriendInfoByID(presenceID)
	local _, Recipient = BNGetInfo()

	local entry = {
		author = BNETTag,
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