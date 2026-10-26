--------------------------------------------------------------------
-- HemsworkPlates - Panel de configuracion (/hms)
-- Ventana oscura con menu lateral; cada seccion se monta con un
-- "layout" de dos columnas con bloques de titulo y desplazamiento.
--------------------------------------------------------------------
local addonName, SP = ...
local function T(s) return SP.T(s) end

local frame
local widgets = {}
local uid = 0
local function UName() uid = uid + 1; return "HemsworkPlatesW" .. uid end
local UpdateDeps
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
	UpdateDeps()
end

------------------------------ ESTILO -----------------------------
local FLAT = "Interface\\Buttons\\WHITE8X8"
local ACCENT = { 1, 0.78, 0.2 }          -- dorado del castbar
local BG = { 0.06, 0.06, 0.07, 0.96 }
local PANEL = { 0.1, 0.1, 0.11, 1 }
local EDGE = { 0.22, 0.22, 0.25, 1 }

local function Skin(f, bg, edge)
	f:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 })
	bg, edge = bg or BG, edge or EDGE
	f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
	f:SetBackdropBorderColor(edge[1], edge[2], edge[3], edge[4])
end
SP.SkinFrame = Skin

-- Boton plano oscuro (sustituye a los botones rojos de Blizzard)
local function FlatButton(parent, w, h, text)
	local b = CreateFrame("Button", nil, parent)
	b:SetWidth(w)
	b:SetHeight(h)
	Skin(b, PANEL)
	b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	b.text:SetPoint("CENTER", 0, 0)
	b.text:SetText(text or "")
	function b:SetText(t) self.text:SetText(t) end
	function b:GetFontString() return self.text end
	b:SetScript("OnEnter", function(self) if self:IsEnabled() == 1 or self:IsEnabled() == true then self:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1) end end)
	b:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(EDGE[1], EDGE[2], EDGE[3], EDGE[4]) end)
	return b
end
SP.FlatButton = FlatButton

