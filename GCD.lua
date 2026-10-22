--------------------------------------------------------------------
-- HemsworkPlates - GCD de los enemigos de arena
-- Integrado desde NameplateArenaGCDs (Fruitdealer1337), basado en
-- ArenaGCDs (Oscarforge). Cuando un rival de arena lanza un hechizo se
-- muestra en su placa el icono con un barrido que dura su GCD (segun
-- clase, hechizo, haste y procs instantaneos).
-- Las placas no se buscan aqui: se usa el emparejamiento por GUID del
-- nucleo (sirve igual con Awesome WotLK y sin el).
--------------------------------------------------------------------
local addonName, SP = ...

local instantCastBuffsTable = SP.instantCastBuffsTable or {}
local hasteBuffsTable = SP.hasteBuffsTable or {}
local spellTable = SP.spellTable or {}

local floor = math.floor
local GetTime = GetTime
local SWIPE = "Interface\\AddOns\\" .. addonName .. "\\Media\\gcd_swipe"

local ARENA_UNITS = { "arena1", "arena2", "arena3", "arena4", "arena5" }

-- Las tablas usan nombres de clase en ingles: se traducen desde el token de
-- clase para que no dependa del idioma del cliente
local CLASS_NAMES = {
	WARRIOR = "Warrior", PALADIN = "Paladin", HUNTER = "Hunter", ROGUE = "Rogue",
	PRIEST = "Priest", DEATHKNIGHT = "Death Knight", SHAMAN = "Shaman",
	MAGE = "Mage", WARLOCK = "Warlock", DRUID = "Druid",
}

local unitClasses, gcdState, observedCasts, pendingClears = {}, {}, {}, {}
local gcdSerial = 0

local function GetUnitClassName(unit)
	local c = unitClasses[unit]
	if c then return c end
	local _, token = UnitClass(unit)
	c = token and CLASS_NAMES[token] or ""
	if c ~= "" then unitClasses[unit] = c end
	return c
end

-- Duracion del GCD (misma logica que el addon original)
local function DetermineGCD(unitClass, spellName, unit)
	if unitClass == "Hunter" then
		if spellName == "Readiness" then return 1.0 end
		return 1.5
	end
	if unitClass == "Shaman" then
		if spellName == "Lava Lash" or spellName == "Stormstrike" then return 1.5 end
	end
	if unitClass == "Warrior" then
		if spellName == "Overpower" or spellName == "Revenge" then return 1.0 end
		return 1.5
	end
	if unitClass == "Rogue" then return 1.0 end
	if unitClass == "Druid" and hasteBuffsTable["Druid"] and hasteBuffsTable["Druid"]["Cat Form"]
		and hasteBuffsTable["Druid"]["Cat Form"][unit] then
		return 1.0
	end
	if unitClass == "Warlock" and spellName == "Shadowfury" then return 0.5 end
	if unitClass == "Paladin" then
		if spellName:match("^Judgement") or spellName == "Shield of Righteousness" then return 1.5 end
	end
	if hasteBuffsTable["Heroism"] and hasteBuffsTable["Heroism"][unit] then return 1.0 end
	local hasteBuffs = hasteBuffsTable[unitClass]
	if hasteBuffs then
		for _, buffData in pairs(hasteBuffs) do
			if type(buffData) == "table" and buffData.spells then
				if buffData.spells[spellName] and buffData[unit] then return 1.0 end
			elseif type(buffData) == "table" and buffData[unit] then
				if unitClass == "Paladin" then return 1.2 end
				return 1.0
			end
		end
	end
	if unitClass == "Death Knight" then return 1.5 end
	return 1.3
end

local function StartGCD(unit, spellName, icon, duration, tentative)
	local now = GetTime()
	gcdSerial = gcdSerial + 1
	pendingClears[unit] = nil
	gcdState[unit] = {
		guid = UnitGUID(unit), spellName = spellName, icon = icon,
		start = now, duration = duration, expiration = now + duration,
		serial = gcdSerial, tentative = tentative and true or false, interrupted = false,
	}
end

local function ClearGCD(unit, serial)
	local st = gcdState[unit]
	if serial and st and st.serial ~= serial then return end
	gcdState[unit] = nil
	pendingClears[unit] = nil
end

local function ConfirmGCD(unit, serial)
	local st = gcdState[unit]
	if not st or (serial and st.serial ~= serial) then return end
	st.tentative = false
	st.interrupted = true
	pendingClears[unit] = nil
end

local function ResolveSpellInfo(unit, spellName, liveIcon)
	local unitClass = GetUnitClassName(unit)
	local data = spellTable[unitClass] and spellTable[unitClass][spellName]
	if data then return unitClass, data.icon end
	local _, _, icon = GetSpellInfo(spellName)
	return unitClass, icon or liveIcon
end

