--------------------------------------------------------------------
-- HemsworkPlates (Warmane) - nameplates para 3.3.5a, sin Awesome WotLK
-- Las placas salen de WorldFrame y las emparejo por nombre con
-- arena1-5, party1-4, target, focus y mouseover.
-- Opciones en /hms (o /plates)
--------------------------------------------------------------------
local addonName, SP = ...

SP.Refresh = function() end -- se reemplaza mas abajo
local function T(s) return SP.T and SP.T(s) or s end

local defaults = {
	language = "auto", -- "auto" (segun el cliente), "es" o "en"
	shape = "classic", -- "classic" o "old" (el marco dorado de siempre)
	width = 120, height = 11, castHeight = 14, castY = 0, castWidth = 0, scale = 1,
	pixelPerfect = true,

	font = "Fonts\\FRIZQT__.TTF", fontSize = 11, fontOutline = "",
	texture = "Interface\\TargetingFrame\\UI-StatusBar",

	showName = true, showLevel = true, showHealthText = false,
	showCast = true, showCastIcon = true, showCastTime = true, showCastText = true,
	castFontSize = 8, -- letra del texto del cast

	-- opacidad de las placas que no son tu target, como en RefinedBlizzPlates (0-99%)
	-- con modNonTargetAlpha apagado se deja la del juego
	modNonTargetAlpha = true, nonTargetAlpha = 0.7,
	bossIconSize = 13, -- calavera de los jefes (nivel ??)
	levelFontSize = 11, -- tamano de letra del nivel (el "80")
	nameWidth = 150, -- ancho max. del nombre, lo que no quepa se corta con ...
	-- tintes de borde como en RBP (blanco = sin tocar)
	borderTint = { 1, 1, 1 },              -- marco dorado (estilo Antiguo)
	castBorderTint = { 1, 1, 1 },          -- marco plateado del castbar
	castProtectedBorderTint = { 1, 1, 1 }, -- marco con escudo (no interrumpible)
	offsetX = 0, offsetY = 0, -- mover la placa entera
	-- centrada sobre la cabeza (ignora offsetX)
	centerPlate = true,
	-- icono de clase a la izquierda de la barra
	classIcon = true, classIconSize = 20,
	classIconGap = 0, -- 0 = pegado a la placa
	-- cruz de healer, con ajustes aparte para rivales y grupo
	healerEnemy = true, healerEnemySize = 18, healerEnemyX = 0, healerEnemyY = 0,
	healerParty = true, healerPartySize = 18, healerPartyX = 0, healerPartyY = 0,
	nameX = 0, nameY = 0, -- mover el nombre (0,0 = centrado)
	stacking = false, stackGap = 2, stackSpeed = 12, stackMax = 80,

	classColorPlayers = true,
	-- aliados en azul para no confundirlos con los enemigos en arena;
	-- con friendlyClassColor vuelven a su color de clase
	friendlyClassColor = false, friendlyPlayerColor = { 0, 0, 1 }, -- el azul de Blizzard

	-- cosas sacadas de RefinedBlizzPlates
	-- sombra, rastro de dano y chispa del cast
	shadow = true, shadowSize = 4, shadowAlpha = 0.6,
	healthTrail = true,
	castSpark = true,
	healthFormat = 1, healthHideMax = true,
	-- arenaIDPos: "left" a la izquierda de la barra o "name" en vez del nombre
	arenaIDs = true, partyIDs = true, arenaIDPos = "left",
	totemIcons = true, totemSize = 24, totemHideFriendly = false,
	totemX = 0, totemY = 0, -- mover el icono del totem
	totemPlateScale = 1, -- escala de las placas de totem (modo placa / icono + placa)
	-- por totem, con el ID de hechizo de clave. mode: 0 oculto, 1 icono, 2 placa, 3 icono + placa
	-- icon: ruta o ID de hechizo, vacio = el del juego
	totems = {},
	targetScale = 1.15, friendlyScale = 0.85, clampTarget = true, clampMargin = 35,
	-- aliados solo con nombre segun zona: 0 no, 1 PNJs, 2 jugadores, 3 todos
	barlessWorld = 3, barlessPvE = 3, barlessBG = 3, barlessArena = 0, barlessExcludeTarget = true,

	textColor         = { 1, 1, 1 },
	bgColor           = { 0.05, 0.05, 0.05, 0.85 },
	bgAlpha           = 0.85, -- opacidad del fondo de la barra
	iconBorder = "blizzard", -- "blizzard" (plateado) o "flat" (linea negra)
	iconBorderTint = { 1, 1, 1 },
	castColor         = { 1, 0.7, 0 },
	castNoInterruptColor = { 0.6, 0.6, 0.6 },
	-- cast cortado: se queda en rojo con "Interrupted: fulano"
	castInterruptColor = { 1, 0.1, 0.1 }, castInterruptHold = 1, showInterrupter = true,
	tfCast = true, -- lo mismo en los castbars de target y focus

	-- debuffs importantes (venia de la WA "[Nameplate] BigDebuffs 3.3.5")
	debuffs = true, debuffEnemyOnly = true, debuffArenaOnly = false, debuffTimer = true,
	debuffLockouts = true,
	-- lo que cambies en /hms > Hechizos
	spellOverrides = {}, -- [spellID] = { off = true, cat = "cc", pri = 80 }
	customSpells = {},   -- [spellID] = { cat = "cc", pri = 50 }
	-- GCDs de arena (venia de NameplateArenaGCDs)
	gcd = true, gcdSize = 27, gcdWidth = 27, gcdHeight = 27, gcdPos = "left", gcdX = 0, gcdY = 0,
	gcdTimer = true, gcdReverse = false, gcdHideSweep = false, gcdAlpha = 1,
	debuffSize = 30, debuffWidth = 30, debuffHeight = 30, debuffPos = "right", debuffX = 0, debuffY = 0,
	debuffCats = {
		immunities = true, cc = true, silence = true, roots = true,
		disarms = true, defensives = true, offensives = true, others = true,
	},

	hostileColor  = { 0.85, 0.20, 0.20 },
	neutralColor  = { 0.95, 0.85, 0.20 },
	friendlyColor = { 0.20, 0.80, 0.30 },
	tappedColor   = { 0.50, 0.50, 0.50 },

	classColors = {
		WARRIOR     = { 0.78, 0.61, 0.43 },
		PALADIN     = { 0.96, 0.55, 0.73 },
		DEATHKNIGHT = { 0.77, 0.12, 0.23 },
		DRUID       = { 1.00, 0.49, 0.04 },
		HUNTER      = { 0.67, 0.83, 0.45 },
		MAGE        = { 0.41, 0.80, 0.94 },
		PRIEST      = { 1.00, 1.00, 1.00 },
		ROGUE       = { 1.00, 0.96, 0.41 },
		SHAMAN      = { 0.00, 0.44, 0.87 },
		WARLOCK     = { 0.58, 0.51, 0.79 },
	},
}
SP.defaults = defaults

local cfg
local function Merge(dst, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dst[k]) ~= "table" then dst[k] = {} end
			Merge(dst[k], v)
		elseif dst[k] == nil then
			dst[k] = v
		end
	end
end

function SP.Reset()
	local geo = HemsworkPlatesDB.geo -- lo medido de la placa nativa no se toca
	for k in pairs(HemsworkPlatesDB) do HemsworkPlatesDB[k] = nil end
	Merge(HemsworkPlatesDB, defaults)
	HemsworkPlatesDB.geo = geo
	HemsworkPlatesDB.dbVersion = 9
	SP.Refresh()
end

local active, built = {}, {}
local dirty = {} -- placas por actualizar, se vacia una vez por frame
local guidPlate = {} -- GUID -> placa (registro de combate)
local hider = CreateFrame("Frame")
hider:Hide()
local driver = CreateFrame("Frame")
local UpdatePlate, UpdateCast

local FALLBACK_FONT = "Fonts\\FRIZQT__.TTF"
local RAID_ICONS = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local FLAT = "Interface\\Buttons\\WHITE8X8"

-- Texturas originales de las nameplates de WotLK
local HP_BORDER   = "Interface\\Tooltips\\Nameplate-Border"
local CAST_BORDER = "Interface\\CastingBar\\UI-CastingBar-Border-Small"
local CAST_SHIELD = "Interface\\CastingBar\\UI-CastingBar-Small-Shield"
local CAST_SPARK  = "Interface\\CastingBar\\UI-CastingBar-Spark"
local CAST_FILL   = "Interface\\TargetingFrame\\UI-StatusBar"
local CLASS_ICONS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
local ROLE_ICONS  = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES" -- cruz verde de sanador
-- sombra 32x32: esquinas = cuartos de la imagen, lados = la fila/columna del medio
local SHADOW      = "Interface\\AddOns\\" .. addonName .. "\\Media\\shadow.tga"

-- medidas por defecto por si no se pudo medir la placa nativa
-- x/y/w/h hueco de la barra, lx/ly centro del nivel,
-- ix/iy/is el icono, ox/oy donde va el cast respecto a la vida
local GEO_FALLBACK = {
	hp   = { bw = 128, bh = 32, x = 4,  y = 11, w = 101, h = 10, lx = 116, ly = 16 },
	cast = { bw = 128, bh = 32, x = 23, y = 11, w = 101, h = 10, ix = 12, iy = 16, is = 14, ox = 0, oy = -9 },
}

local function Geo(part)
	local g = cfg.geo and cfg.geo[part]
	if g and g.w and g.w > 0 and g.h and g.h > 0 then return g end
	return GEO_FALLBACK[part]
end

-------------------------- TOTEMS / ZONAS --------------------------
-- totems por elemento. GetSpellInfo me da el nombre ya traducido (el mismo
-- que lleva el PNJ) y el icono, asi no hacen falta texturas
SP.TOTEMS = {
	{ "earth", { 2062, 2484, 5730, 8071, 8075, 8143 } },
	{ "fire",  { 2894, 1535, 8227, 8181, 8190, 3599, 30706 } },
	{ "water", { 8170, 8184, 5394, 5675, 16190, 8166 } },
	{ "air",   { 8177, 10595, 6495, 8512, 3738 } },
}
local totemByName
local function TotemID(name)
	if not totemByName then
		totemByName = {}
		for _, grp in ipairs(SP.TOTEMS) do
			for _, id in ipairs(grp[2]) do
				local n = GetSpellInfo(id)
				if n then totemByName[n] = id end
			end
		end
	end
	-- ojo, hay servers que meten el rango en romanos ("Searing Totem VII")
	return totemByName[name] or totemByName[(string.gsub(name, "%s+[IVXL]+$", ""))]
end

-- icono del totem: el que hayas puesto o el del juego
function SP.TotemTexture(id)
	local t = cfg.totems[id]
	local custom = t and t.icon
	if custom and custom ~= "" then
		local sid = tonumber(custom)
		if sid then
			local _, _, icon = GetSpellInfo(sid)
			if icon then return icon end
		else
			return custom
		end
	end
	local _, _, icon = GetSpellInfo(id)
	return icon
end

local zoneType = "none"
local function UpdateZone()
	local _, t = IsInInstance()
	zoneType = t or "none"
end

-- aliados solo con nombre segun zona (0 no, 1 PNJs, 2 jugadores, 3 todos)
local function BarlessFor(isPlayer)
	local f
	if zoneType == "arena" then f = cfg.barlessArena
	elseif zoneType == "pvp" then f = cfg.barlessBG
	elseif zoneType == "party" or zoneType == "raid" then f = cfg.barlessPvE
	else f = cfg.barlessWorld end
	return f == 3 or f == (isPlayer and 2 or 1)
end

local function Short(v)
	if v >= 1e6 then return string.format("%.1fm", v / 1e6) end
	if v >= 1e3 then return string.format("%.1fk", v / 1e3) end
	return tostring(v)
end

-- formatos de vida, los mismos que RBP
local function HealthString(v, m)
	if v <= 0 or (cfg.healthHideMax and v >= m) then return "" end
	local f, pct = cfg.healthFormat, v / m
	if f == 2 then return v >= m and "100%" or string.format("%.1f%%", math.floor(pct * 1000) / 10)
	elseif f == 3 then return Short(v)
	elseif f == 4 then return Short(v) .. " / " .. Short(m)
	elseif f == 5 then return Short(v) .. " (" .. math.floor(pct * 100) .. "%)"
	elseif f == 6 then return v < m and ("-" .. Short(m - v)) or ""
	end
	return math.floor(pct * 100) .. "%"
end

------------------------------ PIXEL PERFECT -----------------------
-- cuanto mide 1 pixel real en unidades del frame
local function PixelUnit(frame)
	local h = tonumber(string.match(GetCVar("gxResolution") or "", "%d+x(%d+)")) or 768
	return 768 / h / frame:GetEffectiveScale()
end

local function Snap(v, px)
	if not cfg.pixelPerfect or not px then return v end
	return math.floor(v / px + 0.5) * px
end

local function SnapSize(v, px)
	if not cfg.pixelPerfect or not px then return v end
	return math.max(px, math.floor(v / px + 0.5) * px)
