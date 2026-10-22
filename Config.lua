--------------------------------------------------------------------
-- HemsworkPlates - Panel de configuracion (/hms)
--------------------------------------------------------------------
local addonName, SP = ...
local function T(s) return SP.T(s) end

local frame
local widgets = {}
local uid = 0
local function UName() uid = uid + 1; return "HemsworkPlatesW" .. uid end
local UpdateClassicState
local lastLanguage
local function Apply()
	-- Cambio de idioma: los textos del panel se crean una vez, hace falta /reload
	if SP.cfg.language ~= lastLanguage then
		if lastLanguage ~= nil then
			SP.UpdateLanguage()
			DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffHemsworkPlates:|r " .. T("Haz /reload para cambiar el idioma de todo el panel."))
		end
		lastLanguage = SP.cfg.language
	end
	SP.Refresh()
	UpdateClassicState()
end

-- Ajustes que el estilo Clasico WotLK no usa (lo decide la textura original)
local classicOff = {}
local function ClassicOff(w) classicOff[#classicOff + 1] = w end
function UpdateClassicState()
	local off = SP.cfg.shape == "classic" or SP.cfg.shape == "old"
	for _, w in ipairs(classicOff) do
		w:SetAlpha(off and 0.35 or 1)
		w:EnableMouse(not off)
	end
end

------------------------------ WIDGETS -----------------------------
local function MakeCheck(parent, x, y, label, key)
	local cb = CreateFrame("CheckButton", UName(), parent, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", x, y)
	_G[cb:GetName() .. "Text"]:SetText(label)
	cb:SetScript("OnClick", function(self)
		SP.cfg[key] = self:GetChecked() and true or false
		Apply()
	end)
	function cb:Refresh() self:SetChecked(SP.cfg[key]) end
	widgets[#widgets + 1] = cb
	return cb
end

local function MakeSlider(parent, x, y, label, key, minV, maxV, step, fmt)
	local name = UName()
	local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	s:SetPoint("TOPLEFT", x, y)
	s:SetWidth(190)
	s:SetMinMaxValues(minV, maxV)
	s:SetValueStep(step)
	_G[name .. "Low"]:SetText(minV)
	_G[name .. "High"]:SetText(maxV)
	local text = _G[name .. "Text"]
	s:SetScript("OnValueChanged", function(self, v)
		v = math.floor(v / step + 0.5) * step
		text:SetText(label .. ": " .. string.format(fmt or "%d", v))
		if self.loading then return end
		SP.cfg[key] = v
		Apply()
	end)
	function s:Refresh()
		self.loading = true
		self:SetValue(SP.cfg[key])
		self.loading = false
	end
	widgets[#widgets + 1] = s
	return s
end

local function MakeSwatch(parent, x, y, label, getter, setter)
	local b = CreateFrame("Button", UName(), parent)
	b:SetWidth(18)
	b:SetHeight(18)
	b:SetPoint("TOPLEFT", x, y)
	local edge = b:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints()
	edge:SetTexture(0, 0, 0, 1)
	local tex = b:CreateTexture(nil, "ARTWORK")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fs:SetPoint("LEFT", b, "RIGHT", 6, 0)
	fs:SetText(label)
	b.label = fs
	function b:Refresh()
		local r, g, bl = getter()
		tex:SetTexture(r, g, bl, 1)
	end
	b:SetScript("OnClick", function(self)
		local r, g, bl = getter()
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame.opacityFunc = nil
		ColorPickerFrame.previousValues = { r = r, g = g, b = bl }
		ColorPickerFrame.func = function()
			setter(ColorPickerFrame:GetColorRGB())
			self:Refresh()
			Apply()
		end
		ColorPickerFrame.cancelFunc = function(p)
			setter(p.r, p.g, p.b)
			self:Refresh()
			Apply()
		end
		ColorPickerFrame:SetColorRGB(r, g, bl)
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end)
	widgets[#widgets + 1] = b
	return b
end

local function CfgColor(key)
	return function() local c = SP.cfg[key]; return c[1], c[2], c[3] end,
	       function(r, g, b) local c = SP.cfg[key]; c[1], c[2], c[3] = r, g, b end
end
local function MakeCfgSwatch(parent, x, y, label, key)
	local g, s = CfgColor(key)
	return MakeSwatch(parent, x, y, label, g, s)
end

-- Lista desplegable propia (con scroll de rueda)
local ROWS = 12
local listFrame
local function ShowList(anchor, opts, current, onPick)
	if not listFrame then
		listFrame = CreateFrame("Frame", "HemsworkPlatesList", UIParent)
		listFrame:SetFrameStrata("TOOLTIP")
		listFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
		listFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.97)
		listFrame:SetBackdropBorderColor(0, 0, 0, 1)
		listFrame:EnableMouse(true)
		listFrame:EnableMouseWheel(true)
		listFrame.rows = {}
		for i = 1, ROWS do
			local r = CreateFrame("Button", nil, listFrame)
			r:SetHeight(18)
			r:SetPoint("TOPLEFT", 2, -2 - (i - 1) * 18)
			r:SetPoint("TOPRIGHT", -2, -2 - (i - 1) * 18)
			r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			r.text:SetPoint("LEFT", 4, 0)
			local hl = r:CreateTexture(nil, "HIGHLIGHT")
			hl:SetAllPoints()
			hl:SetTexture(1, 1, 1, 0.15)
			r:SetScript("OnClick", function(self)
				listFrame:Hide()
				if self.opt then listFrame.onPick(self.opt) end
			end)
			listFrame.rows[i] = r
		end
		function listFrame:Redraw()
			for i = 1, ROWS do
				local o, r = self.opts[self.offset + i], self.rows[i]
				if o then
					r.opt = o
					r.text:SetText(o[1])
					if o[2] == self.current then r.text:SetTextColor(1, 0.82, 0) else r.text:SetTextColor(1, 1, 1) end
					r:Show()
				else
					r.opt = nil
					r:Hide()
				end
			end
		end
		listFrame:SetScript("OnMouseWheel", function(self, d)
			local maxOff = math.max(0, #self.opts - ROWS)
			self.offset = math.max(0, math.min(maxOff, self.offset - d))
			self:Redraw()
		end)
		listFrame:SetScript("OnUpdate", function(self)
			if IsMouseButtonDown("LeftButton") and not MouseIsOver(self) and not (self.anchor and MouseIsOver(self.anchor)) then
				self:Hide()
			end
		end)
	end
	listFrame.opts, listFrame.current, listFrame.onPick, listFrame.anchor = opts, current, onPick, anchor
	listFrame.offset = 0
	listFrame:SetWidth(anchor:GetWidth())
	listFrame:SetHeight(4 + math.min(#opts, ROWS) * 18)
	listFrame:ClearAllPoints()
	listFrame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
	listFrame:Redraw()
	listFrame:Show()
end

local function MakeDropdown(parent, x, y, label, key, getOptions)
	local b = CreateFrame("Button", UName(), parent, "UIPanelButtonTemplate")
	b:SetWidth(190)
	b:SetHeight(22)
	b:SetPoint("TOPLEFT", x, y)
	local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	lbl:SetPoint("BOTTOMLEFT", b, "TOPLEFT", 2, 2)
	lbl:SetText(label)
	function b:Refresh()
		local cur, text = SP.cfg[key], SP.cfg[key]
		for _, o in ipairs(getOptions()) do
			if o[2] == cur then text = o[1] end
		end
		self:SetText(text)
	end
	b:SetScript("OnClick", function(self)
		if listFrame and listFrame:IsShown() and listFrame.anchor == self then
			listFrame:Hide()
			return
		end
		ShowList(self, getOptions(), SP.cfg[key], function(o)
			SP.cfg[key] = o[2]
			self:Refresh()
			Apply()
		end)
	end)
	widgets[#widgets + 1] = b
end

local function MakeEditBox(parent, x, y, label, key)
	local e = CreateFrame("EditBox", UName(), parent, "InputBoxTemplate")
	e:SetWidth(180)
	e:SetHeight(20)
	e:SetPoint("TOPLEFT", x + 6, y)
	e:SetAutoFocus(false)
	e:SetFontObject("GameFontHighlightSmall")
	local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	lbl:SetPoint("BOTTOMLEFT", e, "TOPLEFT", -4, 2)
	lbl:SetText(label)
	e:SetScript("OnEnterPressed", function(self)
		SP.cfg[key] = self:GetText()
		self:ClearFocus()
		Apply()
	end)
	e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	function e:Refresh() self:SetText(SP.cfg[key] or ""); self:SetCursorPosition(0) end
	widgets[#widgets + 1] = e
end

------------------------------ OPCIONES ----------------------------
local function FontOptions()
	local o = {
		{ "Friz Quadrata", "Fonts\\FRIZQT__.TTF" },
		{ "Arial Narrow", "Fonts\\ARIALN.TTF" },
		{ "Skurri", "Fonts\\skurri.ttf" },
		{ "Morpheus", "Fonts\\MORPHEUS.ttf" },
	}
	local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
	if LSM then
		local names = {}
		for n in pairs(LSM:HashTable("font")) do names[#names + 1] = n end
		table.sort(names)
		for _, n in ipairs(names) do o[#o + 1] = { n, LSM:Fetch("font", n) } end
	end
	return o
end

local function TextureOptions()
	local o = {
		{ "Blizzard", "Interface\\TargetingFrame\\UI-StatusBar" },
		{ T("Plana"), "Interface\\Buttons\\WHITE8X8" },
	}
	local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
	if LSM then
		local names = {}
		for n in pairs(LSM:HashTable("statusbar")) do names[#names + 1] = n end
		table.sort(names)
		for _, n in ipairs(names) do o[#o + 1] = { n, LSM:Fetch("statusbar", n) } end
	end
	return o
end

local function ShapeOptions()
	return { { T("Clasico WotLK"), "classic" }, { T("Antiguo (Blizzard)"), "old" }, { T("Cuadrada"), "square" }, { T("Redonda"), "round" } }
end

local function HealthFormatOptions()
	return {
		{ T("Porcentaje (85%)"), 1 }, { T("Porcentaje 1 dec. (85.3%)"), 2 }, { T("Actual (12.5k)"), 3 },
		{ T("Actual / Max"), 4 }, { T("Actual (Porc.)"), 5 }, { T("Deficit (-2.1k)"), 6 },
	}
end

local function ArenaIDPosOptions()
	return { { T("A la izquierda de la barra"), "left" }, { T("En lugar del nombre"), "name" } }
end

local function BarlessOptions()
	return { { T("Desactivado"), 0 }, { T("Solo PNJs"), 1 }, { T("Solo jugadores"), 2 }, { T("Jugadores y PNJs"), 3 } }
end

local function LanguageOptions()
	return { { T("Automatico"), "auto" }, { "Español", "es" }, { "English", "en" } }
end

local function OutlineOptions()
	return { { T("Ninguno"), "" }, { T("Contorno"), "OUTLINE" }, { T("Contorno grueso"), "THICKOUTLINE" } }
end

------------------------------ PANELES -----------------------------
local CLASS_ORDER = { "WARRIOR", "PALADIN", "DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK" }

local function BuildGeneral(p)
	MakeSlider(p, 10, -20, T("Ancho"), "width", 60, 200, 1)
	MakeSlider(p, 10, -66, T("Alto de barra"), "height", 4, 24, 1)
	MakeSlider(p, 10, -112, T("Alto cast bar"), "castHeight", 4, 24, 1)
	MakeSlider(p, 10, -158, T("Escala"), "scale", 0.5, 2, 0.05, "%.2f")
	MakeSlider(p, 10, -204, T("Opacidad sin target"), "nonTargetAlpha", 0.2, 1, 0.05, "%.2f")
	ClassicOff(MakeSlider(p, 10, -250, T("Tamano icono cast"), "castIconSize", 8, 30, 1))
	ClassicOff(MakeSlider(p, 10, -296, T("Grosor del borde"), "borderSize", 0, 4, 0.5, "%.1f"))
	MakeCheck(p, 5, -332, T("Pixel perfect (bordes nitidos)"), "pixelPerfect")

	MakeDropdown(p, 250, -20, T("Forma de las barras"), "shape", ShapeOptions)
	MakeDropdown(p, 250, -70, T("Textura de la barra"), "texture", TextureOptions)
	MakeCheck(p, 245, -100, T("Apilar placas (evitar solapamiento)"), "stacking")
	MakeSlider(p, 250, -150, T("Separacion"), "stackGap", 0, 10, 1)
	MakeSlider(p, 250, -196, T("Velocidad de apilado"), "stackSpeed", 2, 30, 1)
	MakeCheck(p, 245, -226, T("Mostrar cast bar"), "showCast")
	MakeCheck(p, 245, -252, T("Icono del hechizo"), "showCastIcon")
	MakeCheck(p, 245, -278, T("Tiempo restante del cast"), "showCastTime")
	MakeCheck(p, 245, -304, T("Nombre del hechizo en el cast"), "showCastText")

	-- Mover la placa entera (izquierda/derecha, arriba/abajo)
	MakeSlider(p, 10, -378, T("Mover horizontal (X)"), "offsetX", -100, 100, 1)
	MakeSlider(p, 250, -350, T("Mover vertical (Y)"), "offsetY", -100, 100, 1)
end

local function BuildText(p)
	MakeDropdown(p, 10, -24, T("Fuente"), "font", FontOptions)
	MakeDropdown(p, 10, -74, T("Contorno"), "fontOutline", OutlineOptions)
	MakeEditBox(p, 10, -126, T("Ruta de fuente personalizada (Enter)"), "font")
	MakeSlider(p, 10, -176, T("Tamano de texto"), "fontSize", 6, 20, 1)
	MakeSlider(p, 10, -268, T("Tamano texto del cast"), "castFontSize", 5, 16, 1)
	MakeDropdown(p, 10, -320, T("Idioma / Language"), "language", LanguageOptions)
	ClassicOff(MakeSlider(p, 10, -222, T("Separacion del nivel"), "levelOffset", 0, 30, 1))

	MakeCheck(p, 245, -14, T("Mostrar nombre"), "showName")
	MakeCheck(p, 245, -44, T("Mostrar nivel"), "showLevel")
	MakeCheck(p, 245, -74, T("Mostrar texto de vida"), "showHealthText")
	MakeCfgSwatch(p, 252, -112, T("Color del texto"), "textColor")

	-- Mover el nombre (con 0, 0 queda en el centro exacto de la barra)
	MakeSlider(p, 250, -164, T("Mover nombre X"), "nameX", -60, 60, 1)
	MakeSlider(p, 250, -210, T("Mover nombre Y"), "nameY", -40, 40, 1)
end

local function BuildColors(p)
	MakeCheck(p, 5, -2, T("Color de clase en jugadores"), "classColorPlayers")

	local y = -36
	for i, class in ipairs(CLASS_ORDER) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		local x, yy = 14 + col * 115, y - row * 26
		local sw = MakeSwatch(p, x, yy, (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class]) or class,
			function() local c = SP.cfg.classColors[class]; return c[1], c[2], c[3] end,
			function(r, g, b) local c = SP.cfg.classColors[class]; c[1], c[2], c[3] = r, g, b end)
		local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
		if c then sw.label:SetTextColor(c.r, c.g, c.b) end
	end

	MakeCfgSwatch(p, 250, -8, T("Hostil"), "hostileColor")
	MakeCfgSwatch(p, 250, -34, T("Neutral"), "neutralColor")
	MakeCfgSwatch(p, 250, -60, T("Amistoso"), "friendlyColor")
	MakeCfgSwatch(p, 250, -86, T("Tapeado por otro"), "tappedColor")
	MakeCfgSwatch(p, 250, -128, T("Fondo de barra"), "bgColor")
	ClassicOff(MakeCfgSwatch(p, 250, -154, T("Borde"), "borderColor"))
	ClassicOff(MakeCfgSwatch(p, 250, -180, T("Borde del target"), "targetBorderColor"))
	MakeCfgSwatch(p, 250, -206, T("Color de cast bar"), "castColor")
	MakeCfgSwatch(p, 250, -232, T("Cast no interrumpible"), "castNoInterruptColor")
	MakeCfgSwatch(p, 250, -258, T("Cast interrumpido"), "castInterruptColor")
end

-- Funciones traidas de RefinedBlizzPlates
local function BuildExtras(p)
	MakeCheck(p, 5, -2, T("Brillo en el target"), "targetGlow")
	MakeCfgSwatch(p, 14, -32, T("Color brillo target"), "targetGlowColor")
	MakeSlider(p, 10, -70, T("Intensidad brillo target"), "targetGlowAlpha", 0.1, 1, 0.05, "%.2f")
	MakeCheck(p, 5, -98, T("Brillo al pasar el raton"), "hoverGlow")
	MakeCfgSwatch(p, 14, -128, T("Color brillo raton"), "hoverGlowColor")
	MakeSlider(p, 10, -166, T("Intensidad brillo raton"), "hoverGlowAlpha", 0.1, 1, 0.05, "%.2f")
	MakeSlider(p, 10, -212, T("Tamano del brillo"), "glowSize", 2, 16, 1)
	MakeDropdown(p, 10, -262, T("Formato del texto de vida"), "healthFormat", HealthFormatOptions)
	MakeCheck(p, 5, -290, T("Ocultar texto con vida al maximo"), "healthHideMax")

	MakeSlider(p, 250, -20, T("Escala del target"), "targetScale", 0.8, 2, 0.05, "%.2f")
	MakeSlider(p, 250, -66, T("Escala de aliados"), "friendlyScale", 0.5, 1.5, 0.05, "%.2f")
	MakeCheck(p, 245, -96, T("Mantener target en pantalla"), "clampTarget")
	MakeSlider(p, 250, -142, T("Margen superior"), "clampMargin", 0, 150, 5)

	MakeSlider(p, 250, -196, T("Tiempo de 'Interrupted' (s)"), "castInterruptHold", 0.3, 3, 0.1, "%.1f")
	MakeCheck(p, 245, -226, T("Mostrar quien corto el cast"), "showInterrupter")
	MakeCheck(p, 245, -252, T("Estilo de cast en target y focus"), "tfCast")
end

local function BuildPvP(p)
	MakeCheck(p, 5, -2, T("Numeros de arena (enemigos)"), "arenaIDs")
	MakeCheck(p, 5, -28, T("Numeros de grupo (aliados)"), "partyIDs")
	MakeDropdown(p, 10, -84, T("Posicion del numero de arena"), "arenaIDPos", ArenaIDPosOptions)

	-- Distinguir aliados de enemigos (en arena todos tienen color de clase)
	MakeCheck(p, 5, -124, T("Aliados con color de clase"), "friendlyClassColor")
	MakeCfgSwatch(p, 14, -154, T("Color de jugadores aliados"), "friendlyPlayerColor")
	MakeSlider(p, 10, -196, T("Tamano de aliados"), "friendlyScale", 0.5, 1.5, 0.05, "%.2f")

	local h = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	h:SetPoint("TOPLEFT", 250, -2)
	h:SetText(T("Aliados solo con nombre"))
	MakeDropdown(p, 250, -38, T("Mundo abierto"), "barlessWorld", BarlessOptions)
	MakeDropdown(p, 250, -88, T("Mazmorras y bandas"), "barlessPvE", BarlessOptions)
	MakeDropdown(p, 250, -138, T("Campos de batalla"), "barlessBG", BarlessOptions)
	MakeDropdown(p, 250, -188, T("Arenas"), "barlessArena", BarlessOptions)
	MakeCheck(p, 245, -218, T("Barras normales en tu target"), "barlessExcludeTarget")
end

-- Lista de totems: modo (icono / oculto / placa) e icono propio de cada uno
local ELEMENT_COLOR = { earth = { 0.8, 0.67, 0 }, fire = { 1, 0.33, 0.33 }, water = { 0.4, 0.6, 1 }, air = { 0.7, 0.9, 1 } }
local MODES = { [1] = { "Icono", 0.3, 1, 0.3 }, [0] = { "Oculto", 1, 0.3, 0.3 }, [2] = { "Placa", 0.8, 0.8, 0.8 } }
local NEXT_MODE = { [1] = 0, [0] = 2, [2] = 1 }

local function TotemCfg(id)
	local t = SP.cfg.totems[id]
	if not t then t = { mode = 1, icon = "" }; SP.cfg.totems[id] = t end
	return t
end

local function BuildTotems(p)
	MakeCheck(p, 5, -2, T("Totems como icono"), "totemIcons")
	MakeCheck(p, 5, -28, T("Ocultar totems aliados"), "totemHideFriendly")
	MakeSlider(p, 250, -20, T("Tamano icono totem"), "totemSize", 12, 48, 1)

	local hdr = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	hdr:SetPoint("TOPLEFT", 8, -60)
	hdr:SetText(T("Totem                                              Modo             Icono propio (ruta o ID de hechizo + Enter)"))

	local sf = CreateFrame("ScrollFrame", UName(), p, "UIPanelScrollFrameTemplate")
	sf:SetPoint("TOPLEFT", 4, -76)
	sf:SetPoint("BOTTOMRIGHT", -26, 0)
	local list = CreateFrame("Frame", nil, sf)
	list:SetWidth(430)
	sf:SetScrollChild(list)

	local y = 0
	for _, grp in ipairs(SP.TOTEMS) do
		local col = ELEMENT_COLOR[grp[1]]
		for _, id in ipairs(grp[2]) do
			local spellName = GetSpellInfo(id)
			if spellName then
				local row = CreateFrame("Frame", nil, list)
				row:SetWidth(430)
				row:SetHeight(24)
				row:SetPoint("TOPLEFT", 0, -y)
				y = y + 26

				local ico = row:CreateTexture(nil, "ARTWORK")
				ico:SetWidth(20)
				ico:SetHeight(20)
				ico:SetPoint("LEFT", 2, 0)
				ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)

				local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				fs:SetPoint("LEFT", 28, 0)
				fs:SetWidth(150)
				fs:SetJustifyH("LEFT")
				fs:SetText(spellName)
				fs:SetTextColor(col[1], col[2], col[3])

				local btn = CreateFrame("Button", UName(), row, "UIPanelButtonTemplate")
				btn:SetWidth(72)
				btn:SetHeight(20)
				btn:SetPoint("LEFT", 182, 0)

				local eb = CreateFrame("EditBox", UName(), row, "InputBoxTemplate")
				eb:SetWidth(160)
				eb:SetHeight(20)
				eb:SetPoint("LEFT", 266, 0)
				eb:SetAutoFocus(false)
				eb:SetFontObject("GameFontHighlightSmall")

				function row:Refresh()
					local t = SP.cfg.totems[id]
					local m = (t and t.mode) or 1
					local md = MODES[m]
					btn:SetText(T(md[1]))
					local bt = btn:GetFontString()
					if bt then bt:SetTextColor(md[2], md[3], md[4]) end
					eb:SetText((t and t.icon) or "")
					eb:SetCursorPosition(0)
					ico:SetTexture(SP.TotemTexture(id))
					ico:SetDesaturated(m ~= 1)
				end
				btn:SetScript("OnClick", function()
					local t = TotemCfg(id)
					t.mode = NEXT_MODE[t.mode or 1]
					row:Refresh()
					Apply()
				end)
				eb:SetScript("OnEnterPressed", function(self)
					TotemCfg(id).icon = strtrim(self:GetText() or "")
					self:ClearFocus()
					row:Refresh()
					Apply()
				end)
				eb:SetScript("OnEscapePressed", function(self) self:ClearFocus(); row:Refresh() end)
				widgets[#widgets + 1] = row
			end
		end
	end
	list:SetHeight(math.max(y, 1))
end

-- Debuffs importantes (integrados desde la WeakAura)
local CAT_LABELS = {
	immunities = "Inmunidades", cc = "Control (CC)", silence = "Silencios", roots = "Raices",
	disarms = "Desarmes", defensives = "Defensivos", offensives = "Ofensivos", others = "Otros",
}

local function DebuffPosOptions()
	return { { T("A la derecha"), "right" }, { T("A la izquierda"), "left" } }
end

local function BuildDebuffs(p)
	MakeCheck(p, 5, -2, T("Mostrar debuffs importantes"), "debuffs")
	MakeCheck(p, 5, -28, T("Solo en enemigos"), "debuffEnemyOnly")
	MakeCheck(p, 5, -54, T("Solo en arena"), "debuffArenaOnly")
	MakeCheck(p, 5, -80, T("Tiempo restante en el icono"), "debuffTimer")
	MakeSlider(p, 10, -126, T("Tamano del icono"), "debuffSize", 16, 60, 1)
	MakeDropdown(p, 10, -176, T("Posicion"), "debuffPos", DebuffPosOptions)

	local h = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	h:SetPoint("TOPLEFT", 250, -2)
	h:SetText(T("Categorias (por prioridad)"))
	for i, cat in ipairs(SP.DEBUFF_CATS or {}) do
		local cb = CreateFrame("CheckButton", UName(), p, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", 245, -18 - (i - 1) * 26)
		_G[cb:GetName() .. "Text"]:SetText(i .. ". " .. T(CAT_LABELS[cat] or cat))
		cb:SetScript("OnClick", function(self)
			SP.cfg.debuffCats[cat] = self:GetChecked() and true or false
			Apply()
		end)
		function cb:Refresh() self:SetChecked(SP.cfg.debuffCats[cat] ~= false) end
		widgets[#widgets + 1] = cb
	end
	MakeCheck(p, 245, -232, T("Bloqueos de interrupcion (Pummel, Kick...)"), "debuffLockouts")
end

------------------------------ PERFILES ----------------------------
-- Exportar / importar la configuracion como un texto para copiar y pegar en
-- otro personaje o cuenta. Formato propio con tipos (no se ejecuta codigo al
-- importar) y despues base64, para que el texto solo tenga letras y numeros.
local PROFILE_PREFIX = "HMS1:"
local PROFILE_SKIP = { geo = true, dbVersion = true } -- datos internos, no ajustes

local function Ser(v, out, top)
	local t = type(v)
	if t == "number" then
		out[#out + 1] = "n" .. v .. ";"
	elseif t == "string" then
		out[#out + 1] = "s" .. #v .. ":" .. v
	elseif t == "boolean" then
		out[#out + 1] = v and "t" or "f"
	elseif t == "table" then
		out[#out + 1] = "{"
		for k, val in pairs(v) do
			local kt, vt = type(k), type(val)
			if (kt == "string" or kt == "number") and not (top and PROFILE_SKIP[k])
				and (vt == "number" or vt == "string" or vt == "boolean" or vt == "table") then
				Ser(k, out)
				Ser(val, out)
			end
		end
		out[#out + 1] = "}"
	end
end

-- Lector del formato anterior; devuelve valor y posicion siguiente (nil si falla)
local function Deser(s, i, depth)
	if depth > 20 then return end
	local c = string.sub(s, i, i)
	if c == "n" then
		local j = string.find(s, ";", i, true)
		local n = j and tonumber(string.sub(s, i + 1, j - 1))
		if n then return n, j + 1 end
	elseif c == "s" then
		local j = string.find(s, ":", i, true)
		local len = j and tonumber(string.sub(s, i + 1, j - 1))
		if len and j + len <= #s then return string.sub(s, j + 1, j + len), j + len + 1 end
	elseif c == "t" then
		return true, i + 1
	elseif c == "f" then
		return false, i + 1
	elseif c == "{" then
		local tbl = {}
		i = i + 1
		while string.sub(s, i, i) ~= "}" do
			if i > #s then return end
			local k, v
			k, i = Deser(s, i, depth + 1)
			if k == nil or type(k) == "boolean" or type(k) == "table" then return end
			v, i = Deser(s, i, depth + 1)
			if v == nil then return end
			tbl[k] = v
		end
		return tbl, i + 1
	end
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64DEC = {}
for i = 1, 64 do B64DEC[string.sub(B64, i, i)] = i - 1 end

local function Enc(data)
	local out = {}
	for i = 1, #data, 3 do
		local a, b, c = string.byte(data, i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1, c2 = math.floor(n / 262144) % 64, math.floor(n / 4096) % 64
		local c3, c4 = math.floor(n / 64) % 64, n % 64
		out[#out + 1] = string.sub(B64, c1 + 1, c1 + 1) .. string.sub(B64, c2 + 1, c2 + 1)
			.. (b and string.sub(B64, c3 + 1, c3 + 1) or "=") .. (c and string.sub(B64, c4 + 1, c4 + 1) or "=")
	end
	return table.concat(out)
end

local function Dec(text)
	local out = {}
	for i = 1, #text, 4 do
		local c1, c2 = B64DEC[string.sub(text, i, i)], B64DEC[string.sub(text, i + 1, i + 1)]
		local c3, c4 = B64DEC[string.sub(text, i + 2, i + 2)], B64DEC[string.sub(text, i + 3, i + 3)]
		if not c1 or not c2 then return end
		local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)
		out[#out + 1] = string.char(math.floor(n / 65536) % 256)
		if c3 then out[#out + 1] = string.char(math.floor(n / 256) % 256) end
		if c4 then out[#out + 1] = string.char(n % 256) end
	end
	return table.concat(out)
end

function SP.ExportProfile()
	local out = {}
	Ser(SP.cfg, out, true)
	return PROFILE_PREFIX .. Enc(table.concat(out))
end

local function FillDefaults(dst, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dst[k]) ~= "table" then dst[k] = {} end
			FillDefaults(dst[k], v)
		elseif dst[k] == nil then
			dst[k] = v
		end
	end
end

-- Devuelve true o false + motivo
function SP.ImportProfile(text)
	text = string.gsub(text or "", "%s", "")
	if string.sub(text, 1, #PROFILE_PREFIX) ~= PROFILE_PREFIX then
		return false, T("el texto no es un perfil de HemsworkPlates")
	end
	local data = Dec(string.sub(text, #PROFILE_PREFIX + 1))
	local tbl = data and Deser(data, 1, 0)
	if type(tbl) ~= "table" or type(tbl.width) ~= "number" then
		return false, T("el perfil esta incompleto o danado (copialo entero)")
	end
	local cfg, defaults = SP.cfg, SP.defaults
	for k in pairs(cfg) do
		if not PROFILE_SKIP[k] then cfg[k] = nil end
	end
	-- Solo ajustes conocidos y con el tipo correcto
	for k, v in pairs(tbl) do
		local d = defaults[k]
		if d ~= nil and type(d) == type(v) and not PROFILE_SKIP[k] then cfg[k] = v end
	end
	FillDefaults(cfg, defaults)
	return true
end

local profFrame
function SP.ShowProfiles()
	if not SP.cfg then return end
	if not profFrame then
		local f = CreateFrame("Frame", "HemsworkPlatesProfiles", UIParent)
		f:SetWidth(440)
		f:SetHeight(300)
		f:SetPoint("CENTER")
		f:SetFrameStrata("FULLSCREEN_DIALOG")
		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartMoving)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 8, right = 8, top = 8, bottom = 8 },
		})
		tinsert(UISpecialFrames, "HemsworkPlatesProfiles")

		local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOP", 0, -16)
		title:SetText(T("Perfiles: importar / exportar"))
		local help = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		help:SetPoint("TOP", 0, -38)
		help:SetText(T("Exportar: copia el texto con Ctrl+C.  Importar: pegalo con Ctrl+V y pulsa Importar."))

		local bg = f:CreateTexture(nil, "BACKGROUND")
		bg:SetTexture(0, 0, 0, 0.6)
		bg:SetPoint("TOPLEFT", 18, -56)
		bg:SetPoint("BOTTOMRIGHT", -18, 48)

		local sf = CreateFrame("ScrollFrame", "HemsworkPlatesProfilesScroll", f, "UIPanelScrollFrameTemplate")
		sf:SetPoint("TOPLEFT", 22, -60)
		sf:SetPoint("BOTTOMRIGHT", -42, 52)
		local eb = CreateFrame("EditBox", nil, sf)
		eb:SetMultiLine(true)
		eb:SetAutoFocus(false)
		eb:SetMaxLetters(0)
		eb:SetFontObject(ChatFontNormal)
		eb:SetWidth(370)
		eb:SetHeight(190)
		eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		sf:SetScrollChild(eb)
		-- Pulsar en cualquier parte del recuadro enfoca el texto
		sf:EnableMouse(true)
		sf:SetScript("OnMouseDown", function() eb:SetFocus() end)
		f.eb = eb

		local status = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		status:SetPoint("BOTTOM", 0, 34)
		f.status = status

		local function Btn(text, x, onClick)
			local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
			b:SetWidth(110)
			b:SetHeight(22)
			b:SetPoint("BOTTOMLEFT", x, 12)
			b:SetText(text)
			b:SetScript("OnClick", onClick)
		end
		Btn(T("Exportar"), 20, function()
			eb:SetText(SP.ExportProfile())
			eb:SetFocus()
			eb:HighlightText()
			status:SetTextColor(0.3, 1, 0.3)
			status:SetText(T("Texto seleccionado: pulsa Ctrl+C para copiarlo"))
		end)
		Btn(T("Importar"), 135, function()
			local ok, err = SP.ImportProfile(eb:GetText())
			if ok then
				Apply()
				for _, w in ipairs(widgets) do w:Refresh() end
				UpdateClassicState()
				status:SetTextColor(0.3, 1, 0.3)
				status:SetText(T("Perfil importado y aplicado"))
			else
				status:SetTextColor(1, 0.3, 0.3)
				status:SetText(T("No se pudo importar: ") .. err)
			end
		end)
		Btn(T("Cerrar"), 310, function() f:Hide() end)
		profFrame = f
	end
	profFrame.eb:SetText("")
	profFrame.status:SetText("")
	profFrame:Show()
end

-- GCD de los enemigos de arena (integrado desde NameplateArenaGCDs)
local function GCDPosOptions()
	return { { T("A la izquierda"), "left" }, { T("A la derecha"), "right" } }
end

local function BuildGCD(p)
	MakeCheck(p, 5, -2, T("Mostrar GCD de enemigos de arena"), "gcd")
	MakeCheck(p, 5, -28, T("Tiempo restante en el icono"), "gcdTimer")
	MakeCheck(p, 5, -54, T("Invertir el barrido"), "gcdReverse")
	MakeCheck(p, 5, -80, T("Ocultar el barrido"), "gcdHideSweep")
	MakeSlider(p, 10, -126, T("Tamano del icono"), "gcdSize", 14, 64, 1)
	MakeSlider(p, 10, -172, T("Opacidad del barrido"), "gcdAlpha", 0, 1, 0.05, "%.2f")

	MakeDropdown(p, 250, -24, T("Posicion"), "gcdPos", GCDPosOptions)

	local test = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
	test:SetWidth(190)
	test:SetHeight(22)
	test:SetPoint("TOPLEFT", 250, -64)
	test:SetText(T("Probar en mi target (15 s)"))
	test:SetScript("OnClick", function() if SP.TestGCD then SP.TestGCD() end end)

	local note = p:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	note:SetPoint("TOPLEFT", 250, -96)
	note:SetWidth(200)
	note:SetJustifyH("LEFT")
	note:SetText(T("Muestra el ultimo hechizo de cada rival de arena con un barrido que dura su GCD (clase, haste y procs instantaneos). Basado en NameplateArenaGCDs."))
end

local function BuildFrame()
	frame = CreateFrame("Frame", "HemsworkPlatesConfig", UIParent)
	frame:SetWidth(560)
	frame:SetHeight(540)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 },
	})
	tinsert(UISpecialFrames, "HemsworkPlatesConfig")

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -16)
	title:SetText("HemsworkPlates")

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)

	local panels, tabs = {}, {}
	local defs = {
		{ T("General"), BuildGeneral },
		{ T("Texto"), BuildText },
		{ T("Colores"), BuildColors },
		{ T("Extras"), BuildExtras },
		{ "PvP", BuildPvP },
		{ T("Totems"), BuildTotems },
		{ T("Debuffs"), BuildDebuffs },
		{ "GCD", BuildGCD },
	}
	local function Select(i)
		for j, pnl in ipairs(panels) do
			if j == i then pnl:Show(); tabs[j]:Disable() else pnl:Hide(); tabs[j]:Enable() end
		end
	end
	for i, d in ipairs(defs) do
		local t = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		t:SetWidth(60)
		t:SetHeight(22)
		t:SetPoint("TOPLEFT", 20 + (i - 1) * 64, -44)
		t:SetText(d[1])
		t:SetScript("OnClick", function() Select(i) end)
		tabs[i] = t

		local pnl = CreateFrame("Frame", nil, frame)
		pnl:SetPoint("TOPLEFT", 16, -74)
		pnl:SetPoint("BOTTOMRIGHT", -16, 44)
		panels[i] = pnl
		d[2](pnl)
	end

	local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	reset:SetWidth(130)
	reset:SetHeight(22)
	reset:SetPoint("BOTTOMLEFT", 20, 16)
	reset:SetText(T("Restablecer todo"))
	reset:SetScript("OnClick", function()
		SP.Reset()
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateClassicState()
	end)

	local prof = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	prof:SetWidth(110)
	prof:SetHeight(22)
	prof:SetPoint("BOTTOMLEFT", 156, 16)
	prof:SetText(T("Perfiles"))
	prof:SetScript("OnClick", function() SP.ShowProfiles() end)

	local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("BOTTOMRIGHT", -22, 20)
	hint:SetText(T("Cambios en vivo"))

	frame:SetScript("OnShow", function()
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateClassicState()
	end)
	Select(1)
	-- Un frame nuevo nace visible: se oculta para que el primer /hms lo abra
	frame:Hide()
end

function SP.ToggleConfig()
	if not SP.cfg then return end
	if not frame then BuildFrame() end
	if frame:IsShown() then frame:Hide() else frame:Show() end
end