-- Procs de cast instantaneo y de haste (para la duracion del GCD)
local function OnUnitAura(unit)
	local unitClass = GetUnitClassName(unit)
	if unitClass == "" then return end
	local classBuffs = instantCastBuffsTable[unitClass]
	if classBuffs then
		for buffName, units in pairs(classBuffs) do
			local auraName, _, _, stacks, _, dur = UnitAura(unit, buffName)
			if unitClass == "Shaman" and auraName == "Maelstrom Weapon" then
				units[unit] = (stacks == 5); break
			elseif unitClass == "Shaman" and auraName == "Elemental Mastery" then
				units[unit] = (dur == 30); break
			end
			units[unit] = auraName and true or false
			if units[unit] then break end
		end
	end
	if hasteBuffsTable["Heroism"] then
		local hero = UnitAura(unit, "Heroism") or UnitAura(unit, "Bloodlust")
		hasteBuffsTable["Heroism"][unit] = hero and true or false
		if hero then return end
	end
	local haste = hasteBuffsTable[unitClass]
	if haste then
		for buffName, units in pairs(haste) do
			units[unit] = UnitAura(unit, buffName) and true or false
			if units[unit] then break end
		end
	end
end

local function OnCastStart(unit, spellName, channel)
	local liveName, liveIcon
	if channel then
		liveName, _, _, liveIcon = UnitChannelInfo(unit)
	else
		liveName, _, _, liveIcon = UnitCastingInfo(unit)
	end
	spellName = spellName or liveName
	if not spellName then return end
	local unitClass, icon = ResolveSpellInfo(unit, spellName, liveIcon)
	if not icon then return end
	observedCasts[unit] = observedCasts[unit] or {}
	observedCasts[unit][spellName] = GetTime()
	StartGCD(unit, spellName, icon, DetermineGCD(unitClass, spellName, unit), true)
end

local function OnCastSucceeded(unit, spellName)
	if not spellName then return end
	local st = gcdState[unit]
	if st and st.tentative and st.spellName == spellName then
		ConfirmGCD(unit, st.serial)
		return
	end
	local seen = observedCasts[unit] and observedCasts[unit][spellName]
	if seen and GetTime() - seen < 10 then return end
	local unitClass = GetUnitClassName(unit)
	local data = spellTable[unitClass] and spellTable[unitClass][spellName]
	if not data then return end
	-- Hechizos con tiempo de cast solo cuentan aqui si un proc los hizo instantaneos
	local instant = false
	local buffs = instantCastBuffsTable[unitClass]
	if buffs then
		for _, b in pairs(buffs) do
			if b.spells and b.spells[spellName] and b[unit] then instant = true break end
		end
	end
	if (data.castTime or 0) > 0 and not instant then return end
	StartGCD(unit, spellName, data.icon, DetermineGCD(unitClass, spellName, unit), false)
end

---------------------------------- EVENTOS ----------------------------------
local ev = CreateFrame("Frame")
for _, e in ipairs({ "PLAYER_ENTERING_WORLD", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP",
	"UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_INTERRUPTED",
	"COMBAT_LOG_EVENT_UNFILTERED", "UNIT_AURA" }) do
	ev:RegisterEvent(e)