-- Tooltip al pasar el raton
local function Tip(f, text)
	if not text then return end
	f:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(T(text), 1, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	f:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Opciones que dependen de otra (se ven grises si no aplican)
local deps = {}
local function Dep(w, cond)
	if w then deps[#deps + 1] = { w, cond } end
	return w
end
local function SetActive(w, on)
	w:SetAlpha(on and 1 or 0.35)
	if w.Enable and w.Disable then
		if on then w:Enable() else w:Disable() end
	else
		w:EnableMouse(on)
	end
	if w.box then w.box:EnableMouse(on) end
end
function UpdateDeps()
	for _, d in ipairs(deps) do SetActive(d[1], d[2]() and true or false) end
end
local function IsClassicStyle() return SP.cfg.shape == "classic" or SP.cfg.shape == "old" end
local function NotClassic() return not IsClassicStyle() end
local function On(key) return function() return SP.cfg[key] end end

------------------------------ WIDGETS -----------------------------
local function MakeCheck(parent, x, y, label, key, tip)
	local cb = CreateFrame("CheckButton", UName(), parent, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", x - 4, y + 2)
	_G[cb:GetName() .. "Text"]:SetText(label)
	_G[cb:GetName() .. "Text"]:SetWidth(210)
	_G[cb:GetName() .. "Text"]:SetJustifyH("LEFT")
	cb:SetScript("OnClick", function(self)
		SP.cfg[key] = self:GetChecked() and true or false
		Apply()
	end)
	function cb:Refresh() self:SetChecked(SP.cfg[key]) end
	Tip(cb, tip)
	widgets[#widgets + 1] = cb
	return cb
end

-- Deslizador con casilla para escribir el valor exacto
local function MakeSlider(parent, x, y, label, key, minV, maxV, step, fmt, tip)
	fmt = fmt or "%d"
	local name = UName()
	local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	s:SetPoint("TOPLEFT", x + 2, y - 16)
	s:SetWidth(168)
	s:SetHeight(16)
	s:SetMinMaxValues(minV, maxV)
	s:SetValueStep(step)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
	local text = _G[name .. "Text"]
	text:ClearAllPoints()
	text:SetPoint("BOTTOMLEFT", s, "TOPLEFT", 0, 2)
	text:SetFontObject("GameFontNormalSmall")
	text:SetText(label)

	local box = CreateFrame("EditBox", UName(), parent, "InputBoxTemplate")
	box:SetWidth(40)
	box:SetHeight(18)
	box:SetPoint("LEFT", s, "RIGHT", 12, 0)
	box:SetAutoFocus(false)
	box:SetFontObject("GameFontHighlightSmall")
	box:SetJustifyH("CENTER")
	s.box = box

	local function Quant(v)
		v = tonumber(v) or minV
		if v < minV then v = minV elseif v > maxV then v = maxV end
		return math.floor(v / step + 0.5) * step
	end
	s:SetScript("OnValueChanged", function(self, v)
		v = Quant(v)
		if not box:HasFocus() then box:SetText(string.format(fmt, v)) end
		if self.loading then return end
		SP.cfg[key] = v
		Apply()
	end)
	box:SetScript("OnEnterPressed", function(self)
		local v = Quant(self:GetText())
		self:ClearFocus()
		s:SetValue(v)
		self:SetText(string.format(fmt, v))
	end)
	box:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		self:SetText(string.format(fmt, SP.cfg[key] or minV))
	end)
	function s:Refresh()
		self.loading = true
		self:SetValue(SP.cfg[key])
		box:SetText(string.format(fmt, Quant(SP.cfg[key])))
		self.loading = false
	end
	Tip(s, tip)
	widgets[#widgets + 1] = s
	return s
end

local function MakeSwatch(parent, x, y, label, getter, setter, tip)
	local b = CreateFrame("Button", UName(), parent)
	b:SetWidth(18)
	b:SetHeight(18)
	b:SetPoint("TOPLEFT", x, y - 2)
	local edge = b:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints()
	edge:SetTexture(0, 0, 0, 1)
	local tex = b:CreateTexture(nil, "ARTWORK")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fs:SetPoint("LEFT", b, "RIGHT", 8, 0)
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
	Tip(b, tip)
	widgets[#widgets + 1] = b
	return b
end

local function CfgColor(key)
	return function() local c = SP.cfg[key]; return c[1], c[2], c[3] end,
	       function(r, g, b) local c = SP.cfg[key]; c[1], c[2], c[3] = r, g, b end
end
local function MakeCfgSwatch(parent, x, y, label, key, tip)
	local g, s = CfgColor(key)
	return MakeSwatch(parent, x, y, label, g, s, tip)
end

-- Lista desplegable propia (con scroll de rueda)
local ROWS = 12
local listFrame
local function ShowList(anchor, opts, current, onPick)
	if not listFrame then
		listFrame = CreateFrame("Frame", "HemsworkPlatesList", UIParent)
		listFrame:SetFrameStrata("TOOLTIP")
		Skin(listFrame, { 0.08, 0.08, 0.09, 0.98 })
		listFrame:EnableMouse(true)
		listFrame:EnableMouseWheel(true)
		listFrame.rows = {}
		for i = 1, ROWS do
			local r = CreateFrame("Button", nil, listFrame)
			r:SetHeight(18)
			r:SetPoint("TOPLEFT", 2, -2 - (i - 1) * 18)
			r:SetPoint("TOPRIGHT", -2, -2 - (i - 1) * 18)
			r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			r.text:SetPoint("LEFT", 6, 0)
			local hl = r:CreateTexture(nil, "HIGHLIGHT")
			hl:SetAllPoints()
			hl:SetTexture(1, 1, 1, 0.12)
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
					if o[2] == self.current then r.text:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3]) else r.text:SetTextColor(1, 1, 1) end
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

local function MakeDropdown(parent, x, y, label, key, getOptions, tip)
	local b = FlatButton(parent, 210, 20, "")
	b:SetPoint("TOPLEFT", x, y - 16)
	b.text:ClearAllPoints()
	b.text:SetPoint("LEFT", 8, 0)
	b.text:SetPoint("RIGHT", -18, 0)
	b.text:SetJustifyH("LEFT")
	local arrow = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	arrow:SetPoint("RIGHT", -6, 0)
	arrow:SetText("v")
	local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	lbl:SetPoint("BOTTOMLEFT", b, "TOPLEFT", 0, 3)
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
	Tip(b, tip)
	widgets[#widgets + 1] = b
	return b
end

local function MakeEditBox(parent, x, y, label, key, tip)
	local e = CreateFrame("EditBox", UName(), parent, "InputBoxTemplate")
	e:SetWidth(204)
	e:SetHeight(20)
	e:SetPoint("TOPLEFT", x + 6, y - 16)
	e:SetAutoFocus(false)
	e:SetFontObject("GameFontHighlightSmall")
	local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	lbl:SetPoint("BOTTOMLEFT", e, "TOPLEFT", -6, 3)
	lbl:SetText(label)
	e:SetScript("OnEnterPressed", function(self)
		SP.cfg[key] = self:GetText()
		self:ClearFocus()
		Apply()
	end)
	e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	function e:Refresh() self:SetText(SP.cfg[key] or ""); self:SetCursorPosition(0) end
	Tip(e, tip)
	widgets[#widgets + 1] = e
	return e
end

------------------------------ LAYOUT ------------------------------
-- Coloca los controles en dos columnas, fila a fila. Header() abre un bloque
-- con titulo y linea separadora a todo el ancho.
local COLX = { 14, 274 }
local SIZES = { check = 26, slider = 46, dropdown = 44, color = 26, edit = 44, button = 30 }

local function NewLayout(page)
	local L = { page = page, y = -10, col = 1, rowH = 0 }
	function L:EndRow()
		if self.col == 2 then
			self.y = self.y - self.rowH
			self.col, self.rowH = 1, 0
		end
	end
	function L:Next(kind)
		local h = SIZES[kind] or 30
		local x = COLX[self.col]
		local y = self.y
		if self.col == 1 then
			self.col, self.rowH = 2, h
		else
			self.rowH = math.max(self.rowH, h)
			self.y = self.y - self.rowH
			self.col, self.rowH = 1, 0
		end
		return x, y
	end
	function L:Header(text)
		self:EndRow()
		if self.y < -10 then self.y = self.y - 8 end
		local fs = self.page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		fs:SetPoint("TOPLEFT", 12, self.y)
		fs:SetText(text)
		fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
		local line = self.page:CreateTexture(nil, "ARTWORK")
		line:SetTexture(EDGE[1], EDGE[2], EDGE[3], 1)
		line:SetHeight(1)
		line:SetPoint("TOPLEFT", 12, self.y - 17)
		line:SetPoint("TOPRIGHT", -12, self.y - 17)
		self.y = self.y - 26
	end
	function L:Note(text)
		self:EndRow()
		local fs = self.page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		fs:SetPoint("TOPLEFT", 14, self.y)
		fs:SetWidth(500)
		fs:SetJustifyH("LEFT")
		fs:SetText(text)
		self.y = self.y - math.max(16, fs:GetStringHeight() + 6)
	end
	function L:Check(label, key, tip) local x, y = self:Next("check"); return MakeCheck(self.page, x, y, label, key, tip) end
	function L:Slider(label, key, a, b, step, fmt, tip) local x, y = self:Next("slider"); return MakeSlider(self.page, x, y, label, key, a, b, step, fmt, tip) end
	function L:Dropdown(label, key, opts, tip) local x, y = self:Next("dropdown"); return MakeDropdown(self.page, x, y, label, key, opts, tip) end
	function L:Color(label, key, tip) local x, y = self:Next("color"); return MakeCfgSwatch(self.page, x, y, label, key, tip) end
	function L:Edit(label, key, tip) local x, y = self:Next("edit"); return MakeEditBox(self.page, x, y, label, key, tip) end
	function L:Button(text, onClick, tip)
		local x, y = self:Next("button")
		local b = FlatButton(self.page, 210, 22, text)
		b:SetPoint("TOPLEFT", x, y - 4)
		b:SetScript("OnClick", onClick)
		Tip(b, tip)
		return b
	end
	function L:Height() self:EndRow(); return -self.y + 12 end
	return L
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

------------------------------ SECCIONES ----------------------------
local CLASS_ORDER = { "WARRIOR", "PALADIN", "DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK" }

local function BuildLook(L)
	L:Header(T("Estilo"))
	L:Dropdown(T("Forma de las barras"), "shape", ShapeOptions)
	L:Dropdown(T("Textura de la barra"), "texture", TextureOptions)
	L:Check(T("Pixel perfect (bordes nitidos)"), "pixelPerfect",
		"Ajusta tamanos y posiciones a pixeles exactos de tu pantalla para que los bordes se vean nitidos.")
	Dep(L:Slider(T("Grosor del borde"), "borderSize", 0, 4, 0.5, "%.1f", "Solo en los estilos Cuadrada y Redonda."), NotClassic)

	L:Header(T("Tamano"))
	L:Slider(T("Ancho"), "width", 60, 200, 1)
	L:Slider(T("Alto de barra"), "height", 4, 24, 1)
	L:Slider(T("Escala"), "scale", 0.5, 2, 0.05, "%.2f")
	L:Slider(T("Opacidad sin target"), "nonTargetAlpha", 0.2, 1, 0.05, "%.2f",
		"Opacidad de las placas que no son tu target (solo cuando tienes un target).")

	L:Header(T("Posicion"))
	L:Slider(T("Mover horizontal (X)"), "offsetX", -100, 100, 1)
	L:Slider(T("Mover vertical (Y)"), "offsetY", -100, 100, 1)

	L:Header(T("Apilado"))
	L:Check(T("Apilar placas (evitar solapamiento)"), "stacking",
		"Separa las placas que se solapan. El juego ya las separa por su cuenta; activalo solo si lo prefieres.")
	L:EndRow()
	Dep(L:Slider(T("Separacion"), "stackGap", 0, 10, 1), On("stacking"))
	Dep(L:Slider(T("Velocidad de apilado"), "stackSpeed", 2, 30, 1), On("stacking"))
end

local function BuildCast(L)
	local cast = On("showCast")
	L:Header(T("Castbar"))
	L:Check(T("Mostrar cast bar"), "showCast")
	Dep(L:Check(T("Icono del hechizo"), "showCastIcon"), cast)
	Dep(L:Check(T("Nombre del hechizo en el cast"), "showCastText"), cast)
	Dep(L:Check(T("Tiempo restante del cast"), "showCastTime"), cast)
	Dep(L:Slider(T("Alto cast bar"), "castHeight", 4, 24, 1), cast)
	Dep(L:Slider(T("Tamano texto del cast"), "castFontSize", 5, 16, 1), cast)
	Dep(L:Slider(T("Tamano icono cast"), "castIconSize", 8, 30, 1, nil, "Solo en los estilos Cuadrada y Redonda."),
		function() return SP.cfg.showCast and NotClassic() end)

	L:Header(T("Interrupciones"))
	Dep(L:Slider(T("Tiempo de 'Interrupted' (s)"), "castInterruptHold", 0.3, 3, 0.1, "%.1f",
		"Cuanto tiempo se queda la barra parada en rojo al cortar un cast."), cast)
	Dep(L:Check(T("Mostrar quien corto el cast"), "showInterrupter"), cast)
	L:Check(T("Estilo de cast en target y focus"), "tfCast",
		"Aplica el rojo de 'Interrupted' y el color de no interrumpible a los castbars de los marcos de target y focus.")

	L:Header(T("Colores del cast"))
	L:Color(T("Color de cast bar"), "castColor")
	L:Color(T("Cast no interrumpible"), "castNoInterruptColor")
	L:Color(T("Cast interrumpido"), "castInterruptColor")
end

local function BuildTextPage(L)
	L:Header(T("Fuente"))
	L:Dropdown(T("Fuente"), "font", FontOptions)
	L:Dropdown(T("Contorno"), "fontOutline", OutlineOptions)
	L:Edit(T("Ruta de fuente personalizada (Enter)"), "font", "Ruta de un archivo .ttf, por ejemplo Interface\\AddOns\\MiFuente\\fuente.ttf")
	L:Slider(T("Tamano de texto"), "fontSize", 6, 20, 1)
	L:Color(T("Color del texto"), "textColor")

	L:Header(T("Nombre y nivel"))
	L:Check(T("Mostrar nombre"), "showName")
	L:Check(T("Mostrar nivel"), "showLevel")
	Dep(L:Slider(T("Mover nombre X"), "nameX", -60, 60, 1, nil, "Con 0 el nombre queda en el centro exacto de la barra."), On("showName"))
	Dep(L:Slider(T("Mover nombre Y"), "nameY", -40, 40, 1), On("showName"))
	Dep(L:Slider(T("Separacion del nivel"), "levelOffset", 0, 30, 1, nil, "Solo en los estilos Cuadrada y Redonda."),
		function() return SP.cfg.showLevel and NotClassic() end)

	L:Header(T("Texto de vida"))
	L:Check(T("Mostrar texto de vida"), "showHealthText")
	Dep(L:Dropdown(T("Formato del texto de vida"), "healthFormat", HealthFormatOptions), On("showHealthText"))
	Dep(L:Check(T("Ocultar texto con vida al maximo"), "healthHideMax"), On("showHealthText"))

	L:Header(T("Idioma / Language"))
	L:Dropdown(T("Idioma / Language"), "language", LanguageOptions, "Automatico: espanol si tu cliente esta en espanol, ingles en cualquier otro.")
end

local function BuildColorsPage(L)
	L:Header(T("Color de clase"))
	L:Check(T("Color de clase en jugadores"), "classColorPlayers")
	L:EndRow()
	for _, class in ipairs(CLASS_ORDER) do
		local x, y = L:Next("color")
		local sw = MakeSwatch(L.page, x, y, (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class]) or class,
			function() local c = SP.cfg.classColors[class]; return c[1], c[2], c[3] end,
			function(r, g, b) local c = SP.cfg.classColors[class]; c[1], c[2], c[3] = r, g, b end)
		local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
		if c then sw.label:SetTextColor(c.r, c.g, c.b) end
		Dep(sw, On("classColorPlayers"))
	end

	L:Header(T("Reaccion"))
	L:Color(T("Hostil"), "hostileColor")
	L:Color(T("Neutral"), "neutralColor")
	L:Color(T("Amistoso"), "friendlyColor")
	L:Color(T("Tapeado por otro"), "tappedColor")

	L:Header(T("Barra"))
	L:Color(T("Fondo de barra"), "bgColor")
	Dep(L:Color(T("Borde"), "borderColor", "Solo en los estilos Cuadrada y Redonda."), NotClassic)
	Dep(L:Color(T("Borde del target"), "targetBorderColor", "Solo en los estilos Cuadrada y Redonda."), NotClassic)
end

local function BuildHighlight(L)
	L:Header(T("Brillo en el target"))
	L:Check(T("Brillo en el target"), "targetGlow")
	Dep(L:Color(T("Color brillo target"), "targetGlowColor"), On("targetGlow"))
	Dep(L:Slider(T("Intensidad brillo target"), "targetGlowAlpha", 0.1, 1, 0.05, "%.2f"), On("targetGlow"))

	L:Header(T("Brillo al pasar el raton"))
	L:Check(T("Brillo al pasar el raton"), "hoverGlow")
	Dep(L:Color(T("Color brillo raton"), "hoverGlowColor"), On("hoverGlow"))
	Dep(L:Slider(T("Intensidad brillo raton"), "hoverGlowAlpha", 0.1, 1, 0.05, "%.2f"), On("hoverGlow"))
	Dep(L:Slider(T("Tamano del brillo"), "glowSize", 2, 16, 1), function() return SP.cfg.targetGlow or SP.cfg.hoverGlow end)

	L:Header(T("Tu target"))
	L:Slider(T("Escala del target"), "targetScale", 0.8, 2, 0.05, "%.2f")
	L:Check(T("Mantener target en pantalla"), "clampTarget",
		"Si la placa de tu target se sale por arriba de la pantalla, se queda pegada al borde superior.")
	Dep(L:Slider(T("Margen superior"), "clampMargin", 0, 150, 5), On("clampTarget"))
end

local function BuildArena(L)
	local ids = function() return SP.cfg.arenaIDs or SP.cfg.partyIDs end
	L:Header(T("Numeros de arena"))
	L:Check(T("Numeros de arena (enemigos)"), "arenaIDs", "Muestra 1-5 en cada rival de arena (en rojo).")
	L:Check(T("Numeros de grupo (aliados)"), "partyIDs", "Muestra el numero de cada companero de arena (en verde).")
	Dep(L:Dropdown(T("Posicion del numero de arena"), "arenaIDPos", ArenaIDPosOptions), ids)

	L:Header(T("Aliados"))
	L:Check(T("Aliados con color de clase"), "friendlyClassColor",
		"Desmarcado: tus aliados salen en un color fijo (azul) para no confundirlos con los enemigos.")
	Dep(L:Color(T("Color de jugadores aliados"), "friendlyPlayerColor"), function() return not SP.cfg.friendlyClassColor end)
	L:Slider(T("Tamano de aliados"), "friendlyScale", 0.5, 1.5, 0.05, "%.2f")

	L:Header(T("Aliados solo con nombre"))
	L:Note(T("Las placas amistosas muestran solo el nombre, sin barra, en las zonas que elijas."))
	L:Dropdown(T("Mundo abierto"), "barlessWorld", BarlessOptions)
	L:Dropdown(T("Mazmorras y bandas"), "barlessPvE", BarlessOptions)
	L:Dropdown(T("Campos de batalla"), "barlessBG", BarlessOptions)
	L:Dropdown(T("Arenas"), "barlessArena", BarlessOptions)
	L:Check(T("Barras normales en tu target"), "barlessExcludeTarget")
end

-- Debuffs importantes (integrados desde la WeakAura)
local CAT_LABELS = {
	immunities = "Inmunidades", cc = "Control (CC)", silence = "Silencios", roots = "Raices",
	disarms = "Desarmes", defensives = "Defensivos", offensives = "Ofensivos", others = "Otros",
}

local function DebuffPosOptions()
	return { { T("A la derecha"), "right" }, { T("A la izquierda"), "left" } }
end

local function BuildDebuffsPage(L)
	local on = On("debuffs")
	L:Header(T("Debuffs importantes"))
	L:Check(T("Mostrar debuffs importantes"), "debuffs",
		"Muestra en cada placa enemiga el aura mas importante segun su categoria y prioridad.")
	Dep(L:Check(T("Solo en enemigos"), "debuffEnemyOnly"), on)
	Dep(L:Check(T("Solo en arena"), "debuffArenaOnly"), on)
	Dep(L:Check(T("Tiempo restante en el icono"), "debuffTimer"), on)
	Dep(L:Slider(T("Tamano del icono"), "debuffSize", 16, 60, 1), on)
	Dep(L:Dropdown(T("Posicion"), "debuffPos", DebuffPosOptions), on)
	Dep(L:Check(T("Bloqueos de interrupcion (Pummel, Kick...)"), "debuffLockouts",
		"Pummel, Shield Bash, Kick, etc. no dejan aura: se detectan en el registro de combate y se muestran como silencio."), on)

	L:Header(T("Categorias (por prioridad)"))
	for i, cat in ipairs(SP.DEBUFF_CATS or {}) do
		local x, y = L:Next("check")
		local cb = CreateFrame("CheckButton", UName(), L.page, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", x - 4, y + 2)
		_G[cb:GetName() .. "Text"]:SetText(i .. ". " .. T(CAT_LABELS[cat] or cat))
		cb:SetScript("OnClick", function(self)
			SP.cfg.debuffCats[cat] = self:GetChecked() and true or false
			Apply()
		end)
		function cb:Refresh() self:SetChecked(SP.cfg.debuffCats[cat] ~= false) end
		widgets[#widgets + 1] = cb
		Dep(cb, on)
	end
end

local function GCDPosOptions()
	return { { T("A la izquierda"), "left" }, { T("A la derecha"), "right" } }
end

local function BuildGCDPage(L)
	local on = On("gcd")
	L:Header(T("GCD de arena"))
	L:Note(T("Muestra el ultimo hechizo de cada rival de arena con un barrido que dura su GCD (clase, haste y procs instantaneos). Basado en NameplateArenaGCDs."))
	L:Check(T("Mostrar GCD de enemigos de arena"), "gcd")
	Dep(L:Dropdown(T("Posicion"), "gcdPos", GCDPosOptions), on)
	Dep(L:Check(T("Tiempo restante en el icono"), "gcdTimer"), on)
	Dep(L:Slider(T("Tamano del icono"), "gcdSize", 14, 64, 1), on)
	Dep(L:Check(T("Invertir el barrido"), "gcdReverse"), on)
	Dep(L:Check(T("Ocultar el barrido"), "gcdHideSweep"), on)
	Dep(L:Slider(T("Opacidad del barrido"), "gcdAlpha", 0, 1, 0.05, "%.2f"), function() return SP.cfg.gcd and not SP.cfg.gcdHideSweep end)
	Dep(L:Button(T("Probar en mi target (15 s)"), function() if SP.TestGCD then SP.TestGCD() end end), on)
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

-- Seccion sin desplazamiento propio: la lista de totems tiene su scroll
local function BuildTotemsPage(L)
	L:Header(T("Totems"))
	L:Check(T("Totems como icono"), "totemIcons")
	Dep(L:Slider(T("Tamano icono totem"), "totemSize", 12, 48, 1), On("totemIcons"))
	Dep(L:Check(T("Ocultar totems aliados"), "totemHideFriendly"), On("totemIcons"))
	L:Header(T("Totem                                              Modo             Icono propio (ruta o ID de hechizo + Enter)"))
	local p = L.page

	local sf = CreateFrame("ScrollFrame", UName(), p, "UIPanelScrollFrameTemplate")
	sf:SetPoint("TOPLEFT", 8, L.y - 2)
	sf:SetPoint("BOTTOMRIGHT", -28, 8)
	local list = CreateFrame("Frame", nil, sf)
	list:SetWidth(470)
	sf:SetScrollChild(list)

	local y = 0
	for _, grp in ipairs(SP.TOTEMS) do
		local col = ELEMENT_COLOR[grp[1]]
		for _, id in ipairs(grp[2]) do
			local spellName = GetSpellInfo(id)
			if spellName then
				local row = CreateFrame("Frame", nil, list)
				row:SetWidth(470)
				row:SetHeight(24)
				row:SetPoint("TOPLEFT", 0, -y)
				y = y + 26

				local ico = row:CreateTexture(nil, "ARTWORK")
				ico:SetWidth(20)
				ico:SetHeight(20)
				ico:SetPoint("LEFT", 4, 0)
				ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)

				local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				fs:SetPoint("LEFT", 30, 0)
				fs:SetWidth(150)
				fs:SetJustifyH("LEFT")
				fs:SetText(spellName)
				fs:SetTextColor(col[1], col[2], col[3])

				local btn = FlatButton(row, 72, 20, "")
				btn:SetPoint("LEFT", 184, 0)

				local eb = CreateFrame("EditBox", UName(), row, "InputBoxTemplate")
				eb:SetWidth(180)
				eb:SetHeight(20)
				eb:SetPoint("LEFT", 270, 0)
				eb:SetAutoFocus(false)
				eb:SetFontObject("GameFontHighlightSmall")

				function row:Refresh()
					local t = SP.cfg.totems[id]
					local m = (t and t.mode) or 1
					local md = MODES[m]
					btn:SetText(T(md[1]))
					btn.text:SetTextColor(md[2], md[3], md[4])
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
		Skin(f)
		tinsert(UISpecialFrames, "HemsworkPlatesProfiles")

		local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOP", 0, -14)
		title:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
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
			local b = FlatButton(f, 110, 22, text)
			b:SetPoint("BOTTOMLEFT", x, 12)
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
				UpdateDeps()
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

local function BuildProfilesPage(L)
	L:Header(T("Perfiles"))
	L:Note(T("Exporta tu configuracion como un texto para copiarla a otro personaje o cuenta, o importa la de otra persona."))
	L:Button(T("Importar / exportar perfil"), function() SP.ShowProfiles() end)
	L:EndRow()
	L:Header(T("Restablecer"))
	L:Note(T("Vuelve todas las opciones a sus valores por defecto."))
	L:Button(T("Restablecer todo"), function()
		SP.Reset()
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateDeps()
	end)
end

local SECTIONS = {
	{ "Aspecto", BuildLook },
	{ "Castbar", BuildCast },
	{ "Texto", BuildTextPage },
	{ "Colores", BuildColorsPage },
	{ "Resaltado", BuildHighlight },
	{ "Arena", BuildArena },
	{ "Debuffs", BuildDebuffsPage },
	{ "GCD", BuildGCDPage },
	{ "Totems", BuildTotemsPage, true }, -- true = sin desplazamiento (la lista tiene el suyo)
	{ "Perfiles", BuildProfilesPage },
}

local SIDE_W, W, H = 150, 720, 520

local function BuildFrame()
	frame = CreateFrame("Frame", "HemsworkPlatesConfig", UIParent)
	frame:SetWidth(W)
	frame:SetHeight(H)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	Skin(frame)
	tinsert(UISpecialFrames, "HemsworkPlatesConfig")

	-- Barra de titulo (se arrastra desde aqui)
	local bar = CreateFrame("Frame", nil, frame)
	bar:SetPoint("TOPLEFT", 1, -1)
	bar:SetPoint("TOPRIGHT", -1, -1)
	bar:SetHeight(30)
	local barBg = bar:CreateTexture(nil, "BACKGROUND")
	barBg:SetAllPoints()
	barBg:SetTexture(0.03, 0.03, 0.035, 1)
	local accent = bar:CreateTexture(nil, "ARTWORK")
	accent:SetPoint("BOTTOMLEFT")
	accent:SetPoint("BOTTOMRIGHT")
	accent:SetHeight(1)
	accent:SetTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.8)
	bar:EnableMouse(true)
	bar:RegisterForDrag("LeftButton")
	bar:SetScript("OnDragStart", function() frame:StartMoving() end)
	bar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

	local title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("LEFT", 12, 0)
	title:SetText("Hemswork|cffffffffPlates|r")
	title:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
	local ver = bar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	ver:SetPoint("LEFT", title, "RIGHT", 8, -1)
	ver:SetText((GetAddOnMetadata and GetAddOnMetadata(addonName, "Version")) or "")
	local hint = bar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("RIGHT", -36, 0)
	hint:SetText(T("Cambios en vivo"))

	local close = CreateFrame("Button", nil, bar, "UIPanelCloseButton")
	close:SetPoint("RIGHT", 2, 0)
	close:SetScript("OnClick", function() frame:Hide() end)

	-- Menu lateral
	local side = CreateFrame("Frame", nil, frame)
	side:SetPoint("TOPLEFT", 1, -31)
	side:SetPoint("BOTTOMLEFT", 1, 1)
	side:SetWidth(SIDE_W)
	local sideBg = side:CreateTexture(nil, "BACKGROUND")
	sideBg:SetAllPoints()
	sideBg:SetTexture(0.045, 0.045, 0.05, 1)
	local sideLine = side:CreateTexture(nil, "ARTWORK")
	sideLine:SetPoint("TOPRIGHT")
	sideLine:SetPoint("BOTTOMRIGHT")
	sideLine:SetWidth(1)
	sideLine:SetTexture(EDGE[1], EDGE[2], EDGE[3], 1)

	-- Zona de contenido
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", SIDE_W + 2, -32)
	content:SetPoint("BOTTOMRIGHT", -2, 2)

	local pages, buttons = {}, {}
	local function Select(i)
		for j, pg in ipairs(pages) do
			local b = buttons[j]
			if j == i then
				pg:Show()
				b.mark:Show()
				b.bg:SetTexture(1, 1, 1, 0.07)
				b.text:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
			else
				pg:Hide()
				b.mark:Hide()
				b.bg:SetTexture(0, 0, 0, 0)
				b.text:SetTextColor(0.85, 0.85, 0.85)
			end
		end
		frame.selected = i
	end

	for i, def in ipairs(SECTIONS) do
		local b = CreateFrame("Button", nil, side)
		b:SetHeight(28)
		b:SetPoint("TOPLEFT", 0, -8 - (i - 1) * 30)
		b:SetPoint("TOPRIGHT", -1, -8 - (i - 1) * 30)
		b.bg = b:CreateTexture(nil, "BACKGROUND")
		b.bg:SetAllPoints()
		b.mark = b:CreateTexture(nil, "ARTWORK")
		b.mark:SetPoint("TOPLEFT")
		b.mark:SetPoint("BOTTOMLEFT")
		b.mark:SetWidth(3)
		b.mark:SetTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		b.text:SetPoint("LEFT", 16, 0)
		b.text:SetText(T(def[1]))
		local hl = b:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetTexture(1, 1, 1, 0.05)
		b:SetScript("OnClick", function() Select(i) end)
		buttons[i] = b

		-- Pagina: con desplazamiento (salvo Totems, que lleva su propia lista)
		local pg = CreateFrame("Frame", nil, content)
		pg:SetAllPoints(content)
		local page
		if def[3] then
			page = pg
			def[2](NewLayout(page))
		else
			local sf = CreateFrame("ScrollFrame", UName(), pg, "UIPanelScrollFrameTemplate")
			sf:SetPoint("TOPLEFT", 0, -4)
			sf:SetPoint("BOTTOMRIGHT", -26, 4)
			page = CreateFrame("Frame", nil, sf)
			page:SetWidth(W - SIDE_W - 30)
			sf:SetScrollChild(page)
			local L = NewLayout(page)
			def[2](L)
			page:SetHeight(L:Height())
			-- Sin barra de scroll si todo cabe
			local bar = _G[sf:GetName() .. "ScrollBar"]
			sf:SetScript("OnShow", function()
				if bar then
					if page:GetHeight() <= sf:GetHeight() then bar:Hide() else bar:Show() end
				end
			end)
		end
		pages[i] = pg
	end

	frame:SetScript("OnShow", function()
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateDeps()
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
