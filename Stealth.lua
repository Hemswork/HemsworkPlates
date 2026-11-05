--------------------------------------------------------------------
-- HemsworkPlates - Rivales en sigilo (solo arena, con el ojo)
-- Con Shadow Sight (el ojo de la arena) se ve a los picaros/druidas en
-- sigilo, pero el juego no les pone placa. Aqui:
--  * se les pone una marca de banda (el juego la dibuja sobre su cabeza)
--  * se muestra un aviso en pantalla con su nombre y la marca
-- Solo actua en arena, si tienes el ojo y el rival esta en sigilo; la
-- marca puesta por el addon se quita cuando deja de cumplirse.
--------------------------------------------------------------------
local addonName, SP = ...

local function T(s) return SP.T and SP.T(s) or s end

local ARENA = { "arena1", "arena2", "arena3", "arena4", "arena5" }
local SHADOW_SIGHT = 34709
-- Stealth (picaro), Prowl (druida), Shadowmeld (elfo de la noche), Invisibility (mago)
local STEALTH_SPELLS = { 1784, 5215, 58984, 32612 }
local RAID_ICON = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"

local stealthNames, sightName
local function LoadNames()
	if stealthNames then return end
	stealthNames = {}
	for _, id in ipairs(STEALTH_SPELLS) do
		local n = GetSpellInfo(id)
		if n then stealthNames[#stealthNames + 1] = n end
	end
	sightName = GetSpellInfo(SHADOW_SIGHT)
end

local function IsStealthed(unit)
	for _, n in ipairs(stealthNames) do
		if UnitBuff(unit, n) then return true end
	end
	return false
end

-- El ojo (Shadow Sight) aparece como debuff en algunos servidores: se busca en ambos
local function HasSight()
	if not sightName then return false end
	return UnitBuff("player", sightName) ~= nil or UnitDebuff("player", sightName) ~= nil
end

-- Arena + ojo activo
local function Active()
	local _, it = IsInInstance()
	return it == "arena" and HasSight()
end

------------------------------ AVISO EN PANTALLA ------------------------------
local alert = CreateFrame("Frame", "HemsworkPlatesStealthAlert", UIParent)
alert:SetPoint("TOP", UIParent, "TOP", 0, -140)
alert:SetWidth(1)
alert:SetHeight(1)
alert:SetFrameStrata("HIGH")
alert.rows = {}

local function Row(i)
	local r = alert.rows[i]
	if r then return r end
	r = CreateFrame("Frame", nil, alert)
	r.bg = r:CreateTexture(nil, "BACKGROUND")
	r.bg:SetAllPoints()
	r.bg:SetTexture(0, 0, 0, 0.55)
	r.icon = r:CreateTexture(nil, "ARTWORK")
	r.text = r:CreateFontString(nil, "OVERLAY")
	r:Hide()
	alert.rows[i] = r
	return r
end

-- Tamano del aviso (opcion "stealthAlertSize")
function SP.LayoutStealth()
	local cfg = SP.cfg
	if not cfg then return end
	local size = cfg.stealthAlertSize
	for i = 1, #ARENA do
		local r = Row(i)
		r:SetHeight(size + 8)
		r:SetWidth(size * 9)
		r:ClearAllPoints()
		r:SetPoint("TOP", alert, "TOP", 0, -(i - 1) * (size + 12))
		r.icon:SetWidth(size)
		r.icon:SetHeight(size)
		r.icon:ClearAllPoints()
		r.icon:SetPoint("LEFT", r, "LEFT", 4, 0)
		r.text:SetFont(cfg.font, math.max(8, math.floor(size * 0.55)), "OUTLINE")
		r.text:ClearAllPoints()
		r.text:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
	end
end

local function ShowRow(i, icon, name, class)
	local r = Row(i)
	if icon and icon > 0 then
		r.icon:SetTexture(string.format(RAID_ICON, icon))
	else
		r.icon:SetTexture("Interface\\Icons\\Ability_Stealth")
	end
	local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	local hex = c and string.format("%02x%02x%02x", math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5),
		math.floor(c.b * 255 + 0.5)) or "ffffff"
	r.text:SetText(string.format("|cff%s%s|r %s", hex, name or "?", T("en sigilo")))
	r:Show()
