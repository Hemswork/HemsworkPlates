--------------------------------------------------------------------
-- HemsworkPlates (Warmane)  -  Nameplates para 3.3.5a SIN Awesome WotLK
-- Las placas se encuentran en WorldFrame y se identifican por su nombre,
-- emparejandolas con arena1-5 / party1-4 / target / focus / mouseover.
-- Opciones: /hms  (tambien /plates)
--------------------------------------------------------------------
local addonName, SP = ...

SP.Refresh = function() end -- se reemplaza mas abajo
local function T(s) return SP.T and SP.T(s) or s end

local defaults = {
	language = "auto", -- "auto" (segun el cliente), "es" o "en"
	shape = "classic", -- "classic", "old" (marco dorado original), "square" o "round"
	width = 120, height = 11, castHeight = 14, castExtraWidth = 0, scale = 1,
	borderSize = 1.5, levelOffset = 8,
	pixelPerfect = true,

	font = "Fonts\\FRIZQT__.TTF", fontSize = 11, fontOutline = "",
	texture = "Interface\\TargetingFrame\\UI-StatusBar",

	showName = true, showLevel = true, showHealthText = false,
	showCast = true, showCastIcon = true, showCastTime = true, showCastText = true, castIconSize = 14,
	castFontSize = 8, -- letra del nombre del hechizo y del tiempo en el cast

	nonTargetAlpha = 0.7,
	offsetX = 0, offsetY = 0, -- mover la placa entera respecto a la posicion nativa
	nameX = 0, nameY = 0, -- mover el nombre (siempre centrado sobre la barra con 0, 0)
	stacking = false, stackGap = 2, stackSpeed = 12, stackMax = 80,

	classColorPlayers = true,
	-- Jugadores aliados en un color fijo (azul) para distinguirlos de los
	-- enemigos en arena; friendlyClassColor = true vuelve al color de clase
	friendlyClassColor = false, friendlyPlayerColor = { 0, 0, 1 }, -- azul original de Blizzard

	-- Funciones traidas de RefinedBlizzPlates
	targetGlow = true, targetGlowColor = { 1, 1, 0 }, targetGlowAlpha = 0.8,
	hoverGlow = true, hoverGlowColor = { 1, 1, 1 }, hoverGlowAlpha = 0.45,
	glowSize = 6,
	healthFormat = 1, healthHideMax = true,
	-- arenaIDPos: "left" = numero a la izquierda de la barra, "name" = en lugar del nombre
	arenaIDs = true, partyIDs = true, arenaIDPos = "left",
	totemIcons = true, totemSize = 24, totemHideFriendly = false,
	-- Por totem (clave = ID de hechizo): mode 1 = icono, 0 = oculto, 2 = placa normal;
	-- icon = ruta de textura o ID de hechizo propio ("" = el del juego)
	totems = {},
	targetScale = 1.15, friendlyScale = 0.85, clampTarget = true, clampMargin = 35,
	-- Aliados solo con nombre por zona: 0 = no, 1 = PNJs, 2 = jugadores, 3 = ambos
	barlessWorld = 3, barlessPvE = 3, barlessBG = 3, barlessArena = 0, barlessExcludeTarget = true,

	textColor         = { 1, 1, 1 },
	bgColor           = { 0.05, 0.05, 0.05, 0.85 },
	borderColor       = { 0, 0, 0, 1 },
	targetBorderColor = { 1, 1, 1, 0.9 },
	hoverBorderColor  = { 1, 1, 1, 0.5 },
	castColor         = { 1, 0.7, 0 },
	castNoInterruptColor = { 0.6, 0.6, 0.6 },
	-- Cast interrumpido: se queda parado en rojo con "Interrupted: quien"
	castInterruptColor = { 1, 0.1, 0.1 }, castInterruptHold = 1, showInterrupter = true,
	tfCast = true, -- lo mismo en los castbars de target y focus

	-- Debuffs importantes (antes WeakAura "[Nameplate] BigDebuffs 3.3.5")
	debuffs = true, debuffEnemyOnly = true, debuffArenaOnly = false, debuffTimer = true,
	debuffLockouts = true,
	-- GCD de los enemigos de arena (antes NameplateArenaGCDs)
	gcd = true, gcdSize = 27, gcdPos = "left", gcdX = 0, gcdY = 0,
	gcdTimer = true, gcdReverse = false, gcdHideSweep = false, gcdAlpha = 1, -- bloqueos de Pummel, Shield Bash, Kick... (no dejan aura)
	debuffSize = 30, debuffPos = "right", debuffX = 0, debuffY = 0,
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
	local geo = HemsworkPlatesDB.geo -- la geometria nativa medida se conserva
	for k in pairs(HemsworkPlatesDB) do HemsworkPlatesDB[k] = nil end
	Merge(HemsworkPlatesDB, defaults)
	HemsworkPlatesDB.geo = geo
	HemsworkPlatesDB.dbVersion = 9
	SP.Refresh()
end

local active, built = {}, {}
local dirty = {} -- placas pendientes de actualizar (se procesan una vez por frame)
local guidPlate = {} -- GUID -> placa (registro de combate)
local hider = CreateFrame("Frame")
hider:Hide()
local driver = CreateFrame("Frame")
local UpdatePlate, UpdateCast

local FALLBACK_FONT = "Fonts\\FRIZQT__.TTF"
local RAID_ICONS = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local FLAT = "Interface\\Buttons\\WHITE8X8"
local CAP = "Interface\\AddOns\\" .. addonName .. "\\Media\\cap.tga"

-- Texturas originales de las nameplates de WotLK
local HP_BORDER   = "Interface\\Tooltips\\Nameplate-Border"
local CAST_BORDER = "Interface\\CastingBar\\UI-CastingBar-Border-Small"
local CAST_SHIELD = "Interface\\CastingBar\\UI-CastingBar-Small-Shield"
local CAST_SPARK  = "Interface\\CastingBar\\UI-CastingBar-Spark"
local CAST_FILL   = "Interface\\TargetingFrame\\UI-StatusBar"
local PLATE_GLOW  = "Interface\\Tooltips\\Nameplate-Glow"

-- Geometria de respaldo (unidades de la placa nativa) por si no se pudo medir.
-- x/y/w/h = hueco de la barra dentro del borde; lx/ly = centro del nivel;
-- ix/iy/is = centro y tamano del icono; ox/oy = cast respecto a la barra de vida
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
-- Hechizos de totem por elemento: GetSpellInfo da el nombre en el idioma del
-- cliente (el mismo que lleva el PNJ del totem) y su icono, sin texturas extra
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
	-- Algunos servidores anaden el rango en numeros romanos ("Searing Totem VII")
	return totemByName[name] or totemByName[(string.gsub(name, "%s+[IVXL]+$", ""))]
end

-- Icono de un totem: el propio si se configuro (ruta o ID de hechizo) o el del juego
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

-- Aliados solo con nombre segun la zona (0 no, 1 PNJs, 2 jugadores, 3 ambos)
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

-- Formatos de texto de vida (como RefinedBlizzPlates)
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
-- Tamano de 1 pixel fisico en unidades de "frame"
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
-- Un error en una placa no debe cortar el refresco de las demas;
-- se avisa en el chat principal (una vez por mensaje) para poder depurarlo
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

-- Tokens y numeros precalculados: crear cadenas como "arena" .. i en cada
-- actualizacion genera basura que el recolector limpia de golpe (tirones)
local ARENA, PARTY, PLATE_TOKENS, NUM = {}, {}, {}, {}
for i = 1, 40 do
	PLATE_TOKENS[i] = "nameplate" .. i
	NUM[i] = tostring(i)
end
for i = 1, 5 do ARENA[i] = "arena" .. i end
for i = 1, 4 do PARTY[i] = "party" .. i end

-- Medidor de rendimiento (/hms perf)
local clock = debugprofilestop or function() return GetTime() * 1000 end
local perf = { start = GetTime(), frames = 0, total = 0, max = 0, evMax = 0, update = 0, restyle = 0, cast = 0, built = 0 }
SP.perf = perf

-- Saca un elemento nativo de la placa (el motor re-aplica alpha, el parent no)
local function Kill(obj)
	if not obj then return end
	if not pcall(obj.SetParent, obj, hider) then obj:SetAlpha(0) end
end

-- Se llama al crear la placa (oculta todo lo nativo) y despues periodicamente:
-- el parche de castbars nativos crea su barra cuando empieza el primer cast, asi
-- que esa barra nueva tambien se oculta. Nunca se tocan marcos de otros addons
-- ni marcos protegidos: moverlos en combate es una accion bloqueada por Blizzard
-- ("HemsworkPlates has been blocked from an action...").
local function HideNatives(plate, onlyIfChanged)
	-- En el repaso periodico solo se mira la placa si aparecio un hijo nuevo
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
				-- Castbar nativo creado por el parche despues de crear la placa
				plate.spNativeCast = c
				Kill(c)
			end
		end
	end
	if first then
		-- Copia fija de las regiones: al reparentarlas la lista de la placa se
		-- acorta, y volver a pedirla en cada vuelta daba nil y se saltaba la mitad
		local regions = { plate:GetRegions() }
		local fake = plate.spFake
		for i = 1, #regions do
			local r = regions[i]
			if not (fake and fake[r]) then
				-- Piezas nativas que se siguen leyendo aunque esten ocultas (el motor las
				-- sigue actualizando): nombre, nivel, resaltado del raton, marca, jefe
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
				-- El primer texto nativo es el nombre (lo usa la compatibilidad con WeakAuras)
				if not plate.spNativeName and r:GetObjectType() == "FontString" then plate.spNativeName = r end
				Kill(r)
			end
		end
		plate.spHidden = true
	end
	plate.spNumChildren = plate:GetNumChildren()
end

-- Compatibilidad con WeakAuras 3.3.5 (WeakAuras.GetUnitNameplate / WatchNamePlates):
-- reconoce una placa en WorldFrame si su 1a region es la textura del brillo de
-- amenaza y lee el nombre de su 7a region. Como las regiones nativas se sacan de
-- la placa, se dejan 7 regiones invisibles propias con esa misma forma.
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
	-- Este hook se anade antes que el de WeakAuras, asi que el nombre ya esta
	-- puesto cuando WeakAuras lo lee al mostrarse la placa
	plate:HookScript("OnShow", function(self)
		local n = self.spNativeName and self.spNativeName:GetText()
		if n then name:SetText(n) end
	end)
end

------------------------ MEDICION NATIVA ---------------------------
-- Antes de ocultar la placa nativa se mide donde pone Blizzard cada pieza,
-- asi el estilo clasico queda identico al original.
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
-- Una pildora = tapa izq + centro + tapa der. Sin redondeo, solo centro.
local function NewPill(parent, level)
	local f = CreateFrame("Frame", nil, parent)
	f:SetFrameLevel(parent:GetFrameLevel() + level)
	local p = { f = f }
	p.l = f:CreateTexture(nil, "ARTWORK")
	p.l:SetTexture(CAP)
	p.r = f:CreateTexture(nil, "ARTWORK")
	p.r:SetTexture(CAP)
	p.r:SetTexCoord(1, 0, 0, 1)
	p.m = f:CreateTexture(nil, "ARTWORK")
	p.m:SetTexture(FLAT)
	return p
end

local function LayoutPill(p, h, round, midTex)
	p.m:SetTexture(midTex or FLAT)
	p.m:ClearAllPoints()
	if round then
		local cw = h / 2
		p.l:SetWidth(cw); p.l:SetHeight(h)
		p.l:ClearAllPoints(); p.l:SetPoint("LEFT", p.f, "LEFT", 0, 0)
		p.r:SetWidth(cw); p.r:SetHeight(h)
		p.r:ClearAllPoints(); p.r:SetPoint("RIGHT", p.f, "RIGHT", 0, 0)
		p.m:SetPoint("TOPLEFT", p.l, "TOPRIGHT", 0, 0)
		p.m:SetPoint("BOTTOMRIGHT", p.r, "BOTTOMLEFT", 0, 0)
		p.l:Show(); p.r:Show()
	else
		p.l:Hide(); p.r:Hide()
		p.m:SetAllPoints(p.f)
	end
end

local function ColorPill(p, r, g, b, a)
	a = a or 1
	p.l:SetVertexColor(r, g, b, a)
	p.m:SetVertexColor(r, g, b, a)
	p.r:SetVertexColor(r, g, b, a)
end

local function SetFill(p, w, h, pct, round)
	if not pct or pct ~= pct or pct <= 0 then p.f:Hide() return end
	if pct > 1 then pct = 1 end
	local fw = w * pct
	if round and fw < h then fw = h end
	p.f:SetWidth(fw)
	p.f:Show()
end

-- Contorno + fondo + relleno sobre "owner"
local function BuildBarParts(owner)
	owner.outline = NewPill(owner, 1)
	owner.bgp = NewPill(owner, 2)
	owner.fillp = NewPill(owner, 3)
	-- Capa del borde clasico (encima del relleno, debajo de los textos)
	owner.cl = CreateFrame("Frame", nil, owner)
	owner.cl:SetAllPoints(owner)
	owner.cl:SetFrameLevel(owner:GetFrameLevel() + 5)
	owner.border = owner.cl:CreateTexture(nil, "ARTWORK")
	owner.border:Hide()
end

local function StyleBarParts(owner, h, round, bs, tex)
	LayoutPill(owner.outline, h + 2 * bs, round)
	owner.outline.f:ClearAllPoints()
	owner.outline.f:SetPoint("TOPLEFT", owner, "TOPLEFT", -bs, bs)
	owner.outline.f:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", bs, -bs)
	if bs > 0 then owner.outline.f:Show() else owner.outline.f:Hide() end
	ColorPill(owner.outline, unpack(cfg.borderColor))

	LayoutPill(owner.bgp, h, round)
	owner.bgp.f:ClearAllPoints()
	owner.bgp.f:SetAllPoints(owner)
	owner.bgp.f:Show()
	ColorPill(owner.bgp, unpack(cfg.bgColor))

	LayoutPill(owner.fillp, h, round, tex)
	owner.fillp.f:ClearAllPoints()
	owner.fillp.f:SetPoint("LEFT", owner, "LEFT", 0, 0)
	owner.fillp.f:SetHeight(h)
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
	-- "old" = placas originales de Blizzard (marco dorado); comparte con
	-- "classic" el castbar plateado y el resto del comportamiento
	local old = cfg.shape == "old"
	local classic = cfg.shape == "classic" or old
	local round = cfg.shape == "round"
	local fs, outline = cfg.fontSize, cfg.fontOutline

	sp:SetScale(cfg.scale * (sp.scaleMul or 1))
	local px = PixelUnit(sp)
	sp.px = px
	sp.classic = classic

	local w, h, ch = SnapSize(cfg.width, px), SnapSize(cfg.height, px), SnapSize(cfg.castHeight, px)
	local bs = cfg.borderSize > 0 and SnapSize(cfg.borderSize, px) or 0
	sp:SetWidth(w)
	sp:SetHeight(h)
	sp.fw = w
	StyleBarParts(sp, h, round, bs, cfg.texture)

	SetFontSafe(sp.name, cfg.font, fs, outline)
	SetFontSafe(sp.level, cfg.font, fs, outline)
	SetFontSafe(sp.hp, cfg.font, fs - 1, outline)
	local cb = sp.cast
	local cfs = cfg.castFontSize
	SetFontSafe(cb.text, cfg.font, cfs, outline)
	SetFontSafe(cb.time, cfg.font, cfs, outline)
	-- Una sola linea: si el texto no cabe se recorta en vez de partirse en dos
	cb.text:SetHeight(cfs + 2)
	sp.texts = sp.texts or { sp.name, sp.level, sp.hp, cb.text, cb.time }
	for _, f in ipairs(sp.texts) do
		f:SetTextColor(unpack(cfg.textColor))
	end
	sp.name:SetWidth(w + 14)
	Toggle(sp.name, cfg.showName)
	Toggle(sp.level, cfg.showLevel)
	Toggle(sp.hp, cfg.showHealthText)
	Toggle(sp.cast.text, cfg.showCastText)

	sp.raid:SetWidth(16)
	sp.raid:SetHeight(16)

	local isz = cfg.castIconSize
	cb:ClearAllPoints()
	cb:SetHeight(ch)
	cb.icon:ClearAllPoints()
	cb.text:ClearAllPoints()
	cb.time:ClearAllPoints()

	if classic then
		local one = SnapSize(1, px)
		local oldGap = 0
		sp.glow:Hide()
		sp.inner.f:Hide()
		if old then
			-- Marco dorado original (Nameplate-Border, 128x32) con las medidas de la
			-- placa nativa: barra de 102.91x8.99 en x=3.97, y=4; nivel centrado a
			-- 9.15 del final de la barra (las mismas que usa RefinedBlizzPlates)
			local sx, sy = w / 102.91, h / 8.99
			sp.outline.f:Hide()
			sp.border:SetTexture(HP_BORDER)
			sp.border:SetVertexColor(1, 1, 1, 1)
			sp.border:ClearAllPoints()
			sp.border:SetWidth(SnapSize(128 * sx, px))
			sp.border:SetHeight(SnapSize(32 * sy, px))
			sp.border:SetPoint("BOTTOMLEFT", sp, "BOTTOMLEFT", Snap(-3.968 * sx, px), Snap(-4 * sy, px))
			sp.border:Show()

			sp.name:ClearAllPoints()
			sp.name:SetPoint("CENTER", sp, "CENTER", Snap(cfg.nameX, px), Snap(7.5 * sy + fs * 0.5 + cfg.nameY, px))
			sp.name:SetJustifyH("CENTER")
			sp.name:SetWidth(w + 30)
			sp.level:ClearAllPoints()
			sp.level:SetPoint("CENTER", sp, "RIGHT", Snap(9.15 * sx, px), Snap(0.57 * sy, px))
			oldGap = Snap(4 * sy, px) -- el marco dorado baja ~4 por debajo de la barra
		else
			-- Vida: borde fino oscuro (1 px) como las placas de WotLK Classic
			sp.border:Hide()
			LayoutPill(sp.outline, h, false)
			sp.outline.f:ClearAllPoints()
			sp.outline.f:SetPoint("TOPLEFT", sp, "TOPLEFT", -one, one)
			sp.outline.f:SetPoint("BOTTOMRIGHT", sp, "BOTTOMRIGHT", one, -one)
			ColorPill(sp.outline, 0, 0, 0, 1)
			sp.outline.f:Show()

			sp.name:ClearAllPoints()
			sp.name:SetPoint("BOTTOM", sp, "TOP", Snap(cfg.nameX, px), one + Snap(2 + cfg.nameY, px))
			sp.name:SetJustifyH("CENTER")
			sp.name:SetWidth(w + 30)
			sp.level:ClearAllPoints()
			sp.level:SetPoint("LEFT", sp, "RIGHT", one + Snap(4, px), 0)
		end

		-- Cast: marco plateado de Blizzard (el del castbar del target) con sus
		-- proporciones originales: barra 150x10, borde 197x49 anclado TOP +20,
		-- icono 16x16 a 5 de la izquierda. Empieza donde la barra de vida y
		-- llega hasta debajo del numero de nivel, como en la referencia
		local reach = SnapSize(one + 4 + fs * 1.1, px)
		local cw = w + reach
		local fx, fy = cw / 150, ch / 10
		cb:SetPoint("TOPLEFT", sp, "BOTTOMLEFT", 0, -Snap(one + 4 + 3 * fy, px) - oldGap)
		cb:SetPoint("TOPRIGHT", sp, "BOTTOMRIGHT", reach, -Snap(one + 4 + 3 * fy, px) - oldGap)
		cb.fw = cw
		StyleBarParts(cb, ch, false, 0, CAST_FILL)
		cb.inner.f:Hide()

		for _, t in ipairs({ cb.border, cb.shield }) do
			t:ClearAllPoints()
			t:SetWidth(SnapSize(197 * fx, px))
			t:SetHeight(SnapSize(49 * fy, px))
			t:SetPoint("TOP", cb, "TOP", 0, Snap(20 * fy, px))
		end
		cb.border:SetTexture(CAST_BORDER)
		cb.shield:SetTexture(CAST_SHIELD)
		cb.border:Show()
		cb.shield:Hide()

		cb.spark:SetWidth(SnapSize(32 * fy, px))
		cb.spark:SetHeight(SnapSize(32 * fy, px))

		isz = SnapSize(16 * fy, px)
		-- Icono pegado al marco, con su propio borde fino oscuro
		cb.icon:SetPoint("RIGHT", cb, "LEFT", -Snap(2.5 * fy, px), 0)
		cb.iconEdge:SetAlpha(1)
		cb.iconEdge:ClearAllPoints()
		cb.iconEdge:SetPoint("TOPLEFT", cb.icon, "TOPLEFT", -one, one)
		cb.iconEdge:SetPoint("BOTTOMRIGHT", cb.icon, "BOTTOMRIGHT", one, -one)
		cb.iconEdge:SetTexture(0, 0, 0, 1)

		cb.text:SetPoint("CENTER", cb, "CENTER", 0, 0)
		cb.text:SetWidth(cw - 2 * (cfs * 2 + 4))
		cb.time:SetPoint("RIGHT", cb, "RIGHT", -2, 0)
	else
		sp.border:Hide()
		sp.glow:Hide()
		cb.border:Hide()
		cb.shield:Hide()
		cb.inner.f:Hide()
		sp.inner.f:Hide()
		cb.spark:Hide()

		sp.name:ClearAllPoints()
		sp.name:SetPoint("BOTTOM", sp, "TOP", Snap(cfg.nameX, px), Snap(3 + cfg.nameY, px))
		sp.name:SetJustifyH("CENTER")
		sp.level:ClearAllPoints()
		sp.level:SetPoint("LEFT", sp, "RIGHT", Snap(cfg.levelOffset, px) + bs, 0)

		-- Icono + barra ocupan exactamente el ancho de la placa
		isz = SnapSize(isz, px)
		local gap = Snap(2 * bs + 2, px)
		local iw = cfg.showCastIcon and (isz + gap) or 0
		cb:SetPoint("TOPLEFT", sp, "BOTTOMLEFT", iw, Snap(-4, px) - bs)
		cb:SetPoint("TOPRIGHT", sp, "BOTTOMRIGHT", 0, Snap(-4, px) - bs)
		cb.fw = w - iw
		StyleBarParts(cb, ch, round, bs, cfg.texture)

		cb.icon:SetPoint("RIGHT", cb, "LEFT", -gap, 0)
		cb.iconEdge:SetAlpha(1)
		cb.iconEdge:ClearAllPoints()
		local ie = math.max(px, bs)
		cb.iconEdge:SetPoint("TOPLEFT", cb.icon, "TOPLEFT", -ie, ie)
		cb.iconEdge:SetPoint("BOTTOMRIGHT", cb.icon, "BOTTOMRIGHT", ie, -ie)
		cb.iconEdge:SetTexture(unpack(cfg.borderColor))

		cb.text:SetPoint("LEFT", cb, "LEFT", 3 + (round and ch / 2 or 0), 0)
		cb.text:SetWidth(0)
		cb.time:SetPoint("RIGHT", cb, "RIGHT", -3 - (round and ch / 2 or 0), 0)
	end
	cb.icon:SetWidth(isz)
	cb.icon:SetHeight(isz)

	-- En 3.3.5 un FontString no se redibuja con la fuente nueva hasta que
	-- cambia su texto: se vacia y se vuelve a poner para forzarlo
	for _, f in ipairs(sp.texts) do
		local t = f:GetText()
		f:SetText("")
		f:SetText(t)
	end

	-- Brillo de target / mouseover: degradado alrededor del borde
	local o = (classic and SnapSize(1, px)) or bs
	local gs = SnapSize(cfg.glowSize, px)
	local gl = sp.gl
	gl.t:ClearAllPoints()
	gl.t:SetPoint("BOTTOMLEFT", sp, "TOPLEFT", -o - gs, o)
	gl.t:SetPoint("TOPRIGHT", sp, "TOPRIGHT", o + gs, o + gs)
	gl.b:ClearAllPoints()
	gl.b:SetPoint("TOPLEFT", sp, "BOTTOMLEFT", -o - gs, -o)
	gl.b:SetPoint("BOTTOMRIGHT", sp, "BOTTOMRIGHT", o + gs, -o - gs)
	gl.l:ClearAllPoints()
	gl.l:SetPoint("TOPRIGHT", sp, "TOPLEFT", -o, o)
	gl.l:SetPoint("BOTTOMLEFT", sp, "BOTTOMLEFT", -o - gs, -o)
	gl.r:ClearAllPoints()
	gl.r:SetPoint("TOPLEFT", sp, "TOPRIGHT", o, o)
	gl.r:SetPoint("BOTTOMRIGHT", sp, "BOTTOMRIGHT", o + gs, -o)
	gl:Hide()

	-- Icono de totem
	local ts = SnapSize(cfg.totemSize, px)
	sp.totem:SetWidth(ts)
	sp.totem:SetHeight(ts)
	local te = SnapSize(2, px)
	sp.totem.edge:ClearAllPoints()
	sp.totem.edge:SetPoint("TOPLEFT", sp.totem, "TOPLEFT", -te, te)
	sp.totem.edge:SetPoint("BOTTOMRIGHT", sp.totem, "BOTTOMRIGHT", te, -te)

	-- Numero de arena / grupo, a la izquierda de la barra
	SetFontSafe(sp.idText, cfg.font, fs + 4, "OUTLINE")
	sp.idText:ClearAllPoints()
	sp.idText:SetPoint("RIGHT", sp, "LEFT", -Snap(4, px) - o, 0)
	sp.idText:Hide()

	if SP.LayoutDebuff then SP.LayoutDebuff(sp, px, fs) end
	if SP.LayoutGCD then SP.LayoutGCD(sp, px, fs) end
	sp.auraDirty = true

	sp.cr, sp.curBC, sp.castNI, sp.lvlStr, sp.nameStr, sp.glowState, sp.idStr = nil, nil, nil, nil, nil, nil, nil
	SP.ApplyMode(sp, sp.mode or "normal")
end

-- Modo de la placa: "normal", "barless" (solo nombre), "totem" o "hidden"
function SP.ApplyMode(sp, mode)
	if mode ~= "normal" then
		sp.barParts = sp.barParts or { sp.outline.f, sp.bgp.f, sp.fillp.f, sp.inner.f, sp.gl, sp.cast }
		for _, f in ipairs(sp.barParts) do f:Hide() end
		if sp.debuff then sp.debuff:Hide() end
		if sp.gcdFrame then sp.gcdFrame:Hide() end
		sp.casting = false
		sp.border:Hide()
		sp.level:Hide()
		sp.hp:Hide()
		sp.idText:Hide()
		Toggle(sp.name, mode == "barless")
	end
	Toggle(sp.totem, mode == "totem")
end

local function Build(plate)
	-- Diagnostico: estructura nativa antes de ocultarla (/hms debug)
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
	sp.inner = NewPill(sp, 2)
	sp.inner.f:Hide()
	sp.glow = sp.cl:CreateTexture(nil, "OVERLAY")
	sp.glow:SetTexture(PLATE_GLOW)
	sp.glow:SetBlendMode("ADD")
	sp.glow:Hide()

	-- Capa superior para textos e iconos
	sp.top = CreateFrame("Frame", nil, sp)
	sp.top:SetAllPoints(sp)
	sp.top:SetFrameLevel(sp:GetFrameLevel() + 8)

	sp.name = NewFont(sp.top, "LEFT")
	sp.level = NewFont(sp.top, "LEFT")
	sp.level:SetPoint("LEFT", sp, "RIGHT", 4, 0)
	sp.hp = NewFont(sp.top, "CENTER")
	sp.hp:SetPoint("CENTER", sp, "CENTER", 0, 0)

	-- Brillo (4 degradados alrededor de la barra)
	sp.gl = CreateFrame("Frame", nil, sp)
	sp.gl:SetAllPoints(sp)
	sp.gl:SetFrameLevel(sp:GetFrameLevel() + 6)
	for _, k in ipairs({ "t", "b", "l", "r" }) do
		local t = sp.gl:CreateTexture(nil, "OVERLAY")
		t:SetTexture(FLAT)
		t:SetBlendMode("ADD")
		sp.gl[k] = t
	end
	sp.gl:Hide()

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
	-- Fondo oscuro dentro del marco clasico (encima del marco, debajo del relleno)
	cb.inner = NewPill(cb, 2)
	cb.inner.f:Hide()
	cb.shield = cb.cl:CreateTexture(nil, "ARTWORK")
	cb.shield:Hide()
	cb.spark = cb.cl:CreateTexture(nil, "OVERLAY")
	cb.spark:SetTexture(CAST_SPARK)
	cb.spark:SetBlendMode("ADD")
	cb.spark:Hide()
	-- El icono va debajo del marco clasico, igual que el original
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

	-- Sin token no llegan eventos de vida: la barra nativa avisa al cambiar
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
	-- Tapeado por otro (como UnitIsTapDenied de ClassicAPI): si el mob da credito
	-- a toda su lista de amenaza (UnitIsTappedByAllThreatList) no cuenta como tapeado
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

-- Icono del hechizo dentro de la barra nativa del parche (si lo tiene)
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

-- El motor deja a opacidad completa solo la placa del target
local function IsTargetPlate(plate, name)
	return UnitExists("target") and plate:GetAlpha() > 0.99 and UnitName("target") == name
end

local function IsHoverPlate(plate)
	local h = plate.spN and plate.spN.highlight
	return h and h:IsShown() and true or false
end

-- Token del juego para la placa (por nombre). En arena los nombres de los
-- jugadores son unicos; las mascotas con el mismo nombre pueden confundirse.
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

-- Sin token: reaccion y clase segun el color de la barra nativa
-- (los jugadores enemigos llevan color de clase con ShowClassColorInNameplate)
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

-- Nombre -> placa (para los eventos de unidad) y GUID -> placa (registro de combate)
local plateByName = {}
local function SetPlateUnit(plate, name, unit)
	local sp = plate.sp
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
-- Brillo de target / mouseover
local function UpdateGlow(sp, isTarget, hover)
	local st = (isTarget and cfg.targetGlow and "t") or (hover and cfg.hoverGlow and "h") or nil
	if sp.glowState == st then return end
	sp.glowState = st
	if not st then sp.gl:Hide() return end
	local c = st == "t" and cfg.targetGlowColor or cfg.hoverGlowColor
	local a = st == "t" and cfg.targetGlowAlpha or cfg.hoverGlowAlpha
	local r, g, b = c[1], c[2], c[3]
	local gl = sp.gl
	gl.t:SetGradientAlpha("VERTICAL", r, g, b, a, r, g, b, 0)
	gl.b:SetGradientAlpha("VERTICAL", r, g, b, 0, r, g, b, a)
	gl.l:SetGradientAlpha("HORIZONTAL", r, g, b, 0, r, g, b, a)
	gl.r:SetGradientAlpha("HORIZONTAL", r, g, b, a, r, g, b, 0)
	gl:Show()
end

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

function UpdatePlate(plate)
	perf.update = perf.update + 1
	local sp = plate.sp
	if not sp or not active[plate] then return end
	local round = cfg.shape == "round"
	local name = NativeName(plate)
	local isTarget = IsTargetPlate(plate, name) and true or false
	local hover = IsHoverPlate(plate)
	local unit = ResolveUnit(name, isTarget, hover)
	SetPlateUnit(plate, name, unit)
	if plate.spWAName then plate.spWAName:SetText(name) end
	local isPlayer, friendly, nClass, nKind
	if unit then
		isPlayer = UnitIsPlayer(unit) and true or false
		friendly = UnitIsFriend("player", unit) and true or false
	else
		isPlayer, friendly, nClass, nKind = NativeInfo(plate)
	end
	sp.isTarget = isTarget

	-- Escala del target / aliados
	local mul = (isTarget and cfg.targetScale) or (friendly and cfg.friendlyScale) or 1
	if sp.scaleMul ~= mul then
		sp.scaleMul = mul
		Restyle(plate)
	end
	sp:SetAlpha((not UnitExists("target") or isTarget) and 1 or cfg.nonTargetAlpha)

	-- Modo: totem como icono, aliado solo con nombre o placa normal
	local mode = "normal"
	local tid = cfg.totemIcons and not isPlayer and TotemID(name)
	local tmode = tid and ((cfg.totems[tid] and cfg.totems[tid].mode) or 1)
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
	if mode == "hidden" then return end
	if mode == "totem" then
		sp.totem.icon:SetTexture(SP.TotemTexture(tid))
		if isTarget then sp.totem.edge:SetVertexColor(1, 1, 0.3, 1)
		elseif friendly then sp.totem.edge:SetVertexColor(0.1, 0.9, 0.1, 1)
		else sp.totem.edge:SetVertexColor(0.9, 0.1, 0.1, 1) end
		sp.raid:Hide()
		return
	end

	-- Numero de arena / grupo
	local id, ir, ig, ib
	if unit then id, ir, ig, ib = ArenaID(unit) end
	local idAsName = id and cfg.arenaIDPos == "name"
	if idAsName then name = id end

	if mode == "barless" then
		if sp.nameStr ~= name then sp.nameStr = name; sp.name:SetText(name) end
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
			-- En lugar del nombre: el numero toma el color de arena (rojo/verde)
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
		SetFill(sp.fillp, sp.fw, cfg.height, hpv / hpm, round)
		if cfg.showHealthText then sp.hp:SetText(HealthString(hpv, hpm)) end

		-- Color
		local r, g, b
		if unit then r, g, b = UnitColor(unit) else r, g, b = NativeColor(nClass, nKind) end
		if sp.cr ~= r or sp.cg ~= g or sp.cb ~= b then
			sp.cr, sp.cg, sp.cb = r, g, b
			ColorPill(sp.fillp, r, g, b, 1)
		end

		-- Nombre y nivel
		if sp.nameStr ~= name then sp.nameStr = name; sp.name:SetText(name) end
		local lvl
		if unit then lvl = UnitLevel(unit) else lvl = NativeLevel(plate) end
		local lt = (lvl and lvl > 0) and tostring(lvl) or "??"
		if sp.lvlStr ~= lt then
			sp.lvlStr = lt
			sp.level:SetText(lt)
			if sp.classic then
				-- Nivel coloreado por dificultad, como el original
				if lvl and lvl > 0 and DiffColor then
					local c = DiffColor(lvl)
					sp.level:SetTextColor(c.r, c.g, c.b)
				else
					sp.level:SetTextColor(1, 0.1, 0.1)
				end
			end
		end
		UpdateGlow(sp, isTarget, hover)

		-- Debuffs importantes: solo se reescanean al llegar UNIT_AURA (o en el repaso)
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

	-- Borde con target / mouseover
	if sp.classic then
		-- Borde negro; se aclara con el raton encima
		if sp.curBC ~= hover then
			sp.curBC = hover
			local v = hover and 0.8 or 0
			ColorPill(sp.outline, v, v, v, 1)
		end
	else
		local bc = cfg.borderColor
		if isTarget then bc = cfg.targetBorderColor
		elseif hover then bc = cfg.hoverBorderColor end
		if sp.curBC ~= bc then
			sp.curBC = bc
			ColorPill(sp.outline, bc[1], bc[2], bc[3], bc[4] or 1)
		end
	end

	UpdateCast(plate)
end

-- Cast: se llama desde UpdatePlate, en un sondeo ligero (20 veces/s) y, mientras
-- la unidad castea, en cada frame para que la barra avance suave
function UpdateCast(plate)
	perf.cast = perf.cast + 1
	local sp, unit = plate.sp, plate.spUnit
	if not sp or sp.mode ~= "normal" then return end
	local round = cfg.shape == "round"
	local cb = sp.cast
	if not cfg.showCast then cb:Hide(); sp.casting = false return end

	-- Interrumpido: la barra se queda parada en rojo hasta que pasa el tiempo
	-- (con un desvanecido al final) o empieza otro cast
	if sp.intUntil then
		local rem = sp.intUntil - GetTime()
		if rem > 0 and not (unit and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) then
			cb:SetAlpha(rem < 0.3 and rem / 0.3 or 1)
			sp.casting = true -- sigue actualizandose cada frame para el desvanecido
			return
		end
		sp.intUntil = nil
		sp.castNI = nil -- recolorear el siguiente cast
		cb:SetAlpha(1)
		Toggle(cb.text, cfg.showCastText)
	end

	-- Sin token (no es arena/target/focus/mouseover) no hay forma de leer su cast
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
		-- Respaldo: progreso de la barra nativa (oculta) del parche de castbars
		local nc = plate.spNativeCast
		if nc and nc:IsShown() then
			local mn, mx = nc:GetMinMaxValues()
			-- Solo cuenta como cast si la barra se esta moviendo: una barra
			-- nativa quieta (sin cast real) no debe mostrar un marco vacio
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
		SetFill(cb.fillp, cb.fw, cfg.castHeight, pct, round)

		local ni = (a8 == true) or (a9 == true)
		if sp.castNI ~= ni then
			sp.castNI = ni
			local c = ni and cfg.castNoInterruptColor or cfg.castColor
			ColorPill(cb.fillp, c[1], c[2], c[3], 1)
			if sp.classic then
				-- Escudo original cuando no se puede interrumpir
				Toggle(cb.border, not ni)
				Toggle(cb.shield, ni)
			end
			cb.icon:SetDesaturated(ni)
		end
		if sp.classic and pct > 0 and pct < 1 then
			cb.spark:ClearAllPoints()
			cb.spark:SetPoint("CENTER", cb, "LEFT", cb.fw * pct, 0)
			cb.spark:Show()
		else
			cb.spark:Hide()
		end
		cb.text:SetText(spell)
		if cfg.showCastTime and left then
			cb.time:SetText(string.format("%.1f", math.max(0, left)))
			cb.time:Show()
		else
			cb.time:Hide()
		end
		if cfg.showCastIcon and icon then
			cb.icon:SetTexture(icon)
			cb.icon:Show(); cb.iconEdge:Show()
		else
			cb.icon:Hide(); cb.iconEdge:Hide()
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
	if not sp or sp.mode ~= "normal" or not cfg.showCast then return end
	local cb = sp.cast
	if sp.intUntil then
		-- Ya estaba interrumpido: solo completar el nombre de quien corto
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
	if sp.classic then
		cb.border:Show()
		cb.shield:Hide()
	end
	cb.text:SetText((who and cfg.showInterrupter) and (INTERRUPTED .. ": " .. who) or INTERRUPTED)
	cb.text:Show()
	cb:SetAlpha(1)
	cb:Show()
	sp.casting = true
end

------------------------------ POSICION ----------------------------
-- Desplazamiento para que la placa caiga exacta en la rejilla de pixeles
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
		a.sp:SetPoint("CENTER", a.plate, "CENTER", SnapOffset(a.sp, a.plate, ClampTop(a.sp, a.plate, cur + cfg.offsetY), cfg.offsetX))
	end
end

local function Position(dt)
	if cfg.stacking then
		Restack(dt)
	else
		for plate, sp in pairs(active) do
			sp.curOff = 0
			sp:SetPoint("CENTER", plate, "CENTER", SnapOffset(sp, plate, ClampTop(sp, plate, cfg.offsetY), cfg.offsetX))
		end
	end
end

------------------------------ EVENTOS -----------------------------
-- Las placas se actualizan cuando llega un evento que las afecta (dirty) en
-- vez de recalcularlo todo 20 veces por segundo. Los eventos de unidad pueden
-- venir con "nameplateN" o con otros tokens (target, focus, party...): el GUID
-- permite encontrar la placa en ambos casos.
-- Ultimo que corto a cada GUID (SPELL_INTERRUPT puede llegar antes o despues
-- de UNIT_SPELLCAST_INTERRUPTED)
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

function SP.OnCombatLog(_, sub, _, srcName, _, dstGUID, _, _, spellId)
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
	sp.nameStr, sp.lvlStr, sp.cr, sp.curBC, sp.castNI = nil, nil, nil, nil, nil
	sp.glowState, sp.idStr = nil, nil
	if sp.mode ~= "normal" then
		sp.mode = "normal"
		Restyle(plate)
	end
	sp:SetPoint("CENTER", plate, "CENTER", 0, 0)
	active[plate] = sp
	sp:Show()
	UpdatePlate(plate)
end

local function OnPlateHide(plate)
	Forget(plate)
end

-- Sin Awesome WotLK no hay eventos de placas: se buscan entre los hijos de
-- WorldFrame (solo cuando cambia su numero). Una placa nativa se reconoce por
-- su primera region: la textura del brillo de amenaza.
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

-- Repaso: placas nuevas, placas que se ocultaron sin aviso y piezas nativas nuevas
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
	-- Segunda pasada en el siguiente frame, cuando el motor ya recalculo
	-- tamanos y escalas (algunos cambios no se ven con una sola pasada)
	driver.pendingRefresh = true
end

-------------------------- TARGET / FOCUS ---------------------------
-- Se engancha al codigo de Blizzard de los castbars de target y focus (despues
-- de que Blizzard actualice) para: dejar la barra parada en rojo con
-- "Interrupted: quien" y pintar distinto los casts no interrumpibles.
local tfValue = {}
function SP.SetupTargetFocus()
	if not CastingBarFrame_OnEvent then return end
	local bars = {}
	if TargetFrameSpellBar then bars[TargetFrameSpellBar] = "target" end
	if FocusFrameSpellBar then bars[FocusFrameSpellBar] = "focus" end

	-- Guardar por donde iba la barra (Blizzard la llena entera al interrumpir)
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

-- Registra el coste de cada frame y avisa (como mucho cada 10 s) de picos grandes
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
		Merge(HemsworkPlatesDB, defaults)
		cfg = HemsworkPlatesDB
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
			cfg.castExtraWidth = 0
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
			-- El cliente ya separa las placas (spreadnameplates): el apilado
			-- propio encima hacia que se movieran solas. Proporciones de la referencia.
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
		SP.cfg = cfg
		if SP.UpdateLanguage then SP.UpdateLanguage() end
		self:UnregisterEvent("ADDON_LOADED")
		-- Marca de version para comprobar que el juego cargo el archivo actual
		DEFAULT_CHAT_FRAME:AddMessage(T("|cff66ccffHemsworkPlates|r cargado: version 1.0.1 Warmane (sin Awesome WotLK)"))

		-- Color de clase en las barras nativas de jugadores enemigos: sin token es
		-- la unica forma de saber su clase
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
			if SP.UpdateGCDs then SafeCall(SP.UpdateGCDs, active) end

			-- El mouseover no avisa al salir: se comprueba aqui
			local hp = self.hoverPlate
			if hp and not IsHoverPlate(hp) then
				dirty[hp] = true
				self.hoverPlate = nil
			end

			-- La opacidad nativa del target cambia un frame despues del evento
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

			-- Cast: cada frame en las que castean, sondeo ligero en el resto
			self.castAcc = (self.castAcc or 0) + dt
			local poll = self.castAcc >= 0.05
			if poll then self.castAcc = 0 end
			for plate, sp in pairs(active) do
				if poll or sp.casting then SafeCall(UpdateCast, plate) end
			end

			-- Repaso de seguridad por si algun evento no llego
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
	-- Los errores de Lua pueden estar ocultos en el cliente: se muestran en el chat
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
		-- Busca en TODO el UI barras visibles cerca de la placa
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
