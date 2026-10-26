--------------------------------------------------------------------
-- HemsworkPlates - Aviso de version nueva
-- Un addon no puede consultar internet: cada copia anuncia su version
-- con mensajes de addon (invisibles) en grupo/arena, banda, campo de
-- batalla y hermandad. Si alguien tiene una version mas nueva, se avisa
-- una vez por sesion; si tiene una mas vieja, se le responde en privado
-- para que el reciba el aviso.
--------------------------------------------------------------------
local addonName, SP = ...

local PREFIX = "HMSPLATES"
local URL = "github.com/Hemswork/HemsworkPlates"
local MY = GetAddOnMetadata(addonName, "Version") or "0"
SP.VERSION = MY

local function T(s) return SP.T and SP.T(s) or s end

-- "1.10.2-warmane" -> 1, 10, 2
local function Parse(v)
	local a, b, c = string.match(v or "", "^(%d+)%.?(%d*)%.?(%d*)")
	return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

-- true si la version a es mas nueva que la b
local function Newer(a, b)
	local a1, a2, a3 = Parse(a)
	local b1, b2, b3 = Parse(b)
	if a1 ~= b1 then return a1 > b1 end
	if a2 ~= b2 then return a2 > b2 end
	return a3 > b3
end
SP.VersionNewer = Newer

local lastSent = {}
local warned = false

local function Send(channel, target)
	local key = target or channel
	local now = GetTime()
	local wait = target and 60 or 15
	if lastSent[key] and now - lastSent[key] < wait then return end
	lastSent[key] = now
	SendAddonMessage(PREFIX, "V:" .. MY, channel, target)
end

local function Broadcast()
	local _, it = IsInInstance()
	if it == "pvp" then
		Send("BATTLEGROUND")
	elseif GetNumRaidMembers() > 0 then
		Send("RAID")
	elseif GetNumPartyMembers() > 0 then
		Send("PARTY") -- en arena tu equipo es un grupo
	end
	if IsInGuild() then Send("GUILD") end
end

local function OnVersion(remote, sender)
	if Newer(remote, MY) then
		if not warned then
			warned = true
			DEFAULT_CHAT_FRAME:AddMessage(string.format(
				T("|cff66ccffHemsworkPlates:|r hay una version nueva (|cffffffff%s|r, tienes la %s). Descargala en |cffffffff%s|r"),
				remote, MY, URL))
		end
	elseif Newer(MY, remote) and sender then
		-- El otro va atrasado: se le responde en privado (como mucho una vez por minuto)
		Send("WHISPER", sender)
	end
end
SP.OnVersionMessage = OnVersion

local f = CreateFrame("Frame")
local pendingAt
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(_, event, prefix, msg, _, sender)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= PREFIX or not msg or sender == UnitName("player") then return end
		local v = string.match(msg, "^V:(.+)$")
		if v then OnVersion(v, sender) end
		return
	end
	-- Se anuncia unos segundos despues (al entrar al mundo o al cambiar el grupo)
	pendingAt = GetTime() + 4
	f:Show()
end)
f:SetScript("OnUpdate", function(self)
	if pendingAt and GetTime() >= pendingAt then
		pendingAt = nil
		self:Hide()
		Broadcast()
	end
end)