end
ev:SetScript("OnEvent", function(_, event, unit, spellName, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		wipe(unitClasses); wipe(gcdState); wipe(observedCasts); wipe(pendingClears)
		-- El addon original pinta sus propios iconos (que no se mueven con /hms)
		if not SP.warnedGCD and IsAddOnLoaded("NamePlateArenaGCDs") then
			SP.warnedGCD = true
			DEFAULT_CHAT_FRAME:AddMessage(SP.T("|cffffaa00HemsworkPlates:|r el addon |cffffffffNamePlateArenaGCDs|r sigue activo. ")
				.. SP.T("HemsworkPlates ya incluye el GCD de arena: desactivalo en la lista de AddOns para no ver los iconos dos veces."))
		end
		return
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		-- unit = timestamp, spellName = subevento; el GUID destino es el 6o argumento
		if spellName == "SPELL_INTERRUPT" then
			local dstGUID = select(4, ...)
			for _, u in ipairs(ARENA_UNITS) do
				local st = gcdState[u]
				if st and st.guid == dstGUID and st.tentative then ConfirmGCD(u, st.serial) end
			end
		end
		return
	end
	local cfg = SP.cfg
	if not cfg or not cfg.gcd or not unit or not string.match(unit, "^arena%d$") then return end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		OnCastSucceeded(unit, spellName)
	elseif event == "UNIT_SPELLCAST_START" then
		OnCastStart(unit, spellName, false)
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
		OnCastStart(unit, spellName, true)
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" then
		local st = gcdState[unit]
		if st and st.tentative and not st.interrupted and (not spellName or st.spellName == spellName) then
			ClearGCD(unit, st.serial)
		end
	elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP"
		or event == "UNIT_SPELLCAST_INTERRUPTED" then
		local st = gcdState[unit]
		if st and st.tentative and (not spellName or st.spellName == spellName) then
			pendingClears[unit] = st.serial
		end
	elseif event == "UNIT_AURA" then
		OnUnitAura(unit)
	end
end)

-- Prueba: GCD de 15 s en tu target (para colocar el icono fuera de arena)
function SP.TestGCD()
	if not UnitExists("target") then
		DEFAULT_CHAT_FRAME:AddMessage(SP.T("|cff66ccffHemsworkPlates:|r pon de target a alguien con placa visible."))
		return
	end
	gcdSerial = gcdSerial + 1
	local now = GetTime()
	gcdState.test = {
		guid = UnitGUID("target"), spellName = "Test", icon = "Interface\\Icons\\Spell_Nature_StarFall",
		start = now, duration = 15, expiration = now + 15, serial = gcdSerial, tentative = false,
	}
end

------------------------------ ICONO EN LA PLACA ------------------------------
function SP.BuildGCD(sp)
	local f = CreateFrame("Frame", nil, sp)
	f:SetFrameLevel(sp:GetFrameLevel() + 10)
	f.edge = f:CreateTexture(nil, "BACKGROUND")
	f.edge:SetTexture(0, 0, 0, 1)
	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetAllPoints(f)
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.sweep = f:CreateTexture(nil, "OVERLAY")
	f.sweep:SetAllPoints(f)
	f.sweep:SetTexture(SWIPE)
	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
	f:Hide()
	sp.gcdFrame = f
end

-- Tamano y posicion (lo llama Restyle)
function SP.LayoutGCD(sp, px, fs)
	local f, cfg = sp.gcdFrame, SP.cfg
	if not f then return end
	local function snap(v) return px and floor(v / px + 0.5) * px or v end
	local size = math.max(px or 1, snap(cfg.gcdSize))
	f:SetWidth(size)
	f:SetHeight(size)
	local one = px and math.max(px, snap(1)) or 1
	f.edge:ClearAllPoints()
	f.edge:SetPoint("TOPLEFT", f, "TOPLEFT", -one, one)
	f.edge:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", one, -one)
	f.text:SetFont(cfg.font, math.max(6, floor(size * 0.4)), "OUTLINE")
	f.sweep:SetAlpha(cfg.gcdAlpha)
	-- Si va del mismo lado que el icono de debuffs, se pega por fuera de el
	local side = cfg.gcdPos == "right" and "right" or "left"
	local dside = cfg.debuffPos == "left" and "left" or "right"
	local inner = (cfg.debuffs and side == dside) and sp.debuff or nil
	SP.PlaceSideIcon(f, sp, side, fs, px, inner)
	f.lastFrame, f.lastText, f.lastIcon = nil, nil, nil
end

-- Cada frame (con limite): pinta el GCD activo de cada placa
local byGuid = {}
local lastUpdate = 0
function SP.UpdateGCDs(active)
	local now = GetTime()
	if now - lastUpdate < 0.03 then return end
	lastUpdate = now
	local cfg = SP.cfg

	-- GCDs que se cancelaron (el cast se paro sin confirmarse)
	for unit, serial in pairs(pendingClears) do
		local st = gcdState[unit]
		if st and st.serial == serial and st.tentative and not st.interrupted then ClearGCD(unit, serial) end
		pendingClears[unit] = nil
	end

	wipe(byGuid)
	for unit, st in pairs(gcdState) do
		if st.expiration <= now then
			gcdState[unit] = nil
		elseif st.guid then
			byGuid[st.guid] = st
		end
	end

	for plate, sp in pairs(active) do
		local f = sp.gcdFrame
		if f then
			local st = cfg.gcd and sp.mode == "normal" and plate.spGUID and byGuid[plate.spGUID]
			if st then
				if f.lastIcon ~= st.icon then f.lastIcon = st.icon; f.icon:SetTexture(st.icon) end
				local left = st.expiration - now
				local ratio = left / (st.duration > 0 and st.duration or 1)
				if ratio < 0 then ratio = 0 elseif ratio > 1 then ratio = 1 end
				if cfg.gcdHideSweep then
					f.sweep:Hide()
				else
					-- Hoja de 8x8 fotogramas del barrido original
					local p = cfg.gcdReverse and (1 - ratio) or ratio
					local idx = floor(p * 63)
					if f.lastFrame ~= idx then
						f.lastFrame = idx
						local row = floor(idx / 8)
						local col = idx - row * 8
						f.sweep:SetTexCoord((col + 1) / 8, col / 8, row / 8, (row + 1) / 8)
					end
					f.sweep:Show()
				end
				if cfg.gcdTimer then
					local s = string.format("%.1f", left)
					if f.lastText ~= s then f.lastText = s; f.text:SetText(s) end
					f.text:Show()
				else
					f.text:Hide()
				end
				f:Show()
			elseif f:IsShown() then
				f:Hide()
			end
		end
	end
end