end

------------------------------ LOGICA ------------------------------
local marked = {} -- unidad -> marca que puso el addon
local testUntil

local function Update()
	local cfg = SP.cfg
	if not cfg then return end
	LoadNames()
	local active = Active()
	local n = 0
	for i, unit in ipairs(ARENA) do
		local stealthed = active and UnitExists(unit) and IsStealthed(unit)
		local icon = cfg.stealthIcons and cfg.stealthIcons[i] or 0
		if stealthed and cfg.stealthMark and icon > 0 then
			-- Poner la marca solo si no la tiene ya (repetirla la quitaria)
			if GetRaidTargetIndex(unit) ~= icon then SetRaidTarget(unit, icon) end
			marked[unit] = icon
		elseif marked[unit] then
			-- Ya no esta en sigilo / sin ojo: quitar solo la marca que puso el addon
			if UnitExists(unit) and GetRaidTargetIndex(unit) == marked[unit] then SetRaidTarget(unit, 0) end
			marked[unit] = nil
		end
		if stealthed and cfg.stealthAlert then
			n = n + 1
			local _, class = UnitClass(unit)
			ShowRow(n, cfg.stealthMark and icon or 0, UnitName(unit), class)
		end
	end
	-- Prueba desde /hms: un aviso de ejemplo durante 5 segundos
	if testUntil then
		if GetTime() < testUntil then
			n = n + 1
			ShowRow(n, cfg.stealthIcons and cfg.stealthIcons[1] or 8, T("Rival de prueba"), "ROGUE")
		else
			testUntil = nil
		end
	end
	for i = n + 1, #alert.rows do alert.rows[i]:Hide() end
end
SP.UpdateStealth = Update

-- Diagnostico (/hms sigilo): que detecta el addon ahora mismo
function SP.StealthDebug()
	LoadNames()
	local _, it = IsInInstance()
	local p = function(s) DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffHemsworkPlates|r " .. s) end
	p(string.format("zona=%s  ojo(%s): buff=%s debuff=%s  activo=%s", tostring(it), tostring(sightName),
		tostring(UnitBuff("player", sightName or "") ~= nil), tostring(UnitDebuff("player", sightName or "") ~= nil), tostring(Active())))
	p(string.format("grupo=%d  lider=%s  tu marca=%s", GetNumPartyMembers(), tostring(IsPartyLeader()),
		tostring(GetRaidTargetIndex("player"))))
	for i, unit in ipairs(ARENA) do
		if UnitExists(unit) then
			local auras = {}
			for j = 1, 40 do
				local n = UnitBuff(unit, j)
				if not n then break end
				auras[#auras + 1] = n
			end
			p(string.format("%s %s: sigilo=%s marca=%s buffs=[%s]", unit, tostring(UnitName(unit)), tostring(IsStealthed(unit)),
				tostring(GetRaidTargetIndex(unit)), table.concat(auras, ", ")))
		end
	end
end

function SP.TestStealth()
	SP.LayoutStealth()
	testUntil = GetTime() + 5
	Update()
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("UNIT_AURA")
ev:RegisterEvent("ARENA_OPPONENT_UPDATE")
ev:SetScript("OnEvent", function(_, event, unit)
	if event == "PLAYER_ENTERING_WORLD" then
		wipe(marked)
		SP.LayoutStealth()
	elseif event == "UNIT_AURA" and unit ~= "player" and not (unit and string.match(unit, "^arena%d$")) then
		return
	end
	Update()
end)
-- Repaso cada medio segundo (el rival puede aparecer/desaparecer sin eventos)
local acc = 0
ev:SetScript("OnUpdate", function(_, dt)
	acc = acc + dt
	if acc < 0.5 then return end
	acc = 0
	if testUntil or next(marked) or Active() then Update() end
end)