end

------------------------------ UTILIDADES --------------------------
-- si una placa da error, que no se lleve a las demas por delante.
-- el error sale una sola vez en el chat para poder verlo
local reported = {}
local function SafeCall(fn, plate)
	local ok, err = pcall(fn, plate)
	if not ok and not reported[err] then
		reported[err] = true
		DEFAULT_CHAT_FRAME:AddMessage("|cffff5555HemsworkPlates error:|r " .. tostring(err))
	end
end

local function SetFontSafe(fs, path, size, flags)
	if not fs:SetFont(path, size, flags or "") then
		fs:SetFont(FALLBACK_FONT, size, flags or "")
	end
end

local function NewFont(parent, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(FALLBACK_FONT, 10, "")
	fs:SetShadowColor(0, 0, 0, 0.9)
	fs:SetShadowOffset(1, -1)
	fs:SetJustifyH(justify or "LEFT")
	return fs
end

local function Toggle(f, on) if on then f:Show() else f:Hide() end end

-- nombre en una fila; si no cabe se corta con ...
-- (lo mido con un fontstring escondido, asi va en cualquier cliente)
local measure
local function TextWidth(text, path, size, flags)
	if not measure then
		measure = UIParent:CreateFontString(nil, "OVERLAY")
		measure:SetAlpha(0)
	end
	SetFontSafe(measure, path, size, flags)
	measure:SetText(text)
	return measure:GetStringWidth()
end

local function FitText(text, maxW, path, size, flags)
	if not text or text == "" or not maxW or maxW <= 0 then return text end
	if TextWidth(text, path, size, flags) <= maxW then return text end
	local s = text
	while #s > 1 do
		-- quitar una letra entera, ojo con los caracteres UTF-8 de varios bytes
		local i = #s
		while i > 1 and string.byte(s, i) >= 128 and string.byte(s, i) < 192 do i = i - 1 end
		s = string.sub(s, 1, i - 1)
		if TextWidth(s .. "...", path, size, flags) <= maxW then return s .. "..." end
	end
	return "..."
end

local function SetName(sp, name)
	sp.nameStr = name
	sp.name:SetText(FitText(name, cfg.nameWidth, cfg.font, cfg.fontSize, cfg.fontOutline))
end

-- tokens precalculados: montar "arena" .. i cada vez genera basura
-- y luego el GC da tirones
local ARENA, PARTY, PLATE_TOKENS, NUM = {}, {}, {}, {}
for i = 1, 40 do
	PLATE_TOKENS[i] = "nameplate" .. i
	NUM[i] = tostring(i)
end
for i = 1, 5 do ARENA[i] = "arena" .. i end
for i = 1, 4 do PARTY[i] = "party" .. i end

-- medidor de rendimiento (/hms perf)
local clock = debugprofilestop or function() return GetTime() * 1000 end
local perf = { start = GetTime(), frames = 0, total = 0, max = 0, evMax = 0, update = 0, restyle = 0, cast = 0, built = 0 }
SP.perf = perf

-- saca una pieza nativa de la placa. con alpha no vale (el juego lo vuelve a poner), con el parent si
local function Kill(obj)
	if not obj then return end
	if not pcall(obj.SetParent, obj, hider) then obj:SetAlpha(0) end
end

-- se llama al crear la placa y luego cada cierto tiempo, porque el parche de
-- castbars crea su barra con el primer cast y tambien hay que esconderla.
-- OJO: nunca tocar frames de otros addons ni protegidos, en combate salta
-- el "HemsworkPlates has been blocked from an action..."
local function HideNatives(plate, onlyIfChanged)
	-- en el repaso solo se mira si hay un hijo nuevo
	if onlyIfChanged and plate:GetNumChildren() == plate.spNumChildren then return end
	local first = not plate.spHidden
	for _, c in ipairs({ plate:GetChildren() }) do
		if c ~= plate.sp and not (c.IsProtected and c:IsProtected()) then
			if first then
				if c:GetObjectType() == "StatusBar" then
					if not plate.spNativeHealth then
						plate.spNativeHealth = c
					elseif not plate.spNativeCast then
						plate.spNativeCast = c
					end
				end
				Kill(c)
			elseif not plate.spNativeCast and c:GetObjectType() == "StatusBar" and not c:GetName() then
				-- castbar del parche, aparece despues que la placa
				plate.spNativeCast = c
				Kill(c)
			end
		end
	end
	if first then
		-- copia de las regiones: al cambiarles el parent la lista se encoge y
		-- pidiendola en cada vuelta me saltaba la mitad
		local regions = { plate:GetRegions() }
		local fake = plate.spFake
		for i = 1, #regions do
			local r = regions[i]
			if not (fake and fake[r]) then
				-- piezas nativas que sigo leyendo aunque esten escondidas (el juego las
				-- sigue actualizando): nombre, nivel, highlight, marca y jefe
				local n = plate.spN or {}
				plate.spN = n
				if r:GetObjectType() == "FontString" then
					if not n.name then n.name = r elseif not n.level then n.level = r end
				else
					local t = strlower(r:GetTexture() or "")
					if t:find("glow") then n.highlight = r
					elseif t:find("raidtargeting") then n.raid = r
					elseif t:find("skull") then n.boss = r end
				end
				-- el primer texto nativo es el nombre (lo necesita lo de WeakAuras)
				if not plate.spNativeName and r:GetObjectType() == "FontString" then plate.spNativeName = r end
				Kill(r)
			end
		end
		plate.spHidden = true
	end
	plate.spNumChildren = plate:GetNumChildren()
end

-- compat con WeakAuras 3.3.5 (GetUnitNameplate / WatchNamePlates).
-- WA reconoce la placa por su 1a region (la textura de amenaza) y saca
-- el nombre de la 7a. Como las nativas las saco de la placa, dejo 7
-- regiones invisibles mias con la misma forma.
local WA_OVERLAY = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
local function SetupWACompat(plate)
	local fake = {}
	local glow = plate:CreateTexture(nil, "BACKGROUND")
	glow:SetTexture(WA_OVERLAY)
	glow:SetAlpha(0)
	glow:Hide()
	fake[glow] = true
	for _ = 2, 6 do
		local t = plate:CreateTexture(nil, "BACKGROUND")
		t:Hide()
		fake[t] = true
	end
	local name = plate:CreateFontString(nil, "BACKGROUND")
	name:SetFont(FALLBACK_FONT, 8, "")
	name:SetAlpha(0)
	name:Hide()
	fake[name] = true
	plate.spFake = fake
	plate.spWAName = name
	-- este hook va antes que el de WA, asi el nombre ya esta puesto
	-- cuando WA lo lee
	plate:HookScript("OnShow", function(self)
		local n = self.spNativeName and self.spNativeName:GetText()
		if n then name:SetText(n) end
	end)
end

------------------------ MEDICION NATIVA ---------------------------
-- antes de esconder la placa nativa mido donde pone Blizzard cada cosa,
-- asi el estilo clasico sale clavado al original
local function Rect(o)
	if not o then return end
	local l, b, w, h = o:GetLeft(), o:GetBottom(), o:GetWidth(), o:GetHeight()
	if l and b and w and h and w > 0 and h > 0 then return l, b, w, h end
end

local function CaptureGeo(plate)
	cfg.geo = cfg.geo or {}
	if cfg.geo.hp and cfg.geo.cast then return end

	local bars = {}
	for _, c in ipairs({ plate:GetChildren() }) do
		if c:GetObjectType() == "StatusBar" then bars[#bars + 1] = c end
	end
	local hpBar, castBar = bars[1], bars[2]

	local hpBorder, castBorder, icon, level
	local fonts = {}
	for i = 1, select("#", plate:GetRegions()) do
		local r = select(i, plate:GetRegions())
		local t = r:GetObjectType()
		if t == "Texture" then
			local p = strlower(r:GetTexture() or "")
			if p:find("nameplate%-border") then
				hpBorder = r
			elseif p:find("nameplate%-castbar") then
				if not p:find("shield") then castBorder = r end
			elseif not p:find("tooltips") and not p:find("targetingframe") then
				local _, rel = r:GetPoint(1)
				if rel and castBar and (rel == castBar or rel == castBorder) then icon = r end
			end
		elseif t == "FontString" then
			fonts[#fonts + 1] = r
		end
	end
	level = fonts[2]

	local bl, bb, bw, bh = Rect(hpBorder)
	local hl, hb, hw, hh = Rect(hpBar)
	if not cfg.geo.hp and bl and hl then
		local g = { bw = bw, bh = bh, x = hl - bl, y = hb - bb, w = hw, h = hh }
		local ll, lb, lw, lh = Rect(level)
		if ll then
			g.lx, g.ly = ll + lw / 2 - bl, lb + lh / 2 - bb
		else
			local f = GEO_FALLBACK.hp
			g.lx, g.ly = f.lx * bw / f.bw, f.ly * bh / f.bh
		end
		cfg.geo.hp = g
	end

	local cl, cbb, cw, chh = Rect(castBorder)
	local xl, xb, xw, xh = Rect(castBar)
	if not cfg.geo.cast and cl and xl and hl then
		local g = { bw = cw, bh = chh, x = xl - cl, y = xb - cbb, w = xw, h = xh,
			ox = xl - hl, oy = (xb + xh) - hb }
		local il, ib, iw, ih = Rect(icon)
		if il then
			g.ix, g.iy, g.is = il + iw / 2 - cl, ib + ih / 2 - cbb, ih
		else
			local f = GEO_FALLBACK.cast
			g.ix, g.iy, g.is = f.ix * cw / f.bw, f.iy * chh / f.bh, f.is * chh / f.bh
		end
		cfg.geo.cast = g
	end
end

------------------------- "PILDORAS" (barras) ----------------------
-- un frame con una textura que lo llena (fondo, relleno, contorno...)
local function NewPill(parent, level)
	local f = CreateFrame("Frame", nil, parent)
	f:SetFrameLevel(parent:GetFrameLevel() + level)
	local p = { f = f }
	p.m = f:CreateTexture(nil, "ARTWORK")
	p.m:SetTexture(FLAT)
	p.m:SetAllPoints(f)
	return p
end

local function ColorPill(p, r, g, b, a)
	p.m:SetVertexColor(r, g, b, a or 1)
end

local function SetFill(p, w, pct)
	if not pct or pct ~= pct or pct <= 0 then p.f:Hide() return end
	if pct > 1 then pct = 1 end
	p.f:SetWidth(w * pct)
	p.f:Show()
end

-- trozos de la sombra: 4 esquinas y luego arriba, abajo, izq, der
local SHADOW_COORDS = {
	{ 0, 0.5, 0, 0.5 }, { 0.5, 1, 0, 0.5 }, { 0, 0.5, 0.5, 1 }, { 0.5, 1, 0.5, 1 },
	{ 0.5, 0.5, 0, 0.5 }, { 0.5, 0.5, 0.5, 1 }, { 0, 0.5, 0.5, 0.5 }, { 0.5, 1, 0.5, 0.5 },
}

-- o = grosor del contorno, s = tamano de la sombra
local function LayoutShadow(owner, o, s, on)
	if not on or s <= 0 then owner.shf:Hide() return end
	local t = owner.sh
	for i = 1, 4 do
		t[i]:ClearAllPoints()
		t[i]:SetWidth(s)
		t[i]:SetHeight(s)
	end
	t[1]:SetPoint("BOTTOMRIGHT", owner, "TOPLEFT", -o, o)
	t[2]:SetPoint("BOTTOMLEFT", owner, "TOPRIGHT", o, o)
	t[3]:SetPoint("TOPRIGHT", owner, "BOTTOMLEFT", -o, -o)
	t[4]:SetPoint("TOPLEFT", owner, "BOTTOMRIGHT", o, -o)
	for i = 5, 8 do t[i]:ClearAllPoints() end
	t[5]:SetPoint("BOTTOMLEFT", owner, "TOPLEFT", -o, o)
	t[5]:SetPoint("TOPRIGHT", owner, "TOPRIGHT", o, o + s)
	t[6]:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", -o, -o)
	t[6]:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", o, -o - s)
	t[7]:SetPoint("TOPRIGHT", owner, "TOPLEFT", -o, o)
	t[7]:SetPoint("BOTTOMLEFT", owner, "BOTTOMLEFT", -o - s, -o)
	t[8]:SetPoint("TOPLEFT", owner, "TOPRIGHT", o, o)
	t[8]:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", o + s, -o)
	local a = cfg.shadowAlpha or 0.6
	for i = 1, 8 do t[i]:SetVertexColor(1, 1, 1, a) end
	owner.shf:Show()
end

-- fondo + relleno sobre "owner" (vida y cast)
local function BuildBarParts(owner)
	owner.bgp = NewPill(owner, 2)
	owner.fillp = NewPill(owner, 4)
	-- capa del borde clasico: encima del relleno, debajo del texto
	owner.cl = CreateFrame("Frame", nil, owner)
	owner.cl:SetAllPoints(owner)
	owner.cl:SetFrameLevel(owner:GetFrameLevel() + 5)
	owner.border = owner.cl:CreateTexture(nil, "ARTWORK")
	owner.border:Hide()
end

local function StyleBarParts(owner, h, tex)
	owner.bgp.f:ClearAllPoints()
	owner.bgp.f:SetAllPoints(owner)
	owner.bgp.f:Show()
	local bg = cfg.bgColor
	ColorPill(owner.bgp, bg[1], bg[2], bg[3], cfg.bgAlpha or bg[4])

	owner.fillp.m:SetTexture(tex)
	owner.fillp.f:ClearAllPoints()
	owner.fillp.f:SetPoint("LEFT", owner, "LEFT", 0, 0)
	owner.fillp.f:SetHeight(h)
end

-- borde de los iconos. "blizzard" es el marco que usa BigDebuffs
-- (Interface\\Buttons\\UI-Quickslot2, el de los botones de accion) con su
-- proporcion original (66 sobre 36). "flat" es solo la linea negra.
-- owner: frame con las texturas, icon: el icono, edge: filo negro
local ICON_FRAME = "Interface\\Buttons\\UI-Quickslot2"
-- recorte para que el icono no se estire si no es cuadrado
function SP.CropIcon(tex, w, h)
	local lo, hi = 0.08, 0.92
	local span = hi - lo
	w, h = tonumber(w) or 1, tonumber(h) or 1
	if w <= 0 or h <= 0 then tex:SetTexCoord(lo, hi, lo, hi) return end
	if w > h then
		local v = span * h / w / 2
		tex:SetTexCoord(lo, hi, 0.5 - v, 0.5 + v)
	elseif h > w then
		local u = span * w / h / 2
		tex:SetTexCoord(0.5 - u, 0.5 + u, lo, hi)
	else
		tex:SetTexCoord(lo, hi, lo, hi)
	end
end

function SP.StyleIconBorder(owner, icon, edge, size, px, h)
	h = h or size
	local function snap(v) return px and math.floor(v / px + 0.5) * px or v end
	local one = px and math.max(px, snap(1)) or 1
	local sv = owner.silver
	if cfg.iconBorder == "flat" then
		owner.silverOn = false
		if sv then sv:Hide() end
		edge:ClearAllPoints()
		edge:SetPoint("TOPLEFT", icon, "TOPLEFT", -one, one)
		edge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", one, -one)
		return
	end
	if not sv then
		sv = owner:CreateTexture(nil, "OVERLAY")
		sv:SetTexture(ICON_FRAME)
		owner.silver = sv
	end
	sv:ClearAllPoints()
	sv:SetWidth(size * 66 / 36)
	sv:SetHeight(h * 66 / 36)
	sv:SetPoint("CENTER", icon, "CENTER", 0, 0)
	local c = cfg.iconBorderTint
	sv:SetVertexColor(c[1], c[2], c[3], 1)
	sv:Show()
	owner.silverOn = true
	-- el marco ya trae su filo oscuro, el negro va justo detras del icono
	edge:ClearAllPoints()
	edge:SetAllPoints(icon)
end

-- Coloca una textura de borde Blizzard alrededor del hueco de la barra
local function PlaceClassicBorder(tex, owner, g, sx, sy, px)
	tex:ClearAllPoints()
	tex:SetWidth(SnapSize(g.bw * sx, px))
	tex:SetHeight(SnapSize(g.bh * sy, px))
	tex:SetPoint("BOTTOMLEFT", owner, "BOTTOMLEFT", Snap(-g.x * sx, px), Snap(-g.y * sy, px))
end

--------------------------- ESTILO (usa cfg) -----------------------
local function Restyle(plate)
	local sp = plate.sp
	if not sp then return end
	perf.restyle = perf.restyle + 1
	-- "old" es la placa de siempre con el marco dorado; el castbar y lo demas
	-- va igual que en "classic"
	-- perfiles viejos con Cuadrada/Redonda pasan a Clasico
	if cfg.shape ~= "old" and cfg.shape ~= "classic" then cfg.shape = "classic" end
	local old = cfg.shape == "old"
	local fs, outline = cfg.fontSize, cfg.fontOutline

	sp:SetScale(cfg.scale * (sp.scaleMul or 1))
	local px = PixelUnit(sp)
	sp.px = px

	local w, h, ch = SnapSize(cfg.width, px), SnapSize(cfg.height, px), SnapSize(cfg.castHeight, px)
	sp:SetWidth(w)
	sp:SetHeight(h)
	sp.fw = w
	StyleBarParts(sp, h, cfg.texture)
	sp.trail.m:SetTexture(cfg.texture)
	sp.trail.f:ClearAllPoints()
	sp.trail.f:SetPoint("LEFT", sp, "LEFT", 0, 0)
	sp.trail.f:SetHeight(h)

	SetFontSafe(sp.name, cfg.font, fs, outline)
	SetFontSafe(sp.level, cfg.font, cfg.levelFontSize or fs, outline)
	SetFontSafe(sp.hp, cfg.font, fs - 1, outline)
	local cb = sp.cast
	local cfs = cfg.castFontSize
	SetFontSafe(cb.text, cfg.font, cfs, outline)
	SetFontSafe(cb.time, cfg.font, cfs, outline)
	-- una sola linea, si no cabe se corta en vez de partirse
	cb.text:SetHeight(cfs + 2)
	sp.texts = sp.texts or { sp.name, sp.level, sp.hp, cb.text, cb.time }
	for _, f in ipairs(sp.texts) do
		f:SetTextColor(unpack(cfg.textColor))
	end
	sp.name:SetWidth(cfg.nameWidth + 6)
	Toggle(sp.name, cfg.showName)
	Toggle(sp.level, cfg.showLevel)
	Toggle(sp.hp, cfg.showHealthText)
	Toggle(sp.cast.text, cfg.showCastText)

	sp.raid:SetWidth(16)
	sp.raid:SetHeight(16)

	cb:ClearAllPoints()
	cb:SetHeight(ch)
	cb.icon:ClearAllPoints()
	cb.text:ClearAllPoints()
	cb.time:ClearAllPoints()

	local one = SnapSize(1, px)
	local oldGap = 0
	if old then
		-- marco dorado original (Nameplate-Border 128x32) con las medidas de la placa
		-- nativa: barra de 102.91x8.99 en x=3.97 y=4, nivel a 9.15 del final.
		-- Son las mismas que usa RefinedBlizzPlates
		local sx, sy = w / 102.91, h / 8.99
		sp.outline.f:Hide()
		sp.border:SetTexture(HP_BORDER)
		local bt = cfg.borderTint
		sp.border:SetVertexColor(bt[1], bt[2], bt[3], 1)
		sp.border:ClearAllPoints()
		sp.border:SetWidth(SnapSize(128 * sx, px))
		sp.border:SetHeight(SnapSize(32 * sy, px))
		sp.border:SetPoint("BOTTOMLEFT", sp, "BOTTOMLEFT", Snap(-3.968 * sx, px), Snap(-4 * sy, px))
		sp.border:Show()

		sp.name:ClearAllPoints()
		sp.name:SetPoint("CENTER", sp, "CENTER", Snap(cfg.nameX, px), Snap(7.5 * sy + fs * 0.5 + cfg.nameY, px))
		sp.name:SetJustifyH("CENTER")
		sp.name:SetWidth(cfg.nameWidth + 6)
		sp.level:ClearAllPoints()
		sp.level:SetPoint("CENTER", sp, "RIGHT", Snap(9.15 * sx, px), Snap(0.57 * sy, px))
		oldGap = Snap(4 * sy, px) -- el marco dorado baja ~4 por debajo de la barra
	else
		-- vida con borde negro de 1px, como en WotLK Classic
		sp.border:Hide()
		sp.outline.f:ClearAllPoints()
		sp.outline.f:SetPoint("TOPLEFT", sp, "TOPLEFT", -one, one)
		sp.outline.f:SetPoint("BOTTOMRIGHT", sp, "BOTTOMRIGHT", one, -one)
		ColorPill(sp.outline, 0, 0, 0, 1)
		sp.outline.f:Show()

		sp.name:ClearAllPoints()
		sp.name:SetPoint("BOTTOM", sp, "TOP", Snap(cfg.nameX, px), one + Snap(2 + cfg.nameY, px))
		sp.name:SetJustifyH("CENTER")
		sp.name:SetWidth(cfg.nameWidth + 6)
		sp.level:ClearAllPoints()
		sp.level:SetPoint("LEFT", sp, "RIGHT", one + Snap(4, px), 0)
	end

	-- cast con el marco plateado de Blizzard (el del target) a su proporcion
	-- original: barra 150x10, borde 197x49 anclado TOP +20, icono 16x16 a 5.
	-- Empieza donde la vida y llega hasta debajo del nivel,
	-- igual que en la captura de referencia
	local reach = SnapSize(one + 4 + fs * 1.1, px)
	-- castWidth puede ser negativo, pero sin bajar del minimo
	local extraW = tonumber(cfg.castWidth) or 0
	if w + reach + extraW < 40 then extraW = 40 - w - reach end
	reach = reach + extraW
	local cw = w + reach
	local fx, fy = cw / 150, ch / 10
	local cy = tonumber(cfg.castY) or 0 -- mover el castbar arriba (+) / abajo (-)
	cb:SetPoint("TOPLEFT", sp, "BOTTOMLEFT", 0, -Snap(one + 4 + 3 * fy, px) - oldGap + Snap(cy, px))
	cb:SetPoint("TOPRIGHT", sp, "BOTTOMRIGHT", reach, -Snap(one + 4 + 3 * fy, px) - oldGap + Snap(cy, px))
	cb.fw = cw
	StyleBarParts(cb, ch, CAST_FILL)

	for _, t in ipairs({ cb.border, cb.shield }) do
		t:ClearAllPoints()
		t:SetWidth(SnapSize(197 * fx, px))
		t:SetHeight(SnapSize(49 * fy, px))
		t:SetPoint("TOP", cb, "TOP", 0, Snap(20 * fy, px))
	end
	cb.border:SetTexture(CAST_BORDER)
	cb.shield:SetTexture(CAST_SHIELD)
	local cbt, cpt = cfg.castBorderTint, cfg.castProtectedBorderTint
	cb.border:SetVertexColor(cbt[1], cbt[2], cbt[3], 1)
	cb.shield:SetVertexColor(cpt[1], cpt[2], cpt[3], 1)
	cb.border:Show()
	cb.shield:Hide()

	cb.spark:SetWidth(SnapSize(32 * fy, px))
	cb.spark:SetHeight(SnapSize(32 * fy, px))

	local isz = SnapSize(16 * fy, px)
	-- icono pegado al marco con su borde negro
	cb.icon:SetPoint("RIGHT", cb, "LEFT", -Snap(2.5 * fy, px), 0)
	cb.iconEdge:SetAlpha(1)
	cb.iconEdge:ClearAllPoints()
	cb.iconEdge:SetPoint("TOPLEFT", cb.icon, "TOPLEFT", -one, one)
	cb.iconEdge:SetPoint("BOTTOMRIGHT", cb.icon, "BOTTOMRIGHT", one, -one)
	cb.iconEdge:SetTexture(0, 0, 0, 1)
	SP.StyleIconBorder(cb.ico, cb.icon, cb.iconEdge, isz, px)

	cb.text:SetPoint("CENTER", cb, "CENTER", 0, 0)
	cb.text:SetWidth(cw - 2 * (cfs * 2 + 4))
	cb.time:SetPoint("RIGHT", cb, "RIGHT", -2, 0)
	cb.icon:SetWidth(isz)
	cb.icon:SetHeight(isz)

	-- en 3.3.5 un FontString no pilla la fuente nueva hasta que le cambias
	-- el texto, asi que lo vacio y lo vuelvo a poner
	for _, f in ipairs(sp.texts) do
		local t = f:GetText()
		f:SetText("")
		f:SetText(t)
	end

	-- calavera encima del nivel
	local bz = SnapSize(cfg.bossIconSize, px)
	sp.boss:SetWidth(bz)
	sp.boss:SetHeight(bz)
	sp.boss:ClearAllPoints()
	if old then sp.boss:SetPoint("CENTER", sp.level, "CENTER", 0, 0)
	else sp.boss:SetPoint("LEFT", sp.level, "LEFT", 0, 0) end

	-- grosor del contorno (lo usan la sombra y lo que va a los lados)
	local o = one
	LayoutShadow(sp, o, SnapSize(cfg.shadowSize or 4, px), cfg.shadow and not old)

	-- Icono de totem
	-- con placa + icono la escala del totem tambien encoge el icono, se compensa
	-- para que vayan por separado
	local tcomp = sp.totemBeside and (cfg.totemPlateScale or 1) or 1
	local ts = SnapSize(cfg.totemSize / tcomp, px)
	sp.totem:SetWidth(ts)
	sp.totem:SetHeight(ts)
	sp.totem:ClearAllPoints()
	if sp.totemBeside then
		-- al lado de la placa, a la izquierda y centrado
		sp.totem:SetPoint("RIGHT", sp, "LEFT", Snap(cfg.totemX - 6 - (old and 4 or 0), px), Snap(cfg.totemY, px))
	else
		sp.totem:SetPoint("CENTER", sp, "CENTER", Snap(cfg.totemX, px), Snap(cfg.totemY, px))
	end
	local te = SnapSize(2, px)
	sp.totem.edge:ClearAllPoints()
	sp.totem.edge:SetPoint("TOPLEFT", sp.totem, "TOPLEFT", -te, te)
	sp.totem.edge:SetPoint("BOTTOMRIGHT", sp.totem, "BOTTOMRIGHT", te, -te)

	-- icono de clase a la izquierda (en el Antiguo, por fuera del marco)
	local cls = sp.cls
	sp.clsSpace = 0
	if cfg.classIcon then
		local cs = SnapSize(cfg.classIconSize, px)
		-- pegado al borde + la separacion que pongas
		local cgap = (old and Snap(3.968 * w / 102.91, px) or o) + Snap(cfg.classIconGap or 0, px)
		cls:SetWidth(cs)
		cls:SetHeight(cs)
		cls:ClearAllPoints()
		cls:SetPoint("RIGHT", sp, "LEFT", -cgap, 0)
		SP.StyleIconBorder(cls, cls.icon, cls.edge, cs, px)
		sp.clsSpace = cgap + cs
	end
	cls:Hide()
	sp.clsClass = nil

	-- numero de arena/grupo a la izquierda (y del icono de clase si hay)
	SetFontSafe(sp.idText, cfg.font, fs + 4, "OUTLINE")
	sp.idText:ClearAllPoints()
	sp.idText:SetPoint("RIGHT", sp, "LEFT", -Snap(4, px) - math.max(o, sp.clsSpace), 0)
	sp.idText:Hide()
	sp.raid:ClearAllPoints()
	sp.raid:SetPoint("RIGHT", sp, "LEFT", -3 - sp.clsSpace, 0)

	if SP.LayoutDebuff then SP.LayoutDebuff(sp, px, fs) end
	if SP.LayoutGCD then SP.LayoutGCD(sp, px, fs) end
	sp.auraDirty = true

	sp.cr, sp.castNI, sp.lvlStr, sp.nameStr = nil, nil, nil, nil
	cb.lastSpell, cb.lastIcon, cb.lastT = nil, nil, nil
	sp.healPos = nil -- que la cruz se recoloque con el tamano nuevo
	sp.idStr = false -- false y no nil, si no el numero viejo se queda puesto
	SP.ApplyMode(sp, sp.mode or "normal")
end

-- modos: "normal", "barless" (solo nombre), "totem" o "hidden"
function SP.ApplyMode(sp, mode)
	if mode ~= "normal" then
		sp.barParts = sp.barParts or { sp.outline.f, sp.bgp.f, sp.fillp.f, sp.cast, sp.shf, sp.trail.f, sp.cls }
		for _, f in ipairs(sp.barParts) do f:Hide() end
		if sp.debuff then sp.debuff:Hide() end
		if sp.gcdFrame then sp.gcdFrame:Hide() end
		sp.casting = false
		sp.border:Hide()
		sp.level:Hide()
		sp.boss:Hide()
		sp.hp:Hide()
		sp.idText:Hide()
		Toggle(sp.name, mode == "barless")
	end
	Toggle(sp.totem, mode == "totem" or (sp.totemBeside and mode ~= "hidden"))
end

local function Build(plate)
	-- para /hms debug: como era la placa nativa antes de esconderla
	local info = {}
	for _, c in ipairs({ plate:GetChildren() }) do info[#info + 1] = "hijo:" .. c:GetObjectType() end
	local regions = { plate:GetRegions() }
	for i = 1, #regions do
		info[#info + 1] = i .. ":" .. regions[i]:GetObjectType()
	end
	plate.spDebug = table.concat(info, ", ")

	perf.built = perf.built + 1
	pcall(CaptureGeo, plate)
	HideNatives(plate)
	SetupWACompat(plate)

	local sp = CreateFrame("Frame", nil, plate)
	sp:SetPoint("CENTER", plate, "CENTER", 0, 0)
	sp.curOff = 0
	BuildBarParts(sp)
	-- contorno de 1px (solo la vida; el cast lleva el marco plateado)
	sp.outline = NewPill(sp, 1)
	sp.trail = NewPill(sp, 3)
	sp.trail.f:Hide()
	-- sombra por fuera del contorno, debajo de todo
	sp.shf = CreateFrame("Frame", nil, sp)
	sp.shf:SetAllPoints(sp)
	sp.shf:SetFrameLevel(sp:GetFrameLevel())
	sp.sh = {}
	for i, tc in ipairs(SHADOW_COORDS) do
		local t = sp.shf:CreateTexture(nil, "BACKGROUND")
		t:SetTexture(SHADOW)
		t:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
		sp.sh[i] = t
	end
	sp.shf:Hide()

	-- Capa superior para textos e iconos
	sp.top = CreateFrame("Frame", nil, sp)
	sp.top:SetAllPoints(sp)
	sp.top:SetFrameLevel(sp:GetFrameLevel() + 8)

	sp.name = NewFont(sp.top, "LEFT")
	if sp.name.SetWordWrap then sp.name:SetWordWrap(false) end
	sp.level = NewFont(sp.top, "LEFT")
	sp.level:SetPoint("LEFT", sp, "RIGHT", 4, 0)
	sp.boss = sp.top:CreateTexture(nil, "OVERLAY")
	sp.boss:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
	sp.boss:Hide()
	sp.hp = NewFont(sp.top, "CENTER")
	sp.hp:SetPoint("CENTER", sp, "CENTER", 0, 0)

	-- Icono de totem (sustituye a la placa)
	sp.totem = CreateFrame("Frame", nil, sp)
	sp.totem:SetPoint("CENTER", sp, "CENTER", 0, 0)
	sp.totem:SetFrameLevel(sp:GetFrameLevel() + 9)
	sp.totem.edge = sp.totem:CreateTexture(nil, "BACKGROUND")
	sp.totem.edge:SetTexture(FLAT)
	sp.totem.icon = sp.totem:CreateTexture(nil, "ARTWORK")
	sp.totem.icon:SetAllPoints(sp.totem)
	sp.totem.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	sp.totem:Hide()

	sp.idText = NewFont(sp.top, "RIGHT")
	sp.idText:Hide()

	-- Icono de sanador
	sp.heal = sp.top:CreateTexture(nil, "OVERLAY")
	sp.heal:SetTexture(ROLE_ICONS)
	sp.heal:SetTexCoord(20 / 64, 39 / 64, 1 / 64, 20 / 64)
	sp.heal:Hide()

	-- Icono de clase (jugadores)
	sp.cls = CreateFrame("Frame", nil, sp)
	sp.cls:SetFrameLevel(sp:GetFrameLevel() + 9)
	sp.cls.edge = sp.cls:CreateTexture(nil, "BACKGROUND")
	sp.cls.edge:SetTexture(0, 0, 0, 1)
	sp.cls.icon = sp.cls:CreateTexture(nil, "ARTWORK")
	sp.cls.icon:SetAllPoints(sp.cls)
	sp.cls.icon:SetTexture(CLASS_ICONS)
	sp.cls:Hide()

	if SP.BuildDebuff then SP.BuildDebuff(sp) end
	if SP.BuildGCD then SP.BuildGCD(sp) end

	sp.raid = sp.top:CreateTexture(nil, "OVERLAY")
	sp.raid:SetTexture(RAID_ICONS)
	sp.raid:SetPoint("RIGHT", sp, "LEFT", -3, 0)
	sp.raid:Hide()

	-- Cast bar
	local cb = CreateFrame("Frame", nil, sp)
	cb:SetPoint("TOPLEFT", sp, "BOTTOMLEFT", 0, -4)
	cb:SetPoint("TOPRIGHT", sp, "BOTTOMRIGHT", 0, -4)
	BuildBarParts(cb)
	cb.shield = cb.cl:CreateTexture(nil, "ARTWORK")
	cb.shield:Hide()
	cb.spark = cb.cl:CreateTexture(nil, "OVERLAY")
	cb.spark:SetTexture(CAST_SPARK)
	cb.spark:SetBlendMode("ADD")
	cb.spark:Hide()
	-- el icono va debajo del marco, como el original
	cb.ico = CreateFrame("Frame", nil, cb)
	cb.ico:SetAllPoints(cb)
	cb.ico:SetFrameLevel(cb:GetFrameLevel() + 4)
	cb.iconEdge = cb.ico:CreateTexture(nil, "BACKGROUND")
	cb.iconEdge:SetTexture(0, 0, 0, 1)
	cb.icon = cb.ico:CreateTexture(nil, "ARTWORK")
	cb.icon:SetPoint("RIGHT", cb, "LEFT", -4, 0)
	cb.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	cb.top = CreateFrame("Frame", nil, cb)
	cb.top:SetAllPoints(cb)
	cb.top:SetFrameLevel(cb:GetFrameLevel() + 8)
	cb.text = NewFont(cb.top, "LEFT")
	cb.time = NewFont(cb.top, "RIGHT")
	cb:Hide()
	sp.cast = cb

	-- sin token no hay eventos de vida, asi que escucho a la barra nativa
	if plate.spNativeHealth then
		plate.spNativeHealth:HookScript("OnValueChanged", function()
			if active[plate] then dirty[plate] = true end
		end)
	end

	plate.sp = sp
	built[plate] = true
	SafeCall(Restyle, plate)
end

------------------------------ COLORES -----------------------------
local function UnitColor(unit)
	if not cfg.friendlyClassColor and UnitIsPlayer(unit) and UnitIsFriend("player", unit) then
		local c = cfg.friendlyPlayerColor
		return c[1], c[2], c[3]
	end
	if cfg.classColorPlayers and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local c = class and cfg.classColors[class]
		if c then return c[1], c[2], c[3] end
	end
	local c
	-- tapeado por otro (igual que UnitIsTapDenied de ClassicAPI). si el mob
	-- da credito a todos los que le pegan (UnitIsTappedByAllThreatList) no cuenta
	if not UnitIsPlayer(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)
		and not (UnitIsTappedByAllThreatList and UnitIsTappedByAllThreatList(unit)) then
		c = cfg.tappedColor
	else
		local reaction = UnitReaction(unit, "player")
		if not reaction then
			c = UnitIsEnemy("player", unit) and cfg.hostileColor or cfg.neutralColor
		elseif reaction <= 3 then c = cfg.hostileColor
		elseif reaction == 4 then c = cfg.neutralColor
		else c = cfg.friendlyColor end
	end
	return c[1], c[2], c[3]
end

-- icono del hechizo de la barra nativa del parche, si lo trae
local function NativeCastIcon(nc)
	for i = 1, select("#", nc:GetRegions()) do
		local r = select(i, nc:GetRegions())
		if r:GetObjectType() == "Texture" then
			local t = r:GetTexture()
			if t and strlower(t):find("icons") then return t end
		end
	end
end

-------------------------- DATOS SIN AWESOME --------------------------
local ARENAPET, PARTYPET = {}, {}
for i = 1, 5 do ARENAPET[i] = "arenapet" .. i end
for i = 1, 4 do PARTYPET[i] = "partypet" .. i end

-- Nombre de la placa (sin la marca de otro reino "(*)")
local function NativeName(plate)
	local n = plate.spN and plate.spN.name
	local t = n and n:GetText()
	if not t then return "" end
	return (string.gsub(t, "%s*%(%*%)$", ""))
end

-- el juego solo deja a alpha 1 la placa del target
local function IsTargetPlate(plate, name)
	return UnitExists("target") and plate:GetAlpha() > 0.999 and UnitName("target") == name
end

local function IsHoverPlate(plate)
	local h = plate.spN and plate.spN.highlight
	return h and h:IsShown() and true or false
end

-- token para la placa, por nombre. en arena los nombres de jugadores son
-- unicos; mascotas con el mismo nombre si se pueden liar
local function ResolveUnit(name, isTarget, hover)
	if name == "" then return end
	if zoneType == "arena" then
		for i = 1, 5 do if UnitName(ARENA[i]) == name then return ARENA[i] end end
		for i = 1, 4 do if UnitName(PARTY[i]) == name then return PARTY[i] end end
		for i = 1, 5 do if UnitName(ARENAPET[i]) == name then return ARENAPET[i] end end
		for i = 1, 4 do if UnitName(PARTYPET[i]) == name then return PARTYPET[i] end end
	end
	if isTarget then return "target" end
	if hover and UnitName("mouseover") == name then return "mouseover" end
	if UnitName("focus") == name then return "focus" end
	if zoneType ~= "arena" and GetNumPartyMembers() > 0 then
		for i = 1, 4 do if UnitName(PARTY[i]) == name then return PARTY[i] end end
	end
end

-- sin token: reaccion y clase sacadas del color de la barra nativa
-- (con ShowClassColorInNameplate los enemigos salen con color de clase)
local function Near(a, b) return math.abs(a - b) < 0.03 end
local function NativeInfo(plate)
	local hb = plate.spNativeHealth
	if not hb then return false, false, nil, "hostile" end
	local r, g, b = hb:GetStatusBarColor()
	if RAID_CLASS_COLORS then
		for class, c in pairs(RAID_CLASS_COLORS) do
			if Near(r, c.r) and Near(g, c.g) and Near(b, c.b) then return true, false, class, "hostile" end
		end
	end
	if b > 0.9 and r < 0.1 and g < 0.1 then return true, true, nil, "friendlyPlayer" end   -- jugador amistoso
	if g > 0.9 and r < 0.1 and b < 0.1 then return false, true, nil, "friendly" end  -- PNJ amistoso
	if r > 0.9 and g > 0.9 and b < 0.1 then return false, false, nil, "neutral" end
	if Near(r, g) and Near(g, b) then return false, false, nil, "tapped" end
	return false, false, nil, "hostile"
end

local function NativeColor(class, kind)
	if class and cfg.classColorPlayers and cfg.classColors[class] then
		local c = cfg.classColors[class]
		return c[1], c[2], c[3]
	end
	local c = (kind == "friendlyPlayer" and cfg.friendlyPlayerColor)
		or (kind == "friendly" and cfg.friendlyColor) or (kind == "neutral" and cfg.neutralColor)
		or (kind == "tapped" and cfg.tappedColor) or cfg.hostileColor
	return c[1], c[2], c[3]
end

local function NativeHealth(plate)
	local hb = plate.spNativeHealth
	if not hb then return 1, 1 end
	local mn, mx = hb:GetMinMaxValues()
	return hb:GetValue() - mn, math.max(mx - mn, 1)
end

local function NativeLevel(plate)
	local n = plate.spN
	if n and n.boss and n.boss:IsShown() then return nil end
	return tonumber(n and n.level and n.level:GetText() or "")
end

local function NativeRaidIndex(plate)
	local r = plate.spN and plate.spN.raid
	if not r or not r:IsShown() then return end
	local x, y = r:GetTexCoord()
	return math.floor(y * 4 + 0.5) * 4 + math.floor(x * 4 + 0.5) + 1
end

-- clones del mago (Mirror Image): se llaman igual que el mago, asi que al
-- emparejar por nombre se quedaban con su cast y se peleaban con su placa
-- (por eso parpadeaba). Si hay un mago con ese nombre pero la barra nativa
-- de esta placa es de PNJ (roja o verde), es un clon.
-- Ante la duda NO se trata como clon.
local CLONE_TOKENS = { "arena1", "arena2", "arena3", "arena4", "arena5",
	"party1", "party2", "party3", "party4", "focus", "target", "mouseover" }
local function IsMageClone(plate, name)
	if name == "" then return false end
	local hb = plate.spNativeHealth
	if not hb then return false end
	local r, g, b = hb:GetStatusBarColor()
	if not (r and g and b) then return false end
	local npcColor
	if r > 0.9 and g < 0.15 and b < 0.15 then
		-- el rojo solo vale si estan activos los colores de clase
		npcColor = GetCVar("ShowClassColorInNameplate") == "1"
	elseif g > 0.9 and r < 0.1 and b < 0.15 then
		npcColor = true -- verde: PNJ amistoso
	end
	if not npcColor then return false end
	for i = 1, #CLONE_TOKENS do
		local tok = CLONE_TOKENS[i]
		if UnitExists(tok) and UnitName(tok) == name and UnitIsPlayer(tok) then
			local _, class = UnitClass(tok)
			if class == "MAGE" then return true end
		end
	end
	return false
end

-- Nombre -> placa (para los eventos de unidad) y GUID -> placa (registro de combate)
local plateByName = {}
local function SetPlateUnit(plate, name, unit, clone)
	local sp = plate.sp
	if clone then
		-- los clones no se registran, el nombre es de la placa del mago de verdad
		if plate.spName and plateByName[plate.spName] == plate then plateByName[plate.spName] = nil end
		if plate.spGUID and guidPlate[plate.spGUID] == plate then guidPlate[plate.spGUID] = nil end
		plate.spName, plate.spGUID = name, nil
		if plate.spUnit ~= unit then plate.spUnit = unit; sp.auraDirty = true end
		return
	end
	if plate.spName ~= name then
		if plate.spName and plateByName[plate.spName] == plate then plateByName[plate.spName] = nil end
		plate.spName = name
		sp.auraDirty, sp.intUntil, sp.castNI = true, nil, nil
	end
	if name ~= "" then plateByName[name] = plate end
	if plate.spUnit ~= unit then
		plate.spUnit = unit
		sp.auraDirty = true
	end
	local guid = unit and UnitGUID(unit)
	if plate.spGUID ~= guid then
		if plate.spGUID and guidPlate[plate.spGUID] == plate then guidPlate[plate.spGUID] = nil end
		plate.spGUID = guid
	end
	if guid then guidPlate[guid] = plate end
end

-- Color del nivel segun dificultad (como en las placas originales)
local DiffColor = GetQuestDifficultyColor or GetDifficultyColor

------------------------------ UPDATE ------------------------------
-- Numero de arena (enemigos) o de grupo (aliados) dentro de arenas
local function ArenaID(unit)
	if zoneType ~= "arena" then return end
	if cfg.arenaIDs then
		for i = 1, 5 do if UnitIsUnit(unit, ARENA[i]) then return NUM[i], 1, 0.3, 0.3 end end
	end
	if cfg.partyIDs then
		for i = 1, 4 do if UnitIsUnit(unit, PARTY[i]) then return NUM[i], 0.3, 1, 0.3 end end
	end
end

local function UpdateTotemIcon(sp, tid, isTarget, friendly)
	sp.totem.icon:SetTexture(SP.TotemTexture(tid))
	if isTarget then sp.totem.edge:SetVertexColor(1, 1, 0.3, 1)
	elseif friendly then sp.totem.edge:SetVertexColor(0.1, 0.9, 0.1, 1)
	else sp.totem.edge:SetVertexColor(0.9, 0.1, 0.1, 1) end
end

-- rastro de dano: cuando baja la vida queda un trozo claro (sp.trail) que
-- espera un poco y luego se encoge. trailing = placas que se estan animando
local trailing = {}
local TRAIL_HOLD, TRAIL_SPEED = 0.35, 7

local function StopTrail(sp)
	trailing[sp] = nil
	sp.trailPct, sp.trailTarget = nil, nil
	sp.trail.f:Hide()
end

local function UpdateTrail(sp, pct)
	if not cfg.healthTrail or not pct or pct ~= pct then StopTrail(sp) return end
	if pct > 1 then pct = 1 elseif pct < 0 then pct = 0 end
	local tp = sp.trailPct
	if not tp or pct >= tp then
		-- si sube o no cambia, nada
		StopTrail(sp)
		sp.trailPct = pct
		return
	end
	-- golpe nuevo: espera un poco antes de encoger
	if not sp.trailTarget or pct < sp.trailTarget then sp.trailHold = GetTime() + TRAIL_HOLD end
	sp.trailTarget = pct
	SetFill(sp.trail, sp.fw, tp)
	trailing[sp] = true
end

local function StepTrails(dt)
	if not next(trailing) then return end
	local now = GetTime()
	local k = math.exp(-dt * TRAIL_SPEED)
	for sp in pairs(trailing) do
		if sp.mode ~= "normal" or not sp.trailTarget then
			StopTrail(sp)
		elseif now >= (sp.trailHold or 0) then
			local tp = sp.trailTarget + (sp.trailPct - sp.trailTarget) * k
			if tp - sp.trailTarget < 0.003 then
				local target = sp.trailTarget
				StopTrail(sp)
				sp.trailPct = target
			else
				sp.trailPct = tp
				SetFill(sp.trail, sp.fw, tp)
			end
		end
	end
end

-- healers: en 3.3.5 no hay forma de pedir la spec, asi que la saco de
-- hechizos que solo tiene un healer (combat log). GUID -> true
local healers = {}
local HEALER_IDS = {
	20473, 53563, 31842,        -- Holy Shock, Beacon of Light, Divine Illumination (pala holy)
	47540, 33206, 47788, 34861, 724, -- Penance, Pain Suppression, Guardian Spirit, Circle of Healing, Lightwell
	61295, 974, 16190,          -- Riptide, Earth Shield, Mana Tide Totem (chaman resto)
	18562, 48438, 33891,        -- Swiftmend, Wild Growth, Tree of Life (druida resto)
}
local healerSpells
local HEALER_EVENTS = { SPELL_CAST_SUCCESS = true, SPELL_HEAL = true, SPELL_AURA_APPLIED = true }

local function IsHealerSpell(spellName)
	if not healerSpells then
		healerSpells = {}
		for _, id in ipairs(HEALER_IDS) do
			local n = GetSpellInfo(id)
			if n then healerSpells[n] = true end
		end
	end
	return spellName and healerSpells[spellName]
end

-- si esta Gladius aprovecho su deteccion de spec: me engancho a
-- Gladius:DetectSpec, que recibe "arenaN" y el nombre de la spec
-- ya traducido
local function HookGladius()
	if SP.gladiusHooked or not (Gladius and Gladius.DetectSpec and LibStub) then return end
	local L = LibStub("AceLocale-3.0"):GetLocale("Gladius", true)
	if not L then return end
	local heal = {}
	for _, k in ipairs({ "Holy", "Discipline", "Restoration" }) do
		if L[k] then heal[L[k]] = true end
	end
	SP.gladiusHooked = true
	hooksecurefunc(Gladius, "DetectSpec", function(_, unit, spec)
		if not (spec and heal[spec] and unit) then return end
		local guid = UnitGUID(unit)
		if guid and not healers[guid] then
			healers[guid] = true
			local p = guidPlate[guid] or plateByName[UnitName(unit) or ""]
			if p then dirty[p] = true end
		end
	end)
end
SP.HookGladius = HookGladius

-- cruz verde a la izquierda del nombre (o del numero de arena);
-- si no hay nombre visible, a la izquierda de la barra
local function UpdateHealerIcon(sp, unit, isPlayer, mode, friendly)
	local h = sp.heal
	-- healerEnemy* o healerParty* segun el bando
	local k = friendly and "healerParty" or "healerEnemy"
	local on = cfg[k] and isPlayer and unit and (mode == "normal" or mode == "barless")
		and healers[UnitGUID(unit) or ""]
	if not on then
		if sp.healPos then h:Hide(); sp.healPos = nil end
		return
	end
	local px = sp.px or 1
	local tw = sp.name:IsShown() and sp.name:GetStringWidth() or 0
	local pos = k .. (tw > 0 and ("n" .. math.floor(tw + 0.5)) or "b")
	if sp.healPos ~= pos then
		sp.healPos = pos
		h:ClearAllPoints()
		local s = SnapSize(cfg[k .. "Size"] or 18, px)
		h:SetWidth(s); h:SetHeight(s)
		local dx, dy = Snap(cfg[k .. "X"] or 0, px), Snap(cfg[k .. "Y"] or 0, px)
		if tw > 0 then
			h:SetPoint("RIGHT", sp.name, "CENTER", -Snap(tw / 2 + 3, px) + dx, dy)
		else
			h:SetPoint("RIGHT", sp, "LEFT", -Snap(3, px) - (sp.clsSpace or 0) + dx, dy)
		end
	end
	h:Show()
end

function UpdatePlate(plate)
	perf.update = perf.update + 1
	local sp = plate.sp
	if not sp or not active[plate] then return end
	local name = NativeName(plate)
	local isTarget = IsTargetPlate(plate, name) and true or false
	local hover = IsHoverPlate(plate)
	local clone = IsMageClone(plate, name)
	local unit
	if clone then
		unit = isTarget and "target" or nil -- nunca el token del mago
	else
		unit = ResolveUnit(name, isTarget, hover)
	end
	sp.noCast = clone or nil
	SetPlateUnit(plate, name, unit, clone)
	if plate.spWAName then plate.spWAName:SetText(name) end
	local isPlayer, friendly, nClass, nKind
	if unit then
		isPlayer = UnitIsPlayer(unit) and true or false
		friendly = UnitIsFriend("player", unit) and true or false
	else
		isPlayer, friendly, nClass, nKind = NativeInfo(plate)
	end
	sp.isTarget = isTarget

	-- Totem (por nombre): 1 = icono, 0 = oculto, 2 = placa, 3 = icono + placa
	local tid = cfg.totemIcons and not isPlayer and TotemID(name)
	local tmode = tid and ((cfg.totems[tid] and cfg.totems[tid].mode) or 1)
	if tmode == 3 and friendly and cfg.totemHideFriendly then tmode = 2 end
	local beside = (tmode == 3) or nil
	local besideChanged = sp.totemBeside ~= beside
	sp.totemBeside = beside

	-- Escala del target / aliados / placa de totem
	local mul = (isTarget and cfg.targetScale) or (friendly and cfg.friendlyScale) or 1
	if tmode == 2 or tmode == 3 then mul = mul * (cfg.totemPlateScale or 1) end
	if sp.scaleMul ~= mul or besideChanged then
		sp.scaleMul = mul
		Restyle(plate)
	end
	-- la opacidad sin target va en la placa entera, ver OnUpdateBody
	sp:SetAlpha(1)

	-- Modo: totem como icono, aliado solo con nombre o placa normal
	local mode = "normal"
	if tmode == 0 or (tmode == 1 and friendly and cfg.totemHideFriendly) then
		mode = "hidden"
	elseif tmode == 1 then
		mode = "totem"
	elseif friendly and BarlessFor(isPlayer) and not (isTarget and cfg.barlessExcludeTarget) then
		mode = "barless"
	end
	if sp.mode ~= mode then
		sp.mode = mode
		if mode == "normal" then Restyle(plate) else SP.ApplyMode(sp, mode) end
	end
	UpdateHealerIcon(sp, unit, isPlayer, mode, friendly)
	if mode == "hidden" then return end
	if mode == "totem" then
		UpdateTotemIcon(sp, tid, isTarget, friendly)
		sp.raid:Hide()
		return
	end
	if beside then UpdateTotemIcon(sp, tid, isTarget, friendly) end

	-- Numero de arena / grupo
	local id, ir, ig, ib
	if unit then id, ir, ig, ib = ArenaID(unit) end
	local idAsName = id and cfg.arenaIDPos == "name"
	if idAsName then name = id end

	if mode == "barless" then
		if sp.nameStr ~= name then SetName(sp, name) end
		local class = unit and select(2, UnitClass(unit)) or nClass
		local c = isPlayer and cfg.classColors[class or ""]
		c = c or cfg.friendlyColor
		sp.name:SetTextColor(c[1], c[2], c[3])
	else
		if sp.idStr ~= id then
			sp.idStr = id
			if id and not idAsName then
				sp.idText:SetText(id)
				sp.idText:SetTextColor(ir, ig, ib)
				sp.idText:Show()
			else
				sp.idText:Hide()
			end
			-- en vez del nombre: el numero con su color (rojo/verde)
			if idAsName then
				sp.name:SetTextColor(ir, ig, ib)
			else
				sp.name:SetTextColor(unpack(cfg.textColor))
			end
		end

		-- Vida
		local hpv, hpm
		if unit then
			hpv, hpm = UnitHealth(unit), math.max(UnitHealthMax(unit), 1)
		else
			hpv, hpm = NativeHealth(plate)
		end
		SetFill(sp.fillp, sp.fw, hpv / hpm)
		UpdateTrail(sp, hpv / hpm)
		if cfg.showHealthText then sp.hp:SetText(HealthString(hpv, hpm)) end

		-- Color
		local r, g, b
		if unit then r, g, b = UnitColor(unit) else r, g, b = NativeColor(nClass, nKind) end
		if sp.cr ~= r or sp.cg ~= g or sp.cb ~= b then
			sp.cr, sp.cg, sp.cb = r, g, b
			ColorPill(sp.fillp, r, g, b, 1)
			-- el rastro es el mismo color pero mas claro
			ColorPill(sp.trail, r + (1 - r) * 0.6, g + (1 - g) * 0.6, b + (1 - b) * 0.6, 0.9)
		end

		-- Icono de clase (solo jugadores)
		local cc = cfg.classIcon and isPlayer and (unit and select(2, UnitClass(unit)) or nClass)
		local tc = cc and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[cc]
		if tc then
			if sp.clsClass ~= cc then
				sp.clsClass = cc
				-- recorto un poco para quitar el borde del atlas
				sp.cls.icon:SetTexCoord(tc[1] + 0.015, tc[2] - 0.015, tc[3] + 0.015, tc[4] - 0.015)
			end
			sp.cls:Show()
		else
			sp.cls:Hide()
		end

		-- Nombre y nivel
		if sp.nameStr ~= name then SetName(sp, name) end
		local lvl
		if unit then lvl = UnitLevel(unit) else lvl = NativeLevel(plate) end
		local lt = (lvl and lvl > 0) and tostring(lvl) or "??"
		if sp.lvlStr ~= lt then
			sp.lvlStr = lt
			-- jefes y elites ??: calavera en vez de "??"
			local skull = lt == "??"
			sp.level:SetText(skull and "" or lt)
			Toggle(sp.boss, skull and cfg.showLevel)
			-- Nivel coloreado por dificultad, como el original
			if lvl and lvl > 0 and DiffColor then
				local c = DiffColor(lvl)
				sp.level:SetTextColor(c.r, c.g, c.b)
			else
				sp.level:SetTextColor(1, 0.1, 0.1)
			end
		end

		-- debuffs: solo se reescanean con UNIT_AURA o en el repaso
		if sp.auraDirty then
			sp.auraDirty = nil
			if unit and SP.UpdateDebuff then
				SP.UpdateDebuff(sp, unit, friendly)
			elseif sp.debuff then
				sp.debuff:Hide() -- sin token no se pueden leer sus auras
			end
		end
	end

	-- Marca de raid
	local idx
	if unit then idx = GetRaidTargetIndex(unit) else idx = NativeRaidIndex(plate) end
	if idx then
		local col, row = (idx - 1) % 4, math.floor((idx - 1) / 4)
		sp.raid:SetTexCoord(col * 0.25, col * 0.25 + 0.25, row * 0.25, row * 0.25 + 0.25)
		sp.raid:Show()
	else
		sp.raid:Hide()
	end

	if mode == "barless" then return end

	UpdateCast(plate)
end

-- cast: se llama desde UpdatePlate, en un sondeo ligero (20/s) y, mientras
-- castea, cada frame para que la barra vaya fluida
function UpdateCast(plate)
	perf.cast = perf.cast + 1
	local sp, unit = plate.sp, plate.spUnit
	if not sp or sp.mode ~= "normal" then return end
	local cb = sp.cast
	if not cfg.showCast then cb:Hide(); sp.casting = false return end
	-- Clon de mago: sin castbar
	if sp.noCast then
		if cb:IsShown() then cb:Hide() end
		sp.casting, sp.intUntil = false, nil
		return
	end

	-- cortado: se queda en rojo hasta que pasa el tiempo (y se desvanece
	-- al final) o hasta que empieza otro cast
	if sp.intUntil then
		local rem = sp.intUntil - GetTime()
		if rem > 0 and not (unit and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) then
			cb:SetAlpha(rem < 0.3 and rem / 0.3 or 1)
			sp.casting = true -- sigue actualizandose cada frame para el desvanecido
			return
		end
		sp.intUntil = nil
		sp.castNI = nil -- recolorear el siguiente cast
		cb.lastSpell = nil -- y volver a poner su nombre
		cb:SetAlpha(1)
		Toggle(cb.text, cfg.showCastText)
	end

	-- sin token no hay manera de leer el cast
	if not unit then
		if cb:IsShown() then sp.castHidAt = GetTime() end
		cb:Hide()
		sp.casting = false
		return
	end

	local spell, _, _, icon, st, et, _, a8, a9 = UnitCastingInfo(unit)
	local channel = false
	if not spell then
		spell, _, _, icon, st, et, _, a8, a9 = UnitChannelInfo(unit)
		channel = spell ~= nil
	end
	local pct, left
	if spell and st and et and et > st then
		local now = GetTime() * 1000
		pct = (channel and (et - now) or (now - st)) / (et - st)
		left = (et - now) / 1000
	else
		-- plan B: el progreso de la barra nativa del parche
		local nc = plate.spNativeCast
		if nc and nc:IsShown() then
			local mn, mx = nc:GetMinMaxValues()
			-- solo cuenta si la barra se mueve; una barra nativa parada
			-- no deberia sacar un marco vacio
			local v = nc:GetValue()
			local moving = plate.spNcLast ~= nil and v ~= plate.spNcLast
			plate.spNcLast = v
			if moving and mx and mn and mx > mn then
				pct = (v - mn) / (mx - mn)
				spell = spell or ""
				icon = icon or NativeCastIcon(nc)
			end
		end
	end
	if pct then
		SetFill(cb.fillp, cb.fw, pct)

		local ni = (a8 == true) or (a9 == true)
		if sp.castNI ~= ni then
			sp.castNI = ni
			local c = ni and cfg.castNoInterruptColor or cfg.castColor
			ColorPill(cb.fillp, c[1], c[2], c[3], 1)
			-- Escudo original cuando no se puede interrumpir
			Toggle(cb.border, not ni)
			Toggle(cb.shield, ni)
			cb.icon:SetDesaturated(ni)
		end
		if cfg.castSpark and pct > 0 and pct < 1 then
			cb.spark:ClearAllPoints()
			cb.spark:SetPoint("CENTER", cb, "LEFT", cb.fw * pct, 0)
			cb.spark:Show()
		else
			cb.spark:Hide()
		end
		-- esto corre cada frame mientras castea: solo se toca lo que cambia
		if cb.lastSpell ~= spell then cb.lastSpell = spell; cb.text:SetText(spell) end
		if cfg.showCastTime and left then
			local t = math.floor(math.max(0, left) * 10 + 0.5)
			if cb.lastT ~= t then cb.lastT = t; cb.time:SetText(string.format("%.1f", t / 10)) end
			cb.time:Show()
		else
			cb.time:Hide()
		end
		if cfg.showCastIcon and icon then
			if cb.lastIcon ~= icon then cb.lastIcon = icon; cb.icon:SetTexture(icon) end
			cb.icon:Show(); cb.iconEdge:Show()
			if cb.ico.silver and cb.ico.silverOn then cb.ico.silver:Show() end
		else
			cb.icon:Hide(); cb.iconEdge:Hide()
			if cb.ico.silver then cb.ico.silver:Hide() end
		end
		cb:Show()
		sp.casting = true
	else
		if cb:IsShown() then sp.castHidAt = GetTime() end
		cb:Hide()
		sp.casting = false
	end
end

-- Pone el castbar de una placa en estado "Interrupted" (rojo, parado)
function SP.ShowInterrupt(plate, who)
	local sp = plate and plate.sp
	if not sp or sp.mode ~= "normal" or not cfg.showCast or sp.noCast then return end
	local cb = sp.cast
	if sp.intUntil then
		-- ya estaba cortado, solo falta poner quien fue
		if who and cfg.showInterrupter then cb.text:SetText(INTERRUPTED .. ": " .. who) end
		return
	end
	-- Solo si se estaba viendo un cast (o se acaba de ocultar)
	if not cb:IsShown() and not (sp.castHidAt and GetTime() - sp.castHidAt < 0.3) then return end
	sp.intUntil = GetTime() + cfg.castInterruptHold
	sp.castNI = "int"
	local c = cfg.castInterruptColor
	ColorPill(cb.fillp, c[1], c[2], c[3], 1)
	cb.spark:Hide()
	cb.time:Hide()
	cb.icon:SetDesaturated(false)
	cb.border:Show()
	cb.shield:Hide()
	cb.lastSpell = nil
	cb.text:SetText((who and cfg.showInterrupter) and (INTERRUPTED .. ": " .. who) or INTERRUPTED)
	cb.text:Show()
	cb:SetAlpha(1)
	cb:Show()
	sp.casting = true
end

------------------------------ POSICION ----------------------------
-- ajuste para que la placa caiga justo en pixeles enteros
local function SnapOffset(sp, plate, oy, ox)
	ox = ox or 0
	if not cfg.pixelPerfect or not sp.px then return ox, oy end
	local cx, cy = plate:GetCenter()
	if not cx then return 0, oy end
	local k = plate:GetEffectiveScale() / sp:GetEffectiveScale()
	local px = sp.px
	local x = cx * k + ox - sp:GetWidth() / 2
	local y = cy * k + oy - sp:GetHeight() / 2
	return math.floor(x / px + 0.5) * px - x + ox, math.floor(y / px + 0.5) * px - y + oy
end

-- Baja la placa del target si se sale por arriba de la pantalla
local function ClampTop(sp, plate, oy)
	if not cfg.clampTarget or not sp.isTarget then return oy end
	local _, cy = plate:GetCenter()
	if not cy then return oy end
	local ses = sp:GetEffectiveScale()
	local k = plate:GetEffectiveScale() / ses
	local limit = WorldFrame:GetTop() * WorldFrame:GetEffectiveScale() / ses - cfg.clampMargin
	local top = cy * k + oy + sp:GetHeight() / 2 + cfg.fontSize + 4
	if top > limit then oy = oy - (top - limit) end
	return oy
end

-- la placa nativa ya esta centrada sobre la cabeza, asi que basta con
-- no moverla en horizontal
local function OffsetX()
	if cfg.centerPlate then return 0 end
	return cfg.offsetX
end

-- recoloca la placa solo si el desplazamiento cambio (antes era cada frame)
local function Place(sp, plate, oy)
	local x, y = SnapOffset(sp, plate, ClampTop(sp, plate, oy), OffsetX())
	if sp.posX ~= x or sp.posY ~= y then
		sp.posX, sp.posY = x, y
		sp:SetPoint("CENTER", plate, "CENTER", x, y)
	end
end

local list = {}
local function byY(a, b) return a.y < b.y end

local function Restack(dt)
	local n = 0
	local s = cfg.scale
	for plate, sp in pairs(active) do
		local cx, cy = plate:GetCenter()
		if cx then
			n = n + 1
			local t = list[n]
			if not t then t = {}; list[n] = t end
			local es = plate:GetEffectiveScale()
			t.plate, t.sp, t.es = plate, sp, es * s
			t.x, t.y = cx * es, cy * es
			t.w = (cfg.width + 16) * es * s
			t.h = (cfg.height + cfg.fontSize + 6) * es * s
			t.off = 0
		end
	end
	for i = #list, n + 1, -1 do list[i] = nil end
	table.sort(list, byY)

	local k = math.min(1, dt * cfg.stackSpeed)
	for i = 1, n do
		local a = list[i]
		for j = 1, i - 1 do
			local b = list[j]
			if math.abs(a.x - b.x) < (a.w + b.w) / 2 then
				local need = (b.y + b.off + b.h + cfg.stackGap * a.es) - a.y
				if need > a.off then a.off = need end
			end
		end
		local goal = math.min(a.off / a.es, cfg.stackMax)
		local cur = a.sp.curOff
		cur = cur + (goal - cur) * k
		a.sp.curOff = cur
		Place(a.sp, a.plate, cur + cfg.offsetY)
	end
end

local function Position(dt)
	if cfg.stacking then
		Restack(dt)
	else
		for plate, sp in pairs(active) do
			sp.curOff = 0
			Place(sp, plate, cfg.offsetY)
		end
	end
end

------------------------------ EVENTOS -----------------------------
-- las placas se actualizan cuando llega un evento que les toca (dirty)
-- en vez de recalcular todo 20 veces por segundo. Los eventos pueden venir
-- con nameplateN u otros tokens (target, focus, party...); con el GUID
-- encuentro la placa igual
-- ultimo que corto a cada GUID (SPELL_INTERRUPT puede llegar antes o
-- despues que UNIT_SPELLCAST_INTERRUPTED)
local lastInt, lastIntTime = {}, {}
local function RecentInterrupter(guid)
	if guid and lastInt[guid] and GetTime() - lastIntTime[guid] < 0.5 then return lastInt[guid] end
end

-- Castbars de Blizzard de target y focus
local function TFBar(guid)
	if not cfg.tfCast or not guid then return end
	if TargetFrameSpellBar and guid == UnitGUID("target") then return TargetFrameSpellBar end
	if FocusFrameSpellBar and guid == UnitGUID("focus") then return FocusFrameSpellBar end
end

function SP.OnCombatLog(_, sub, srcGUID, srcName, _, dstGUID, _, _, spellId, spellName)
	if HEALER_EVENTS[sub] then
		if srcGUID and not healers[srcGUID] and IsHealerSpell(spellName) then
			healers[srcGUID] = true
			local p = guidPlate[srcGUID] or (srcName and plateByName[srcName])
			if p then dirty[p] = true end
		end
		return
	end
	if sub ~= "SPELL_INTERRUPT" or not dstGUID then return end
	lastInt[dstGUID], lastIntTime[dstGUID] = srcName, GetTime()
	local plate = guidPlate[dstGUID]
	if plate then SP.ShowInterrupt(plate, srcName) end
	-- Bloqueo de escuela como icono de silencio en la placa
	if SP.AddLockout and SP.AddLockout(dstGUID, spellId) and plate then
		plate.sp.auraDirty = true
		dirty[plate] = true
	end
	-- Completar el texto del castbar de target/focus si ya marco "Interrupted"
	local bar = TFBar(dstGUID)
	if bar and bar.spInterrupted and cfg.showInterrupter and srcName then
		local t = _G[bar:GetName() .. "Text"]
		if t then t:SetText(INTERRUPTED .. ": " .. srcName) end
	end
end

local function Forget(plate)
	if plate.spGUID and guidPlate[plate.spGUID] == plate then guidPlate[plate.spGUID] = nil end
	if plate.spName and plateByName[plate.spName] == plate then plateByName[plate.spName] = nil end
	plate.spGUID, plate.spName, plate.spUnit = nil, nil, nil
	active[plate] = nil
	dirty[plate] = nil
end

-- Placa de un token de evento (arena1, target, party2...), buscada por nombre
local function PlateForUnit(unit)
	local n = unit and UnitName(unit)
	local plate = n and plateByName[n]
	return plate and active[plate] and plate
end

local function MarkAll()
	for plate, sp in pairs(active) do
		dirty[plate] = true
		sp.auraDirty = true
	end
end

-- Una placa aparece (o se reutiliza): se viste y se marca para actualizar
local function OnPlateShow(plate)
	if not plate.sp then Build(plate) else HideNatives(plate) end
	local sp = plate.sp
	Forget(plate)
	sp.curOff = 0
	sp.casting = false
	sp.auraDirty = true
	sp.intUntil = nil
	sp.nameStr, sp.lvlStr, sp.cr, sp.castNI = nil, nil, nil, nil
	sp.noCast = nil
	StopTrail(sp)
	sp.heal:Hide()
	sp.healPos = nil
	sp.idStr = false -- la placa se reutiliza, hay que borrar el numero anterior
	sp.idText:Hide()
	if sp.mode ~= "normal" then
		sp.mode = "normal"
		Restyle(plate)
	end
	sp:SetPoint("CENTER", plate, "CENTER", 0, 0)
	sp.posX, sp.posY = 0, 0
	active[plate] = sp
	sp:Show()
	UpdatePlate(plate)
end

local function OnPlateHide(plate)
	Forget(plate)
end

-- sin Awesome no hay eventos de placas: las busco entre los hijos de
-- WorldFrame (solo si cambia cuantos hay). Una placa se reconoce por
-- su primera region, la textura de amenaza
local PLATE_OVERLAY = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
local knownPlates, lastChildren = {}, 0
local function IsPlate(f)
	if f:GetName() or f:GetObjectType() ~= "Frame" then return false end
	local r = f:GetRegions()
	return r and r:GetObjectType() == "Texture" and r:GetTexture() == PLATE_OVERLAY
end

local function FindPlates()
	local n = WorldFrame:GetNumChildren()
	if n == lastChildren then return end
	local kids = { WorldFrame:GetChildren() }
	for i = lastChildren + 1, n do
		local f = kids[i]
		if f and not knownPlates[f] and IsPlate(f) then
			knownPlates[f] = true
			f:HookScript("OnShow", function(self) SafeCall(OnPlateShow, self) end)
			f:HookScript("OnHide", OnPlateHide)
			if f:IsShown() then SafeCall(OnPlateShow, f) end
		end
	end
	lastChildren = n
end

-- repaso: placas nuevas, las que se escondieron sin avisar y piezas nativas nuevas
local function Scan()
	FindPlates()
	for plate in pairs(active) do
		if not plate:IsShown() then
			Forget(plate)
		else
			HideNatives(plate, true)
		end
	end
	for plate in pairs(knownPlates) do
		if plate:IsShown() and not active[plate] then SafeCall(OnPlateShow, plate) end
	end
end

function SP.Refresh()
	if not cfg then return end
	for plate in pairs(built) do SafeCall(Restyle, plate) end
	for plate in pairs(active) do SafeCall(UpdatePlate, plate) end
	-- segunda pasada al frame siguiente, cuando el juego ya recalculo
	-- tamanos y escalas (con una sola a veces no se nota el cambio)
	driver.pendingRefresh = true
end

-------------------------- TARGET / FOCUS ---------------------------
-- me engancho a los castbars de Blizzard de target y focus (despues de
-- que Blizzard los actualice) para dejarlos en rojo con "Interrupted: fulano"
-- y pintar distinto los casts que no se pueden cortar
local tfValue = {}
function SP.SetupTargetFocus()
	if not CastingBarFrame_OnEvent then return end
	local bars = {}
	if TargetFrameSpellBar then bars[TargetFrameSpellBar] = "target" end
	if FocusFrameSpellBar then bars[FocusFrameSpellBar] = "focus" end

	-- guardo por donde iba, porque Blizzard la llena entera al cortarla
	local watcher = CreateFrame("Frame")
	watcher:SetScript("OnUpdate", function()
		for bar in pairs(bars) do
			if bar.casting or bar.channeling then tfValue[bar] = bar:GetValue() end
		end
	end)

	hooksecurefunc("CastingBarFrame_OnEvent", function(self, event, unit)
		local u = bars[self]
		if not u or not cfg.tfCast then return end
		if unit and unit ~= u and event ~= "PLAYER_TARGET_CHANGED" and event ~= "PLAYER_FOCUS_CHANGED" then return end
		local text = _G[self:GetName() .. "Text"]
		if event == "UNIT_SPELLCAST_INTERRUPTED" then
			if tfValue[self] then self:SetValue(tfValue[self]) end
			local c = cfg.castInterruptColor
			self:SetStatusBarColor(c[1], c[2], c[3])
			self.holdTime = GetTime() + cfg.castInterruptHold
			self.spInterrupted = true
			local who = cfg.showInterrupter and RecentInterrupter(UnitGUID(u))
			if text then text:SetText(who and (INTERRUPTED .. ": " .. who) or INTERRUPTED) end
		elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START"
			or event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
			or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
			self.spInterrupted = nil
			local name, _, _, _, _, _, _, _, ni = UnitCastingInfo(u)
			if not name then
				local _
				name, _, _, _, _, _, _, ni = UnitChannelInfo(u)
			end
			if name and ni then
				local c = cfg.castNoInterruptColor
				self:SetStatusBarColor(c[1], c[2], c[3])
			end
		end
	end)
end

-- Eventos que marcan una placa (por unidad) o todas para actualizar
SP.UNIT_EVENTS = {
	UNIT_HEALTH = true, UNIT_MAXHEALTH = true, UNIT_LEVEL = true, UNIT_NAME_UPDATE = true,
	UNIT_FACTION = true, UNIT_FLAGS = true, UNIT_THREAT_LIST_UPDATE = true,
	UNIT_SPELLCAST_START = true, UNIT_SPELLCAST_STOP = true, UNIT_SPELLCAST_FAILED = true,
	UNIT_SPELLCAST_INTERRUPTED = true, UNIT_SPELLCAST_DELAYED = true,
	UNIT_SPELLCAST_CHANNEL_START = true, UNIT_SPELLCAST_CHANNEL_UPDATE = true,
	UNIT_SPELLCAST_CHANNEL_STOP = true, UNIT_SPELLCAST_INTERRUPTIBLE = true,
	UNIT_SPELLCAST_NOT_INTERRUPTIBLE = true, UNIT_AURA = true,
}
SP.GLOBAL_EVENTS = {
	PLAYER_TARGET_CHANGED = true, UPDATE_MOUSEOVER_UNIT = true, RAID_TARGET_UPDATE = true,
	PARTY_MEMBERS_CHANGED = true, ARENA_OPPONENT_UPDATE = true, PLAYER_FOCUS_CHANGED = true,
}

-- apunta lo que cuesta cada frame y avisa de picos (max. cada 10 s)
local lastWarn = 0
function SP.RecordFrame(cost, u0, r0, b0)
	perf.frames = perf.frames + 1
	perf.total = perf.total + cost
	if cost > perf.max then
		perf.max = cost
		perf.maxInfo = string.format(T("%d actualizaciones, %d restyle, %d placas creadas"),
			perf.update - u0, perf.restyle - r0, perf.built - b0)
	end
	if cost > 100 and GetTime() - lastWarn > 10 then
		lastWarn = GetTime()
		DEFAULT_CHAT_FRAME:AddMessage(string.format(T("|cffffaa00HemsworkPlates:|r pico de %.0f ms (%s). Usa /hms perf"), cost,
			string.format(T("%d actualizaciones, %d restyle, %d placas creadas"), perf.update - u0, perf.restyle - r0, perf.built - b0)))
	end
end

local OnEvent
driver:RegisterEvent("ADDON_LOADED")
driver:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		SP.OnCombatLog(arg1, ...)
		return
	end
	local t0 = clock()
	local b0 = perf.built
	OnEvent(self, event, arg1)
	local cost = clock() - t0
	if cost > perf.evMax then
		perf.evMax = cost
		perf.evMaxName = event .. (perf.built > b0 and (" (" .. (perf.built - b0) .. T(" placas creadas)")) or "")
	end
	if cost > 100 and GetTime() - lastWarn > 10 then
		lastWarn = GetTime()
		DEFAULT_CHAT_FRAME:AddMessage(string.format(T("|cffffaa00HemsworkPlates:|r pico de %.0f ms en %s. Usa /hms perf"), cost, event))
	end
end)

function OnEvent(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= addonName then return end
		HemsworkPlatesDB = HemsworkPlatesDB or {}
		local hadIconWH = HemsworkPlatesDB.debuffWidth ~= nil
		Merge(HemsworkPlatesDB, defaults)
		-- limpiar las opciones del sigilo de la 1.2.0
		HemsworkPlatesDB.stealthMark, HemsworkPlatesDB.stealthAlert = nil, nil
		HemsworkPlatesDB.stealthAlertSize, HemsworkPlatesDB.stealthIcons = nil, nil
		-- y las del resaltado, que quite en la 1.2.2
		for _, k in ipairs({ "targetGlow", "targetGlowColor", "targetGlowAlpha", "hoverGlow",
			"hoverGlowColor", "hoverGlowAlpha", "glowSize",
			"petStyle", "petScale", "petPulse", "healerIcon", "healerIconSize",
			"castExtraWidth", "borderSize", "levelOffset", "castIconSize", "borderColor",
			"targetBorderColor", "hoverBorderColor" }) do
			HemsworkPlatesDB[k] = nil
		end
		cfg = HemsworkPlatesDB
		if not hadIconWH then
			-- antes habia un solo tamano, ancho y alto empiezan con ese
			cfg.debuffWidth, cfg.debuffHeight = cfg.debuffSize, cfg.debuffSize
			cfg.gcdWidth, cfg.gcdHeight = cfg.gcdSize, cfg.gcdSize
		end
		if (cfg.dbVersion or 0) < 4 then
			cfg.castHeight = defaults.castHeight
		end
		if (cfg.dbVersion or 0) < 5 then
			-- Estilo clasico WotLK por defecto
			cfg.shape = defaults.shape
			cfg.font = defaults.font
			cfg.texture = defaults.texture
			cfg.castColor = { unpack(defaults.castColor) }
		end
		if (cfg.dbVersion or 0) < 6 then
			-- Solo quedan texturas que se distinguen; el cast ya no lleva ancho extra
			if cfg.texture ~= "Interface\\Buttons\\WHITE8X8" then cfg.texture = defaults.texture end
			cfg.dbVersion = 6
		end
		if (cfg.dbVersion or 0) < 7 then
			-- Como la referencia: cast mas alto, nombre blanco y algo mayor
			cfg.castHeight = defaults.castHeight
			cfg.fontSize = defaults.fontSize
			cfg.textColor = { unpack(defaults.textColor) }
			cfg.dbVersion = 7
		end
		if (cfg.dbVersion or 0) < 8 then
			-- el cliente ya separa las placas (spreadnameplates) y con el apilado
			-- propio encima se movian solas. Proporciones de la referencia
			cfg.stacking = false
			cfg.width, cfg.height, cfg.castHeight = defaults.width, defaults.height, defaults.castHeight
			cfg.dbVersion = 8
		end
		if (cfg.dbVersion or 0) < 9 then
			-- En la referencia el cast es ~1.3 veces mas alto que la vida
			cfg.castHeight = defaults.castHeight
			cfg.dbVersion = 9
		end
		if cfg.arenaHideNames ~= nil then
			if cfg.arenaHideNames then cfg.arenaIDPos = "name" end
			cfg.arenaHideNames = nil
		end
		-- El azul de aliados pasa al original de Blizzard si no se habia cambiado
		local fc = cfg.friendlyPlayerColor
		if fc and fc[1] == 0.25 and fc[2] == 0.55 and fc[3] == 1 then fc[1], fc[2], fc[3] = 0, 0, 1 end
		-- maximo 99%, al 100% seria como no tocarla
		if (tonumber(cfg.nonTargetAlpha) or 0.7) > 0.99 then cfg.nonTargetAlpha = 0.99 end
		SP.cfg = cfg
		HookGladius()
		if SP.UpdateLanguage then SP.UpdateLanguage() end
		self:UnregisterEvent("ADDON_LOADED")
		-- Marca de version para comprobar que el juego cargo el archivo actual
		DEFAULT_CHAT_FRAME:AddMessage(string.format(T("|cff66ccffHemsworkPlates|r cargado: version %s (Warmane, sin Awesome WotLK)"), SP.VERSION or "?"))

		-- color de clase en las barras nativas de los enemigos: sin token es
		-- lo unico que me dice su clase
		if GetCVar("ShowClassColorInNameplate") ~= "1" then SetCVar("ShowClassColorInNameplate", "1") end
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("DISPLAY_SIZE_CHANGED")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		SP.SetupTargetFocus()
		for e in pairs(SP.UNIT_EVENTS) do self:RegisterEvent(e) end
		for e in pairs(SP.GLOBAL_EVENTS) do self:RegisterEvent(e) end
		self:SetScript("OnUpdate", function(_, dt)
			local t0 = clock()
			local u0, r0, b0 = perf.update, perf.restyle, perf.built
			SP.OnUpdateBody(self, dt)
			SP.RecordFrame(clock() - t0, u0, r0, b0)
		end)
		SP.OnUpdateBody = function(_, dt)
			if self.pendingRefresh then
				self.pendingRefresh = nil
				for plate in pairs(built) do SafeCall(Restyle, plate) end
				for plate in pairs(active) do SafeCall(UpdatePlate, plate) end
			end
			SafeCall(Position, dt)
			SafeCall(StepTrails, dt)

			-- opacidad sin target, como en RBP: el juego solo deja a 1 la del target
			-- y al resto le piso el valor
			if cfg.modNonTargetAlpha and UnitExists("target") then
				local a = cfg.nonTargetAlpha
				for plate in pairs(active) do
					if plate:GetAlpha() < 0.999 then plate:SetAlpha(a) end
				end
			end
			if SP.UpdateGCDs then SafeCall(SP.UpdateGCDs, active) end

			-- el mouseover no avisa cuando sales, lo miro aqui
			local hp = self.hoverPlate
			if hp and not IsHoverPlate(hp) then
				dirty[hp] = true
				self.hoverPlate = nil
			end

			-- la opacidad del target cambia un frame despues del evento
			if self.markNext then
				self.markNext = self.markNext - 1
				if self.markNext <= 0 then self.markNext = nil end
				MarkAll()
			end

			-- Placas con eventos pendientes (una sola vez por frame)
			if next(dirty) then
				for plate in pairs(dirty) do
					dirty[plate] = nil
					if active[plate] then SafeCall(UpdatePlate, plate) end
				end
			end

			-- cast: cada frame si esta casteando, si no un sondeo ligero
			self.castAcc = (self.castAcc or 0) + dt
			local poll = self.castAcc >= 0.05
			if poll then self.castAcc = 0 end
			for plate, sp in pairs(active) do
				if poll or sp.casting then SafeCall(UpdateCast, plate) end
			end

			-- por si se pierde algun evento
			self.acc = (self.acc or 0) + dt
			if self.acc >= 0.4 then
				self.acc = 0
				MarkAll()
			end
			self.scanAcc = (self.scanAcc or 0) + dt
			if self.scanAcc >= 0.25 then
				self.scanAcc = 0
				SafeCall(Scan)
			end
		end
	elseif SP.UNIT_EVENTS[event] then
		local plate = PlateForUnit(arg1)
		if plate then
			dirty[plate] = true
			if event == "UNIT_AURA" then
				plate.sp.auraDirty = true
			elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
				SP.ShowInterrupt(plate, RecentInterrupter(plate.spGUID))
			end
		end
	elseif SP.GLOBAL_EVENTS[event] then
		MarkAll()
		self.markNext = 2
		if event == "UPDATE_MOUSEOVER_UNIT" then self.hoverPlate = PlateForUnit("mouseover") end
	elseif event == "PLAYER_ENTERING_WORLD" then
		wipe(healers)
		UpdateZone()
		SafeCall(Scan)
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		UpdateZone()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		SP.Refresh()
	end
end

local function PrintGeo(name, g)
	if not g then print("  " .. name .. T(": sin medir (usando respaldo)")) return end
	local keys = {}
	for k, v in pairs(g) do keys[#keys + 1] = k .. "=" .. string.format("%.1f", v) end
	table.sort(keys)
	print("  " .. name .. ": " .. table.concat(keys, " "))
end

SLASH_HEMSWORKPLATES1 = "/hms"
SLASH_HEMSWORKPLATES2 = "/plates"
SLASH_HEMSWORKPLATES3 = "/hemsworkplates"
local SlashHandler
SlashCmdList["HEMSWORKPLATES"] = function(msg)
	-- el cliente puede tener los errores de Lua ocultos, asi que van al chat
	local ok, err = pcall(SlashHandler, msg)
	if not ok then DEFAULT_CHAT_FRAME:AddMessage("|cffff5555HemsworkPlates error:|r " .. tostring(err)) end
end

function SlashHandler(msg)
	msg = strlower(msg or "")
	if msg == "debug" then
		local shown = false
		for plate in pairs(active) do
			print("|cff66ccffHemsworkPlates debug:|r " .. (plate.spDebug or "?"))
			shown = true
			break
		end
		if not shown then print(T("HemsworkPlates: no hay placas activas, apunta a un mob cercano.")) end
	elseif msg == "cast" then
		-- Diagnostico del cast (usar con un target que este casteando)
		local plate
		for p, psp in pairs(active) do if psp.isTarget then plate = p end end
		if not plate then print(T("HemsworkPlates: pon de target a alguien que este casteando.")) return end
		local sp = plate.sp
		local function Desc(f)
			if not f then return "nil" end
			if f == plate then return "PLACA" end
			if f == hider then return "OCULTADOR" end
			if sp and f == sp then return "NUESTRA" end
			return f:GetObjectType() .. ":" .. (f:GetName() or "?")
		end
		print("|cff66ccffHemsworkPlates cast:|r " .. (UnitName("target") or "?"))
		print("  API target: " .. tostring(UnitCastingInfo("target") or UnitChannelInfo("target"))
			.. "  API placa: " .. tostring(plate.spUnit and (UnitCastingInfo(plate.spUnit) or UnitChannelInfo(plate.spUnit))))
		print("  nativa salud: " .. Desc(plate.spNativeHealth) .. "  nativa cast: " .. Desc(plate.spNativeCast)
			.. (plate.spNativeCast and (" padre=" .. Desc(plate.spNativeCast:GetParent()) .. " shown=" .. tostring(plate.spNativeCast:IsShown())) or ""))
		for i, c in ipairs({ plate:GetChildren() }) do
			print("  hijo " .. i .. ": " .. Desc(c) .. " visible=" .. tostring(c:IsVisible()))
		end
		-- busca en todo el UI barras visibles cerca de la placa
		local px, py = plate:GetCenter()
		local f = EnumerateFrames()
		local n = 0
		while f and n < 10 do
			if f:GetObjectType() == "StatusBar" and f:IsVisible() and (not sp or (f:GetParent() ~= sp and f:GetParent() ~= sp.cast)) then
				local x, y = f:GetCenter()
				if x and px and math.abs(x - px) < 150 and math.abs(y - py) < 80 then
					n = n + 1
					local _, rel = f:GetPoint(1)
					print("  BARRA VISIBLE: " .. Desc(f) .. " padre=" .. Desc(f:GetParent())
						.. " abuelo=" .. Desc(f:GetParent() and f:GetParent():GetParent()) .. " ancla=" .. Desc(rel))
				end
			end
			f = EnumerateFrames(f)
		end
		if n == 0 then print(T("  no hay barras visibles cerca de la placa")) end
	elseif msg == "perf" then
		local secs = math.max(GetTime() - perf.start, 0.001)
		UpdateAddOnMemoryUsage()
		print(T("|cff66ccffHemsworkPlates rendimiento|r (") .. string.format("%.0f", secs) .. T(" s medidos)"))
		print(string.format(T("  Por frame: media %.2f ms, peor %.1f ms"), perf.total / math.max(perf.frames, 1), perf.max))
		if perf.maxInfo then print(T("  En el peor frame: ") .. perf.maxInfo) end
		print(string.format(T("  Peor evento: %.1f ms %s"), perf.evMax, perf.evMaxName or ""))
		print(string.format(T("  Por segundo: %.1f actualizaciones, %.1f casts, %.2f restyle"), perf.update / secs, perf.cast / secs, perf.restyle / secs))
		print(string.format(T("  Placas creadas: %d   Memoria del addon: %.0f KB"), perf.built, GetAddOnMemoryUsage(addonName)))
	elseif msg == "perf reset" then
		perf.start, perf.frames, perf.total, perf.max, perf.evMax = GetTime(), 0, 0, 0, 0
		perf.update, perf.restyle, perf.cast, perf.built = 0, 0, 0, 0
		perf.maxInfo, perf.evMaxName = nil, nil
		print(T("HemsworkPlates: medidor reiniciado."))
	elseif msg == "geo" then
		print(T("|cff66ccffHemsworkPlates geometria nativa:|r"))
		PrintGeo("vida", cfg.geo and cfg.geo.hp)
		PrintGeo("cast", cfg.geo and cfg.geo.cast)
	elseif msg == "geo reset" then
		cfg.geo = nil
		print(T("HemsworkPlates: geometria borrada, se volvera a medir tras /reload."))
	elseif msg == "perfil" or msg == "perfiles" or msg == "export" or msg == "import" then
		if SP.ShowProfiles then SP.ShowProfiles() end
	elseif msg == "gcd" or msg == "gcd test" then
		if SP.TestGCD then SP.TestGCD() end
	elseif msg == "reset" then
		SP.Reset()
		print(T("HemsworkPlates: configuracion restablecida."))
	elseif SP.ToggleConfig then
		SP.ToggleConfig()
	end
end
