--------------------------------------------------------------------
-- HemsworkPlates - panel de opciones (/hms)
-- Ventana oscura con menu a la izquierda; cada seccion se monta con
-- un layout de dos columnas
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
	-- el idioma pide /reload porque los textos del panel se crean una sola vez
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

-- boton plano oscuro en vez de los rojos de Blizzard
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

-- opciones que dependen de otra, salen en gris si no aplican
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
local function On(key) return function() return SP.cfg[key] end end

------------------------------ WIDGETS -----------------------------
-- todas las opciones son filas: el nombre a la izquierda y el control a la
-- derecha. Cada fila tiene su Refresh y su Enable/Disable para las dependencias
local CW = 540   -- ancho de la pagina
local ROW_H = 26

-- tocar algo a mano deja de ser "el perfil X tal cual"
local RefreshCards
local function Changed()
	SP.cfg.activePreset = nil
	Apply()
	if RefreshCards then RefreshCards() end
end

local function NewRow(parent, y)
	local r = CreateFrame("Frame", nil, parent)
	r:SetPoint("TOPLEFT", 8, y)
	r:SetPoint("TOPRIGHT", -8, y)
	r:SetHeight(ROW_H)
	local line = r:CreateTexture(nil, "BACKGROUND")
	line:SetPoint("BOTTOMLEFT")
	line:SetPoint("BOTTOMRIGHT")
	line:SetHeight(1)
	line:SetTexture(EDGE[1], EDGE[2], EDGE[3], 0.45)
	r.label = r:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	r.label:SetPoint("LEFT", 8, 0)
	r.label:SetWidth(270)
	r.label:SetJustifyH("LEFT")
	return r
end

-- interruptor encendido / apagado; se pulsa en cualquier parte de la fila
local function MakeToggle(parent, y, label, get, set, tip)
	local r = NewRow(parent, y)
	r.label:SetText(label)
	local b = CreateFrame("Button", nil, r)
	b:SetAllPoints(r)
	local hl = b:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetTexture(1, 1, 1, 0.04)
	local track = b:CreateTexture(nil, "ARTWORK")
	track:SetTexture(FLAT)
	track:SetWidth(28)
	track:SetHeight(14)
	track:SetPoint("RIGHT", -8, 0)
	local knob = b:CreateTexture(nil, "OVERLAY")
	knob:SetTexture(FLAT)
	knob:SetWidth(10)
	knob:SetHeight(10)
	function r:Refresh()
		knob:ClearAllPoints()
		if get() then
			track:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
			knob:SetVertexColor(0.08, 0.08, 0.09, 1)
			knob:SetPoint("RIGHT", track, "RIGHT", -2, 0)
		else
			track:SetVertexColor(0.25, 0.25, 0.28, 1)
			knob:SetVertexColor(0.7, 0.7, 0.7, 1)
			knob:SetPoint("LEFT", track, "LEFT", 2, 0)
		end
	end
	b:SetScript("OnClick", function()
		set(not get())
		r:Refresh()
		Changed()
	end)
	function r:Enable() b:Enable() end
	function r:Disable() b:Disable() end
	Tip(b, tip)
	widgets[#widgets + 1] = r
	return r
end

local function MakeCheck(parent, y, label, key, tip)
	return MakeToggle(parent, y, label, function() return SP.cfg[key] end,
		function(v) SP.cfg[key] = v and true or false end, tip)
end

-- deslizador con su valor al lado (se puede escribir el numero exacto)
local function MakeSlider(parent, y, label, key, minV, maxV, step, fmt, tip)
	fmt = fmt or "%d"
	local pct = fmt == "pct" -- valor 0-1 mostrado como porcentaje
	local function Disp(v)
		if pct then return string.format("%d%%", math.floor(v * 100 + 0.5)) end
		return string.format(fmt, v)
	end
	local r = NewRow(parent, y)
	r.label:SetText(label)
	local name = UName()
	local s = CreateFrame("Slider", name, r, "OptionsSliderTemplate")
	s:SetPoint("RIGHT", r, "RIGHT", -60, 0)
	s:SetWidth(150)
	s:SetHeight(16)
	s:SetMinMaxValues(minV, maxV)
	s:SetValueStep(step)
	_G[name .. "Low"]:SetText("")
	_G[name .. "High"]:SetText("")
	_G[name .. "Text"]:SetText("")

	local box = CreateFrame("EditBox", UName(), r, "InputBoxTemplate")
	box:SetWidth(40)
	box:SetHeight(18)
	box:SetPoint("RIGHT", r, "RIGHT", -8, 0)
	box:SetAutoFocus(false)
	box:SetFontObject("GameFontHighlightSmall")
	box:SetJustifyH("CENTER")

	local function Quant(v)
		v = tonumber(v) or minV
		if v < minV then v = minV elseif v > maxV then v = maxV end
		return math.floor(v / step + 0.5) * step
	end
	s:SetScript("OnValueChanged", function(self, v)
		v = Quant(v)
		if not box:HasFocus() then box:SetText(Disp(v)) end
		if self.loading then return end
		SP.cfg[key] = v
		Changed()
	end)
	box:SetScript("OnEnterPressed", function(self)
		local n = tonumber((string.gsub(self:GetText() or "", "%%", "")))
		if n and pct then n = n / 100 end
		local v = Quant(n)
		self:ClearFocus()
		s:SetValue(v)
		self:SetText(Disp(v))
	end)
	box:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		self:SetText(Disp(SP.cfg[key] or minV))
	end)
	function r:Refresh()
		s.loading = true
		s:SetValue(SP.cfg[key])
		box:SetText(Disp(Quant(SP.cfg[key])))
		s.loading = false
	end
	function r:Enable() s:Enable(); box:EnableMouse(true) end
	function r:Disable() s:Disable(); box:EnableMouse(false) end
	Tip(s, tip)
	widgets[#widgets + 1] = r
	return r
end

local function MakeSwatch(parent, y, label, getter, setter, tip)
	local r = NewRow(parent, y)
	r.label:SetText(label)
	local b = CreateFrame("Button", nil, r)
	b:SetWidth(18)
	b:SetHeight(18)
	b:SetPoint("RIGHT", -12, 0)
	local edge = b:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints()
	edge:SetTexture(0, 0, 0, 1)
	local tex = b:CreateTexture(nil, "ARTWORK")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	function r:Refresh()
		local cr, cg, cb = getter()
		tex:SetTexture(cr, cg, cb, 1)
	end
	b:SetScript("OnClick", function()
		local cr, cg, cb = getter()
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame.opacityFunc = nil
		ColorPickerFrame.previousValues = { r = cr, g = cg, b = cb }
		ColorPickerFrame.func = function()
			setter(ColorPickerFrame:GetColorRGB())
			r:Refresh()
			Changed()
		end
		ColorPickerFrame.cancelFunc = function(p)
			setter(p.r, p.g, p.b)
			r:Refresh()
			Changed()
		end
		ColorPickerFrame:SetColorRGB(cr, cg, cb)
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end)
	function r:Enable() b:Enable() end
	function r:Disable() b:Disable() end
	Tip(b, tip)
	widgets[#widgets + 1] = r
	return r
end

local function CfgColor(key)
	return function() local c = SP.cfg[key]; return c[1], c[2], c[3] end,
	       function(r, g, b) local c = SP.cfg[key]; c[1], c[2], c[3] = r, g, b end
end
local function MakeCfgSwatch(parent, y, label, key, tip)
	local g, s = CfgColor(key)
	return MakeSwatch(parent, y, label, g, s, tip)
end

-- desplegable propio, con rueda del raton
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

local function MakeDropdown(parent, y, label, key, getOptions, tip)
	local r = NewRow(parent, y)
	r.label:SetText(label)
	local b = FlatButton(r, 170, 20, "")
	b:SetPoint("RIGHT", -8, 0)
	b.text:ClearAllPoints()
	b.text:SetPoint("LEFT", 8, 0)
	b.text:SetPoint("RIGHT", -18, 0)
	b.text:SetJustifyH("LEFT")
	local arrow = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	arrow:SetPoint("RIGHT", -6, 0)
	arrow:SetText("v")
	function r:Refresh()
		local cur, text = SP.cfg[key], SP.cfg[key]
		for _, o in ipairs(getOptions()) do
			if o[2] == cur then text = o[1] end
		end
		b:SetText(text)
	end
	b:SetScript("OnClick", function(self)
		if listFrame and listFrame:IsShown() and listFrame.anchor == self then
			listFrame:Hide()
			return
		end
		ShowList(self, getOptions(), SP.cfg[key], function(o)
			SP.cfg[key] = o[2]
			r:Refresh()
			Changed()
		end)
	end)
	function r:Enable() b:Enable() end
	function r:Disable() b:Disable() end
	Tip(b, tip)
	widgets[#widgets + 1] = r
	return r
end

local function MakeEditBox(parent, y, label, key, tip)
	local r = NewRow(parent, y)
	r.label:SetText(label)
	local e = CreateFrame("EditBox", UName(), r, "InputBoxTemplate")
	e:SetWidth(170)
	e:SetHeight(20)
	e:SetPoint("RIGHT", -8, 0)
	e:SetAutoFocus(false)
	e:SetFontObject("GameFontHighlightSmall")
	e:SetScript("OnEnterPressed", function(self)
		SP.cfg[key] = self:GetText()
		self:ClearFocus()
		Changed()
	end)
	e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	function r:Refresh() e:SetText(SP.cfg[key] or ""); e:SetCursorPosition(0) end
	function r:Enable() e:EnableMouse(true) end
	function r:Disable() e:EnableMouse(false) end
	Tip(e, tip)
	widgets[#widgets + 1] = r
	return r
end

------------------------------ LAYOUT ------------------------------
-- una columna de filas, en bloques uno debajo de otro. L:More() abre un
-- bloque plegado ("Mas opciones") que llega hasta el siguiente titulo.
-- flat = paginas con lista propia (Hechizos, Totems): todo va directo a la pagina
local INDEX, curSec = {}, nil -- indice del buscador

local function AddIndex(L, label, tip, y, kind)
	if not curSec or not label then return end
	INDEX[#INDEX + 1] = { label = label, tip = tip and T(tip) or "", sec = curSec, y = y, kind = kind, block = L.cur, L = L }
end

local function NewLayout(page, flat)
	local L = { page = page, blocks = {}, groups = {}, flat = flat }

	function L:NewBlock(group)
		if self.cur then self.cur.h = -self.y end
		local b = CreateFrame("Frame", nil, page)
		b:SetWidth(CW)
		b:SetHeight(1)
		b.group = group
		b.top = 0
		self.blocks[#self.blocks + 1] = b
		self.cur = b
		self.y = 0
	end

	function L:Relayout()
		if flat then return end
		local y = -10
		for _, b in ipairs(self.blocks) do
			if b.group and not b.group.open then
				b:Hide()
			else
				b:Show()
				b:ClearAllPoints()
				b:SetPoint("TOPLEFT", page, "TOPLEFT", 0, y)
				b.top = y
				y = y - (b.h or 0)
			end
		end
		page:SetHeight(-y + 12)
		if self.onResize then self.onResize() end
	end

	-- titulo de la pagina
	function L:Title(text)
		AddIndex(self, text, nil, self.y, "header")
		local fs = self.cur:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		fs:SetPoint("TOPLEFT", 12, self.y - 2)
		fs:SetText(text)
		self.y = self.y - 30
	end

	-- titulo de un grupo de opciones
	function L:Header(text)
		if not flat and self.cur.group then self:NewBlock(nil) end
		if self.y < -12 or (not flat and #self.blocks > 1) then self.y = self.y - 10 end
		AddIndex(self, text, nil, self.y, "header")
		local fs = self.cur:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		fs:SetPoint("TOPLEFT", 12, self.y - 4)
		fs:SetText(text)
		fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
		self.y = self.y - 24
	end

	function L:Note(text)
		local fs = self.cur:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		fs:SetPoint("TOPLEFT", 16, self.y - 2)
		fs:SetWidth(CW - 40)
		fs:SetJustifyH("LEFT")
		fs:SetText(text)
		self.y = self.y - math.max(16, fs:GetStringHeight() + 8)
	end

	-- reserva una fila y la apunta en el buscador
	local function Place(self, label, tip)
		local y = self.y
		AddIndex(self, label, tip, y, "row")
		self.y = self.y - ROW_H
		if self.cur.group then self.cur.group.count = self.cur.group.count + 1 end
		return y
	end
	function L:Check(label, key, tip) return MakeCheck(self.cur, Place(self, label, tip), label, key, tip) end
	function L:Toggle(label, get, set, tip) return MakeToggle(self.cur, Place(self, label, tip), label, get, set, tip) end
	function L:Slider(label, key, a, b, step, fmt, tip)
		return MakeSlider(self.cur, Place(self, label, tip), label, key, a, b, step, fmt, tip)
	end
	function L:Dropdown(label, key, opts, tip) return MakeDropdown(self.cur, Place(self, label, tip), label, key, opts, tip) end
	function L:Color(label, key, tip) return MakeCfgSwatch(self.cur, Place(self, label, tip), label, key, tip) end
	function L:Swatch(label, get, set, tip) return MakeSwatch(self.cur, Place(self, label, tip), label, get, set, tip) end
	function L:Edit(label, key, tip) return MakeEditBox(self.cur, Place(self, label, tip), label, key, tip) end
	function L:Button(text, onClick, tip)
		local y = Place(self, text, tip)
		local b = FlatButton(self.cur, 220, 22, text)
		b:SetPoint("TOPLEFT", 16, y - 2)
		b:SetScript("OnClick", onClick)
		Tip(b, tip)
		return b
	end

	-- "Mas opciones": lo de detras (hasta el siguiente titulo) queda plegado
	function L:More()
		if flat then return end
		local g = { open = false, count = 0 }
		local r = CreateFrame("Button", nil, self.cur)
		r:SetPoint("TOPLEFT", 8, self.y)
		r:SetPoint("TOPRIGHT", -8, self.y)
		r:SetHeight(ROW_H - 4)
		local hl = r:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetTexture(1, 1, 1, 0.04)
		local fs = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		fs:SetPoint("LEFT", 8, 0)
		function g:Update()
			if self.open then
				fs:SetText("-  " .. T("Menos opciones"))
			else
				fs:SetText("+  " .. string.format(T("Mas opciones (%d)"), self.count))
			end
		end
		r:SetScript("OnClick", function()
			g.open = not g.open
			g:Update()
			L:Relayout()
		end)
		self.y = self.y - ROW_H
		self.groups[#self.groups + 1] = g
		self:NewBlock(g)
	end

	function L:Height()
		if flat then return -self.y + 12 end
		self.cur.h = -self.y
		for _, g in ipairs(self.groups) do g:Update() end
		self:Relayout()
		return page:GetHeight()
	end

	if flat then
		L.cur = page
		page.top = 0
		L.y = -10
	else
		L:NewBlock(nil)
	end
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
	return { { T("Clasico WotLK"), "classic" }, { T("Antiguo (Blizzard)"), "old" } }
end

local function IconBorderOptions()
	return { { T("Blizzard (como BigDebuffs)"), "blizzard" }, { T("Plano (negro)"), "flat" } }
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

local function BuildPlatePage(L)
	L:Title(T("Placa"))
	L:Header(T("Estilo y tamano"))
	L:Dropdown(T("Forma de las barras"), "shape", ShapeOptions)
	L:Slider(T("Escala"), "scale", 0.5, 2, 0.05, "%.2f")
	L:Slider(T("Ancho"), "width", 60, 200, 1)
	L:Slider(T("Alto de barra"), "height", 4, 24, 1)
	L:Check(T("Centrar sobre la cabeza"), "centerPlate",
		"La mitad de la barra queda justo encima de la cabeza del personaje. Desactivalo para moverla en horizontal a mano.")
	L:Slider(T("Mover vertical (Y)"), "offsetY", -100, 100, 1)
	L:More()
	L:Dropdown(T("Textura de la barra"), "texture", TextureOptions)
	Dep(L:Slider(T("Mover horizontal (X)"), "offsetX", -100, 100, 1), function() return not SP.cfg.centerPlate end)
	L:Check(T("Pixel perfect (bordes nitidos)"), "pixelPerfect",
		"Ajusta tamanos y posiciones a pixeles exactos de tu pantalla para que los bordes se vean nitidos.")

	L:Header(T("Texto"))
	L:Check(T("Mostrar nombre"), "showName")
	L:Check(T("Mostrar nivel"), "showLevel")
	L:Slider(T("Tamano de texto"), "fontSize", 6, 20, 1)
	L:Dropdown(T("Fuente"), "font", FontOptions)
	L:Check(T("Mostrar texto de vida"), "showHealthText")
	L:More()
	L:Dropdown(T("Contorno"), "fontOutline", OutlineOptions)
	L:Edit(T("Ruta de fuente personalizada (Enter)"), "font", "Ruta de un archivo .ttf, por ejemplo Interface\\AddOns\\MiFuente\\fuente.ttf")
	Dep(L:Dropdown(T("Formato del texto de vida"), "healthFormat", HealthFormatOptions), On("showHealthText"))
	Dep(L:Check(T("Ocultar texto con vida al maximo"), "healthHideMax"), On("showHealthText"))
	Dep(L:Slider(T("Mover nombre X"), "nameX", -60, 60, 1, nil, "Con 0 el nombre queda en el centro exacto de la barra."), On("showName"))
	Dep(L:Slider(T("Mover nombre Y"), "nameY", -40, 40, 1), On("showName"))
	Dep(L:Slider(T("Ancho del nombre"), "nameWidth", 50, 250, 1, nil,
		"Ancho maximo del nombre: si no cabe se recorta con ... para que vaya siempre en una sola fila."), On("showName"))
	Dep(L:Slider(T("Tamano del nivel"), "levelFontSize", 6, 30, 1, nil,
		"Tamano de letra del nivel (el numero junto a la barra, por ejemplo 80)."), On("showLevel"))
	Dep(L:Slider(T("Tamano de la calavera"), "bossIconSize", 8, 30, 1, nil,
		"Calavera de Blizzard que sustituye al nivel ?? en jefes y elites sin nivel."), On("showLevel"))

	L:Header(T("Efectos"))
	L:Check(T("Sombra suave"), "shadow",
		"Halo oscuro difuminado alrededor de la barra para separarla del fondo. No se usa en el estilo Antiguo (marco dorado).")
	L:Check(T("Rastro de dano"), "healthTrail",
		"Al perder vida queda un momento un trozo claro que se encoge hasta el valor nuevo: se ve cuanto dano acaba de recibir.")
	L:Check(T("Modificar opacidad sin target"), "modNonTargetAlpha",
		"Sustituye la opacidad del juego en las placas que no son tu target (solo cuando tienes un target). Desactivado: se usa la del juego.")
	Dep(L:Slider(T("Opacidad sin target"), "nonTargetAlpha", 0, 0.99, 0.01, "pct",
		"De 0% (invisibles) a 99% (casi sin transparencia). Puedes escribir el valor exacto."), On("modNonTargetAlpha"))
	L:More()
	Dep(L:Slider(T("Tamano de la sombra"), "shadowSize", 1, 10, 1), On("shadow"))
	Dep(L:Slider(T("Intensidad de la sombra"), "shadowAlpha", 0.1, 1, 0.05, "pct"), On("shadow"))
end

local function BuildCastPage(L)
	local cast = On("showCast")
	L:Title(T("Castbar"))
	L:Header(T("Castbar"))
	L:Check(T("Mostrar cast bar"), "showCast")
	Dep(L:Check(T("Icono del hechizo"), "showCastIcon"), cast)
	Dep(L:Check(T("Nombre del hechizo en el cast"), "showCastText"), cast)
	Dep(L:Check(T("Tiempo restante del cast"), "showCastTime"), cast)
	Dep(L:Check(T("Chispa en el cast"), "castSpark", "Linea brillante en el borde del relleno, como en la barra de Blizzard."), cast)
	Dep(L:Slider(T("Alto cast bar"), "castHeight", 4, 24, 1), cast)
	Dep(L:Slider(T("Tamano texto del cast"), "castFontSize", 5, 16, 1), cast)
	L:More()
	Dep(L:Slider(T("Ancho cast bar"), "castWidth", -60, 120, 1, nil, "Ancho extra del castbar (se suma a la derecha). Con 0 queda el ancho original."), cast)
	Dep(L:Slider(T("Mover cast bar arriba/abajo"), "castY", -40, 40, 1, nil, "Positivo sube el castbar, negativo lo baja. Con 0 queda en su posicion original."), cast)

	L:Header(T("Interrupciones"))
	Dep(L:Check(T("Mostrar quien corto el cast"), "showInterrupter"), cast)
	Dep(L:Slider(T("Tiempo de 'Interrupted' (s)"), "castInterruptHold", 0.3, 3, 0.1, "%.1f",
		"Cuanto tiempo se queda la barra parada en rojo al cortar un cast."), cast)
	L:More()
	L:Check(T("Estilo de cast en target y focus"), "tfCast",
		"Aplica el rojo de 'Interrupted' y el color de no interrumpible a los castbars de los marcos de target y focus.")
end

local function BuildColorsPage(L)
	L:Title(T("Colores"))
	L:Header(T("Color de clase"))
	L:Check(T("Color de clase en jugadores"), "classColorPlayers")
	for _, class in ipairs(CLASS_ORDER) do
		local sw = L:Swatch((LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class]) or class,
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

	L:Header(T("Barra y texto"))
	L:Color(T("Fondo de barra"), "bgColor")
	L:Slider(T("Oscuridad del fondo de barra"), "bgAlpha", 0, 1, 0.01, "pct",
		"Opacidad del interior de las barras (la parte vacia). 100% = fondo totalmente oscuro; baja el valor para verlo mas transparente.")
	L:Color(T("Color del texto"), "textColor")

	L:Header(T("Colores del cast"))
	L:Color(T("Color de cast bar"), "castColor")
	L:Color(T("Cast no interrumpible"), "castNoInterruptColor")
	L:Color(T("Cast interrumpido"), "castInterruptColor")

	L:Header(T("Tinte de borde"))
	L:Note(T("Es un tinte, no un color normal: blanco deja el borde original; gris oscuro o negro lo oscurece."))
	L:More()
	Dep(L:Color(T("Tinte de borde"), "borderTint", "Marco dorado de la barra de vida. Solo en el estilo Antiguo (Blizzard)."),
		function() return SP.cfg.shape == "old" end)
	Dep(L:Color(T("Tinte de borde del cast"), "castBorderTint", "Marco plateado del castbar. Solo en los estilos Clasico y Antiguo."), IsClassicStyle)
	Dep(L:Color(T("Tinte de borde (no interrumpible)"), "castProtectedBorderTint", "Marco con escudo del castbar cuando el hechizo no se puede interrumpir. Solo en los estilos Clasico y Antiguo."), IsClassicStyle)
end

local function BuildArenaPage(L)
	local ids = function() return SP.cfg.arenaIDs or SP.cfg.partyIDs end
	L:Title(T("Arena y grupo"))
	L:Header(T("Numeros de arena"))
	L:Check(T("Numeros de arena (enemigos)"), "arenaIDs", "Muestra 1-5 en cada rival de arena (en rojo).")
	L:Check(T("Numeros de grupo (aliados)"), "partyIDs", "Muestra el numero de cada companero de arena (en verde).")
	Dep(L:Dropdown(T("Posicion del numero de arena"), "arenaIDPos", ArenaIDPosOptions), ids)

	L:Header(T("Sanadores"))
	L:Note(T("Cruz verde junto al nombre de los healers. Se detectan por sus hechizos (Holy Shock, Penance, Riptide, Swiftmend...) y, si usas Gladius, tambien por su deteccion de especializacion."))
	L:Check(T("Sanadores rivales"), "healerEnemy")
	L:Check(T("Sanadores de tu grupo"), "healerParty")
	L:More()
	Dep(L:Slider(T("Tamano (rivales)"), "healerEnemySize", 10, 40, 1), On("healerEnemy"))
	Dep(L:Slider(T("Mover X (rivales)"), "healerEnemyX", -100, 100, 1, nil, "Positivo a la derecha, negativo a la izquierda."), On("healerEnemy"))
	Dep(L:Slider(T("Mover Y (rivales)"), "healerEnemyY", -60, 60, 1, nil, "Positivo sube, negativo baja."), On("healerEnemy"))
	Dep(L:Slider(T("Tamano (grupo)"), "healerPartySize", 10, 40, 1), On("healerParty"))
	Dep(L:Slider(T("Mover X (grupo)"), "healerPartyX", -100, 100, 1, nil, "Positivo a la derecha, negativo a la izquierda."), On("healerParty"))
	Dep(L:Slider(T("Mover Y (grupo)"), "healerPartyY", -60, 60, 1, nil, "Positivo sube, negativo baja."), On("healerParty"))

	L:Header(T("Tu equipo"))
	L:Check(T("Aliados con color de clase"), "friendlyClassColor",
		"Desmarcado: tus aliados salen en un color fijo (azul) para no confundirlos con los enemigos.")
	Dep(L:Color(T("Color de jugadores aliados"), "friendlyPlayerColor"), function() return not SP.cfg.friendlyClassColor end)
	L:Slider(T("Tamano de aliados"), "friendlyScale", 0.5, 1.5, 0.05, "%.2f")
	L:Dropdown(T("Solo nombre en arenas"), "barlessArena", BarlessOptions,
		"Las placas amistosas muestran solo el nombre, sin barra.")
	L:Dropdown(T("Solo nombre en campos de batalla"), "barlessBG", BarlessOptions)
	L:More()
	L:Dropdown(T("Solo nombre en mundo abierto"), "barlessWorld", BarlessOptions)
	L:Dropdown(T("Solo nombre en mazmorras y bandas"), "barlessPvE", BarlessOptions)
	L:Check(T("Barras normales en tu target"), "barlessExcludeTarget")

	L:Header(T("Marca sobre tu grupo"))
	L:Check(T("Marca sobre tu grupo"), "allyMarker",
		"Tus companeros de grupo que salen sin barra llevan el icono de su clase encima y el nombre mas grande, con su color.")
	L:More()
	Dep(L:Slider(T("Tamano del icono de la marca"), "allyMarkerSize", 12, 40, 1), On("allyMarker"))
	Dep(L:Slider(T("Tamano del nombre"), "allyNameSize", 8, 24, 1), On("allyMarker"))

	L:Header(T("Tu target"))
	L:Slider(T("Escala del target"), "targetScale", 0.8, 2, 0.05, "%.2f")
	L:More()
	L:Check(T("Mantener target en pantalla"), "clampTarget",
		"Si la placa de tu target se sale por arriba de la pantalla, se queda pegada al borde superior.")
	Dep(L:Slider(T("Margen superior"), "clampMargin", 0, 150, 5), On("clampTarget"))
end

local function BuildAdvancedPage(L)
	L:Title(T("Avanzado"))
	L:Header(T("Idioma / Language"))
	L:Dropdown(T("Idioma / Language"), "language", LanguageOptions, "Automatico: espanol si tu cliente esta en espanol, ingles en cualquier otro.")
	L:Header(T("Apilado"))
	L:Check(T("Apilar placas (evitar solapamiento)"), "stacking",
		"Separa las placas que se solapan. El juego ya las separa por su cuenta; activalo solo si lo prefieres.")
	Dep(L:Slider(T("Separacion"), "stackGap", 0, 10, 1), On("stacking"))
	Dep(L:Slider(T("Velocidad de apilado"), "stackSpeed", 2, 30, 1), On("stacking"))
	L:Header(T("Comandos"))
	L:Note(T("Comandos: /hms abre las opciones, /hms setup el asistente y /hms test prueba los iconos en tu target."))
end

-- debuffs importantes (lo que antes era la WA)
local CAT_LABELS = {
	immunities = "Inmunidades", cc = "Control (CC)", silence = "Silencios", roots = "Raices",
	disarms = "Desarmes", defensives = "Defensivos", offensives = "Ofensivos", others = "Otros",
}

local function DebuffPosOptions()
	return { { T("A la derecha"), "right" }, { T("A la izquierda"), "left" } }
end

local function GCDPosOptions()
	return { { T("A la izquierda"), "left" }, { T("A la derecha"), "right" } }
end

local function BuildIconsPage(L)
	L:Title(T("Iconos"))
	L:Header(T("Icono de clase"))
	L:Check(T("Icono de clase"), "classIcon", "Muestra el icono de la clase de los jugadores a la izquierda de la barra.")
	Dep(L:Slider(T("Tamano del icono de clase"), "classIconSize", 10, 40, 1), On("classIcon"))
	L:More()
	Dep(L:Slider(T("Separacion del icono de clase"), "classIconGap", -10, 20, 1, nil,
		"0 = pegado a la placa. Positivo lo aparta, negativo lo mete sobre el borde."), On("classIcon"))

	local deb = On("debuffs")
	L:Header(T("Debuffs importantes"))
	L:Check(T("Mostrar debuffs importantes"), "debuffs",
		"Muestra en cada placa enemiga el aura mas importante segun su categoria y prioridad.")
	Dep(L:Dropdown(T("Posicion"), "debuffPos", DebuffPosOptions), deb)
	Dep(L:Slider(T("Ancho del icono"), "debuffWidth", 10, 100, 1), deb)
	Dep(L:Slider(T("Alto del icono"), "debuffHeight", 10, 100, 1), deb)
	Dep(L:Check(T("Tiempo restante en el icono"), "debuffTimer"), deb)
	L:More()
	Dep(L:Check(T("Solo en enemigos"), "debuffEnemyOnly"), deb)
	Dep(L:Check(T("Solo en arena"), "debuffArenaOnly"), deb)
	Dep(L:Check(T("Bloqueos de interrupcion (Pummel, Kick...)"), "debuffLockouts",
		"Pummel, Shield Bash, Kick, etc. no dejan aura: se detectan en el registro de combate y se muestran como silencio."), deb)
	Dep(L:Slider(T("Mover icono X"), "debuffX", -150, 150, 1, nil, "Positivo a la derecha, negativo a la izquierda."), deb)
	Dep(L:Slider(T("Mover icono Y"), "debuffY", -100, 100, 1, nil, "Positivo sube, negativo baja."), deb)
	for i, cat in ipairs(SP.DEBUFF_CATS or {}) do
		Dep(L:Toggle(string.format(T("Categoria %d: %s"), i, T(CAT_LABELS[cat] or cat)),
			function() return SP.cfg.debuffCats[cat] ~= false end,
			function(v) SP.cfg.debuffCats[cat] = v end), deb)
	end

	local gcd = On("gcd")
	L:Header(T("GCD de arena"))
	L:Check(T("Mostrar GCD de enemigos de arena"), "gcd",
		"Muestra el ultimo hechizo de cada rival de arena con un barrido que dura su GCD (clase, haste y procs instantaneos). Basado en NameplateArenaGCDs.")
	Dep(L:Dropdown(T("Posicion"), "gcdPos", GCDPosOptions), gcd)
	Dep(L:Slider(T("Ancho del icono"), "gcdWidth", 10, 100, 1), gcd)
	Dep(L:Slider(T("Alto del icono"), "gcdHeight", 10, 100, 1), gcd)
	Dep(L:Check(T("Tiempo restante en el icono"), "gcdTimer"), gcd)
	L:More()
	Dep(L:Slider(T("Mover icono X"), "gcdX", -150, 150, 1, nil, "Positivo a la derecha, negativo a la izquierda."), gcd)
	Dep(L:Slider(T("Mover icono Y"), "gcdY", -100, 100, 1, nil, "Positivo sube, negativo baja."), gcd)
	Dep(L:Check(T("Invertir el barrido"), "gcdReverse"), gcd)
	Dep(L:Check(T("Ocultar el barrido"), "gcdHideSweep"), gcd)
	Dep(L:Slider(T("Opacidad del barrido"), "gcdAlpha", 0, 1, 0.05, "%.2f"), function() return SP.cfg.gcd and not SP.cfg.gcdHideSweep end)
	Dep(L:Button(T("Probar en mi target (15 s)"), function() if SP.TestGCD then SP.TestGCD() end end), gcd)

	L:Header(T("Borde de los iconos"))
	L:Dropdown(T("Estilo del borde de iconos"), "iconBorder", IconBorderOptions,
		"Borde de los iconos de debuffs, GCD, interrupciones y cast. Blizzard = el mismo marco de BigDebuffs; Plano = solo una linea negra.")
	L:More()
	Dep(L:Color(T("Tinte del borde de iconos"), "iconBorderTint",
		"Es un tinte: blanco = marco original de Blizzard; gris oscuro o negro lo oscurece."), function() return SP.cfg.iconBorder ~= "flat" end)
end

-- lista de totems: modo e icono de cada uno
local ELEMENT_COLOR = { earth = { 0.8, 0.67, 0 }, fire = { 1, 0.33, 0.33 }, water = { 0.4, 0.6, 1 }, air = { 0.7, 0.9, 1 } }
local MODES = { [1] = { "Icono", 0.3, 1, 0.3 }, [0] = { "Oculto", 1, 0.3, 0.3 }, [2] = { "Placa", 0.8, 0.8, 0.8 }, [3] = { "Icono + Placa", 0.4, 0.8, 1 } }
local NEXT_MODE = { [1] = 0, [0] = 2, [2] = 3, [3] = 1 }

local function TotemCfg(id)
	local t = SP.cfg.totems[id]
	if not t then t = { mode = 1, icon = "" }; SP.cfg.totems[id] = t end
	return t
end

-- sin scroll de pagina, la lista ya tiene el suyo
local function BuildTotemsPage(L)
	L:Header(T("Totems"))
	L:Check(T("Totems como icono"), "totemIcons")
	Dep(L:Slider(T("Tamano icono totem"), "totemSize", 12, 48, 1), On("totemIcons"))
	Dep(L:Check(T("Ocultar totems aliados"), "totemHideFriendly"), On("totemIcons"))
	Dep(L:Slider(T("Escala de la placa del totem"), "totemPlateScale", 0.5, 2.5, 0.05, "%.2f",
		"Agranda o achica solo las placas de los totems (modos Placa e Icono + Placa). No afecta a las demas placas."), On("totemIcons"))
	Dep(L:Slider(T("Mover icono totem X"), "totemX", -80, 80, 1, nil, "Mueve el icono del totem en horizontal."), On("totemIcons"))
	Dep(L:Slider(T("Mover icono totem Y"), "totemY", -80, 80, 1, nil, "Mueve el icono del totem en vertical."), On("totemIcons"))
	L:Header(T("Totem                                              Modo                      Icono propio (ruta o ID de hechizo + Enter)"))
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

				local btn = FlatButton(row, 96, 20, "")
				btn:SetPoint("LEFT", 184, 0)

				local eb = CreateFrame("EditBox", UName(), row, "InputBoxTemplate")
				eb:SetWidth(166)
				eb:SetHeight(20)
				eb:SetPoint("LEFT", 290, 0)
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


------------------------------ HECHIZOS (debuffs) ------------------------
-- lista de auras: encender/apagar cada una, cambiar categoria o
-- prioridad y meter hechizos por ID (parecido a BigDebuffs). El scroll
-- es "virtual": hay pocas filas de verdad y se rellenan segun bajas
local SPELL_ROWS, SPELL_ROW_H = 13, 24

local function SpellState(id)
	local cfg = SP.cfg
	local b, c, o = SP.DEBUFF_BASE[id], cfg.customSpells[id], cfg.spellOverrides[id]
	local cat = (c and c.cat) or (b and b.cat)
	local pri = (c and tonumber(c.pri)) or (b and b.pri) or 50
	if o then
		if o.cat then cat = o.cat end
		if o.pri then pri = o.pri end
	end
	return not (o and o.off), cat, pri
end

local function SpellOv(id)
	local t = SP.cfg.spellOverrides
	if not t[id] then t[id] = {} end
	return t[id]
end

local function SpellClean(id)
	local o = SP.cfg.spellOverrides[id]
	if o and not o.off and not o.cat and not o.pri then SP.cfg.spellOverrides[id] = nil end
end

local function BuildSpellsPage(L)
	local cats = SP.DEBUFF_CATS or {}
	local nextCat = {}
	for i, c in ipairs(cats) do nextCat[c] = cats[i + 1] or cats[1] end
	local catIdx = {}
	for i, c in ipairs(cats) do catIdx[c] = i end

	L:Header(T("Hechizos de los debuffs"))
	L:Note(T("Marca los que quieres ver, cambia su categoria o prioridad, o anade los tuyos por ID. La categoria manda; dentro de ella gana la prioridad mas alta."))
	local p = L.page
	local y = L.y
	local state = { cat = nil, text = "", newCat = "cc" }
	local list, rows, sf = {}, {}, nil
	local nameCache = {}

	local function NameOf(id)
		local n = nameCache[id]
		if not n then
			local b = SP.DEBUFF_BASE[id]
			n = GetSpellInfo(id) or (b and b.name) or ("ID " .. id)
			nameCache[id] = n
		end
		return n
	end
	local function CatLabel(cat) return T(CAT_LABELS[cat] or cat or "?") end

	local function Rebuild()
		local ids, seen = {}, {}
		for id in pairs(SP.DEBUFF_BASE) do seen[id] = true; ids[#ids + 1] = id end
		for id in pairs(SP.cfg.customSpells) do if not seen[id] then ids[#ids + 1] = id end end
		local q = strlower(state.text or "")
		local f = {}
		for _, id in ipairs(ids) do
			local _, cat = SpellState(id)
			if (not state.cat or cat == state.cat)
				and (q == "" or strfind(strlower(NameOf(id)), q, 1, true) or strfind(tostring(id), q, 1, true)) then
				f[#f + 1] = id
			end
		end
		table.sort(f, function(a, b)
			local _, ca, pa = SpellState(a)
			local _, cb, pb = SpellState(b)
			if ca ~= cb then return (catIdx[ca] or 99) < (catIdx[cb] or 99) end
			if pa ~= pb then return pa > pb end
			local na, nb = NameOf(a), NameOf(b)
			if na ~= nb then return na < nb end
			return a < b
		end)
		list = f
	end

	local function Update()
		FauxScrollFrame_Update(sf, #list, SPELL_ROWS, SPELL_ROW_H)
		local off = FauxScrollFrame_GetOffset(sf)
		for i = 1, SPELL_ROWS do
			local id = list[off + i]
			if id then rows[i]:Set(id); rows[i]:Show() else rows[i]:Hide() end
		end
	end

	local function Changed()
		SP.DebuffsChanged()
		Apply()
	end

	-- fila 1: filtro, buscador y restablecer
	local filterBtn = FlatButton(p, 160, 20, "")
	filterBtn:SetPoint("TOPLEFT", 14, y - 2)
	local function RefreshFilter()
		filterBtn:SetText(T("Categoria") .. ": " .. (state.cat and CatLabel(state.cat) or T("Todas")))
	end
	filterBtn:SetScript("OnClick", function()
		if not state.cat then state.cat = cats[1]
		elseif catIdx[state.cat] >= #cats then state.cat = nil
		else state.cat = cats[catIdx[state.cat] + 1] end
		RefreshFilter()
		Rebuild()
		sf:SetVerticalScroll(0)
		Update()
	end)
	Tip(filterBtn, "Pulsa para filtrar la lista por categoria.")

	local sLbl = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	sLbl:SetPoint("TOPLEFT", 190, y - 6)
	sLbl:SetText(T("Buscar"))
	local search = CreateFrame("EditBox", UName(), p, "InputBoxTemplate")
	search:SetWidth(120)
	search:SetHeight(20)
	search:SetPoint("TOPLEFT", 238, y - 2)
	search:SetAutoFocus(false)
	search:SetFontObject("GameFontHighlightSmall")
	search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	search:SetScript("OnTextChanged", function(self)
		state.text = self:GetText() or ""
		Rebuild()
		sf:SetVerticalScroll(0)
		Update()
	end)
	Tip(search, "Busca por nombre o por ID de hechizo.")

	local resetBtn = FlatButton(p, 100, 20, T("Restablecer"))
	resetBtn:SetPoint("TOPLEFT", 372, y - 2)
	resetBtn:SetScript("OnClick", function()
		for k in pairs(SP.cfg.spellOverrides) do SP.cfg.spellOverrides[k] = nil end
		for k in pairs(SP.cfg.customSpells) do SP.cfg.customSpells[k] = nil end
		Changed()
		Rebuild()
		Update()
	end)
	Tip(resetBtn, "Vuelve la lista de hechizos a la original: quita tus hechizos y deshace los cambios.")

	-- fila 2: anadir hechizo por ID
	local aLbl = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	aLbl:SetPoint("TOPLEFT", 14, y - 34)
	aLbl:SetText(T("Anadir ID"))
	local idBox = CreateFrame("EditBox", UName(), p, "InputBoxTemplate")
	idBox:SetWidth(70)
	idBox:SetHeight(20)
	idBox:SetPoint("TOPLEFT", 78, y - 30)
	idBox:SetAutoFocus(false)
	idBox:SetFontObject("GameFontHighlightSmall")
	idBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	Tip(idBox, "ID del hechizo (por ejemplo el de Wowhead). Se anade en la categoria elegida a la derecha.")

	local newCatBtn = FlatButton(p, 120, 20, "")
	newCatBtn:SetPoint("TOPLEFT", 160, y - 30)
	local function RefreshNewCat() newCatBtn:SetText(CatLabel(state.newCat)) end
	newCatBtn:SetScript("OnClick", function()
		state.newCat = nextCat[state.newCat] or cats[1]
		RefreshNewCat()
	end)
	Tip(newCatBtn, "Categoria en la que se anadira el hechizo (pulsa para cambiar).")

	local status = p:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	status:SetPoint("TOPLEFT", 14, y - 54)
	status:SetWidth(450)
	status:SetJustifyH("LEFT")

	local addBtn = FlatButton(p, 80, 20, T("Anadir"))
	addBtn:SetPoint("TOPLEFT", 288, y - 30)
	local function DoAdd()
		local id = tonumber(idBox:GetText())
		id = id and math.floor(id)
		if not id or not GetSpellInfo(id) then
			status:SetTextColor(1, 0.3, 0.3)
			status:SetText(T("ID de hechizo no valido"))
			return
		end
		local cfg = SP.cfg
		local b = SP.DEBUFF_BASE[id]
		if b and not cfg.customSpells[id] then
			local o = SpellOv(id)
			o.off = nil
			o.cat = (state.newCat ~= b.cat) and state.newCat or nil
			SpellClean(id)
		else
			cfg.customSpells[id] = { cat = state.newCat, pri = 50 }
			if cfg.spellOverrides[id] then cfg.spellOverrides[id].off = nil; SpellClean(id) end
		end
		nameCache[id] = nil
		status:SetTextColor(0.3, 1, 0.3)
		status:SetText(NameOf(id) .. " (" .. id .. ") " .. T("anadido en") .. " " .. CatLabel(state.newCat))
		idBox:SetText("")
		idBox:ClearFocus()
		state.cat, state.text = nil, ""
		search:SetText("")
		RefreshFilter()
		Changed()
		Rebuild()
		Update()
		for i, v in ipairs(list) do
			if v == id then
				local sb = _G[sf:GetName() .. "ScrollBar"]
				if sb then sb:SetValue((i - 1) * SPELL_ROW_H) end
				break
			end
		end
	end
	addBtn:SetScript("OnClick", DoAdd)
	idBox:SetScript("OnEnterPressed", DoAdd)

	-- Cabecera de columnas
	local hy = y - 72
	local function Col(x, text)
		local fs = p:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		fs:SetPoint("TOPLEFT", x, hy)
		fs:SetText(T(text))
	end
	Col(40, "Hechizo")
	Col(214, "Ver")
	Col(246, "Categoria")
	Col(352, "Prioridad")

	-- Lista con scroll
	local ly = hy - 16
	sf = CreateFrame("ScrollFrame", UName(), p, "FauxScrollFrameTemplate")
	sf:SetPoint("TOPLEFT", 8, ly)
	sf:SetWidth(470)
	sf:SetHeight(SPELL_ROWS * SPELL_ROW_H)
	sf:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, SPELL_ROW_H, Update)
	end)
	p:EnableMouseWheel(true)
	p:SetScript("OnMouseWheel", function(_, delta)
		local sb = _G[sf:GetName() .. "ScrollBar"]
		if sb then sb:SetValue(sb:GetValue() - delta * SPELL_ROW_H * 2) end
	end)

	for i = 1, SPELL_ROWS do
		local row = CreateFrame("Frame", nil, p)
		row:SetWidth(470)
		row:SetHeight(SPELL_ROW_H - 2)
		row:SetPoint("TOPLEFT", 14, ly - (i - 1) * SPELL_ROW_H)

		row.ico = row:CreateTexture(nil, "ARTWORK")
		row.ico:SetWidth(20)
		row.ico:SetHeight(20)
		row.ico:SetPoint("LEFT", 2, 0)
		row.ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.name:SetPoint("LEFT", 28, 0)
		row.name:SetWidth(170)
		row.name:SetJustifyH("LEFT")

		row.chk = CreateFrame("CheckButton", UName(), row, "UICheckButtonTemplate")
		row.chk:SetWidth(24)
		row.chk:SetHeight(24)
		row.chk:SetPoint("LEFT", 196, 0)
		row.chk:SetScript("OnClick", function(self)
			local on = self:GetChecked() and true or false
			local o = SpellOv(row.id)
			o.off = (not on) or nil
			SpellClean(row.id)
			row:Set(row.id)
			Changed()
		end)

		row.cat = FlatButton(row, 100, 20, "")
		row.cat:SetPoint("LEFT", 232, 0)
		row.cat:SetScript("OnClick", function()
			local _, cur = SpellState(row.id)
			local new = nextCat[cur] or cats[1]
			local c = SP.cfg.customSpells[row.id]
			if c then
				c.cat = new
			else
				local o = SpellOv(row.id)
				o.cat = (new ~= SP.DEBUFF_BASE[row.id].cat) and new or nil
				SpellClean(row.id)
			end
			row:Set(row.id)
			Changed()
		end)

		row.pri = CreateFrame("EditBox", UName(), row, "InputBoxTemplate")
		row.pri:SetWidth(40)
		row.pri:SetHeight(18)
		row.pri:SetPoint("LEFT", 346, 0)
		row.pri:SetAutoFocus(false)
		row.pri:SetFontObject("GameFontHighlightSmall")
		row.pri:SetJustifyH("CENTER")
		row.pri:SetScript("OnEscapePressed", function(self) self:ClearFocus(); row:Set(row.id) end)
		row.pri:SetScript("OnEnterPressed", function(self)
			local n = tonumber(self:GetText())
			self:ClearFocus()
			if n then
				n = math.max(0, math.min(100, math.floor(n + 0.5)))
				local c = SP.cfg.customSpells[row.id]
				if c then
					c.pri = n
				else
					local o = SpellOv(row.id)
					o.pri = (n ~= SP.DEBUFF_BASE[row.id].pri) and n or nil
					SpellClean(row.id)
				end
				Changed()
			end
			row:Set(row.id)
		end)

		row.del = FlatButton(row, 24, 20, "")
		row.del:SetPoint("LEFT", 396, 0)
		row.del:SetScript("OnClick", function()
			SP.cfg.customSpells[row.id] = nil
			SP.cfg.spellOverrides[row.id] = nil
			Changed()
			Rebuild()
			Update()
		end)
		row.del:HookScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(T(SP.cfg.customSpells[row.id] and "Quitar de la lista" or "Volver al valor original"), 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		row.del:HookScript("OnLeave", function() GameTooltip:Hide() end)

		function row:Set(id)
			self.id = id
			local on, cat, pri = SpellState(id)
			local _, _, icon = GetSpellInfo(id)
			self.ico:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
			self.ico:SetDesaturated(not on)
			self.name:SetText(NameOf(id))
			if on then self.name:SetTextColor(1, 1, 1) else self.name:SetTextColor(0.5, 0.5, 0.5) end
			self.chk:SetChecked(on)
			self.cat:SetText(CatLabel(cat))
			self.pri:SetText(tostring(pri))
			self.pri:SetCursorPosition(0)
			if SP.cfg.customSpells[id] then
				self.del:SetText("X"); self.del:Show()
			elseif SP.cfg.spellOverrides[id] then
				self.del:SetText("R"); self.del:Show()
			else
				self.del:Hide()
			end
		end
		rows[i] = row
	end

	local holder = CreateFrame("Frame", nil, p)
	holder:SetWidth(1)
	holder:SetHeight(1)
	function holder:Refresh()
		RefreshFilter()
		RefreshNewCat()
		Rebuild()
		Update()
	end
	widgets[#widgets + 1] = holder
end

------------------------------ PERFILES ----------------------------
-- exportar/importar la config como texto para pasarla a otro pj o cuenta.
-- Formato propio con tipos (al importar no se ejecuta nada) y luego
-- base64 para que solo queden letras y numeros
local PROFILE_PREFIX = "HMS1:"
local PROFILE_SKIP = { geo = true, dbVersion = true, setupDone = true, activePreset = true } -- datos internos, no ajustes

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

-- lee el formato de arriba; devuelve valor y siguiente posicion (nil si falla)
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

-- true, o false y el motivo
-- el texto de un perfil -> su tabla de ajustes (o nil y el motivo)
function SP.DecodeProfile(text)
	text = string.gsub(text or "", "%s", "")
	if string.sub(text, 1, #PROFILE_PREFIX) ~= PROFILE_PREFIX then
		return nil, T("el texto no es un perfil de HemsworkPlates")
	end
	local data = Dec(string.sub(text, #PROFILE_PREFIX + 1))
	local tbl = data and Deser(data, 1, 0)
	if type(tbl) ~= "table" or type(tbl.width) ~= "number" then
		return nil, T("el perfil esta incompleto o danado (copialo entero)")
	end
	return tbl
end

function SP.ImportProfile(text)
	local tbl, err = SP.DecodeProfile(text)
	if not tbl then return false, err end
	local cfg, defaults = SP.cfg, SP.defaults
	for k in pairs(cfg) do
		if not PROFILE_SKIP[k] then cfg[k] = nil end
	end
	-- solo ajustes que existen y con el tipo bueno
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
		-- clic en cualquier parte del recuadro y ya escribes
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

------------------------- PERFILES YA HECHOS ------------------------
-- cada uno parte de los valores por defecto y cambia solo lo que pone aqui
-- ("import" = un perfil exportado entero). Al aplicarlo se conservan el idioma
-- y lo que el usuario haya montado a mano (hechizos y totems)
local HEMSWORK_PROFILE = "HMS1:e3MxOTpmcmllbmRseVBsYXllckNvbG9ye24xO24wO24yO24wO24zO24xO31zNTpuYW1lWG4wO3MxODpjYXN0SW50ZXJydXB0Q29sb3J7bjE7bjE7bjI7bjAuMTtuMztuMC4xO31zMTQ6Y2FzdEV4dHJhV2lkdGhuMDtzOTpjYXN0V2lkdGhuLTE3O3M0OmdjZFluMDtzMTc6Y2xhc3NDb2xvclBsYXllcnN0czExOmNlbnRlclBsYXRldHM4OmFyZW5hSURzdHM0OmZvbnRzMTg6Rm9udHNcRlJJWlFUX18uVFRGczEyOmNsYXNzSWNvbkdhcG4wO3M3Om9mZnNldFluMTM7czEzOmZyaWVuZGx5U2NhbGVuMC45NTtzMTI6YmFybGVzc1dvcmxkbjA7czY6c2hhZG93dHM5Om5hbWVXaWR0aG4xNTA7czE0Omljb25Cb3JkZXJUaW50e24xO24xO24yO24xO24zO24xO31zMTE6dGFwcGVkQ29sb3J7bjE7bjAuNTtuMjtuMC41O24zO24wLjU7fXM2OmdjZFBvc3M0OmxlZnRzNzp0ZXh0dXJlczM3OkludGVyZmFjZVxBZGRPbnNcR2xhZGR5XEltYWdlc1xTbW9vdGhzMTE6aGVhbGVyRW5lbXl0czY6dG90ZW1YbjA7czg6c2hvd05hbWV0czEyOmhvc3RpbGVDb2xvcntuMTtuMC44NTtuMjtuMC4yO24zO24wLjI7fXM4OnN0YWNraW5nZnMxNTpzaG93SW50ZXJydXB0ZXJ0czg6cGFydHlJRHN0czY6dGZDYXN0dHMxMTpmb250T3V0bGluZXMxMjpUSElDS09VVExJTkVzODpsYW5ndWFnZXM0OmF1dG9zMTA6ZGVidWZmQ2F0c3tzNzpkaXNhcm1zdHMxMDpvZmZlbnNpdmVzdHMyOmNjdHMxMDpkZWZlbnNpdmVzdHM3OnNpbGVuY2V0czU6cm9vdHN0czEwOmltbXVuaXRpZXN0czY6b3RoZXJzdH1zMTM6aGVhbHRoSGlkZU1heGZzMTI6aGVhbGVyRW5lbXlYbjA7czEyOmNhc3RJY29uU2l6ZW4xNDtzMTI6c2hvd0Nhc3RUZXh0ZnMxMjpnY2RIaWRlU3dlZXBmczExOnNoYWRvd0FscGhhbjAuNjtzODpmb250U2l6ZW4yMDtzMTA6Ym9yZGVyU2l6ZW4xLjU7czE3Om1vZE5vblRhcmdldEFscGhhdHM4OnN0YWNrR2FwbjI7czEyOmN1c3RvbVNwZWxsc3t9czQ6Z2NkWG4wO3M5OmJhcmxlc3NCR24wO3M5OmNhc3RDb2xvcntuMTtuMTtuMjtuMC43O24zO24wO31zMTI6ZGVidWZmSGVpZ2h0bjMwO3MxMTpkZWJ1ZmZUaW1lcnRzOTp0b3RlbVNpemVuMjQ7czEwOmJvcmRlclRpbnR7bjE7bjE7bjI7bjE7bjM7bjE7fXMxMTpsZXZlbE9mZnNldG44O3MxMjpib3NzSWNvblNpemVuMTM7czY6dG90ZW1ze24yMDYyO3tzNDppY29uczA6czQ6bW9kZW4xO319czU6Y2FzdFluLTM7czE1OmhlYWxlckVuZW15U2l6ZW4xODtzMjA6YmFybGVzc0V4Y2x1ZGVUYXJnZXR0czc6b2Zmc2V0WG4tNTtzMTE6Ym9yZGVyQ29sb3J7bjE7bjA7bjI7bjA7bjM7bjA7bjQ7bjE7fXMxMjpwaXhlbFBlcmZlY3R0czE0OmRlYnVmZkxvY2tvdXRzdHM3OmRlYnVmZlhuLTI4O3MxMTpjbGFtcFRhcmdldHRzODpzaG93Q2FzdHRzMTg6ZnJpZW5kbHlDbGFzc0NvbG9yZnM1OnNoYXBlczM6b2xkczk6Y2xhc3NJY29udHMxMjpjYXN0Rm9udFNpemVuMTI7czk6ZGVidWZmUG9zczU6cmlnaHRzNzpiZ0FscGhhbjAuODU7czU6c2NhbGVuMC44O3M4OnN0YWNrTWF4bjgwO3MxMDpnY2RSZXZlcnNlZnMxMDppY29uQm9yZGVyczg6YmxpenphcmRzMTU6aGVhbGVyUGFydHlTaXplbjE4O3MxNTpkZWJ1ZmZFbmVteU9ubHl0czEyOmhlYWx0aEZvcm1hdG4xO3MxMTpjbGFzc0NvbG9yc3tzMTE6REVBVEhLTklHSFR7bjE7bjAuNzc7bjI7bjAuMTI7bjM7bjAuMjM7fXM3OldBUlJJT1J7bjE7bjAuNzg7bjI7bjAuNjE7bjM7bjAuNDM7fXM3OlBBTEFESU57bjE7bjAuOTY7bjI7bjAuNTU7bjM7bjAuNzM7fXM0Ok1BR0V7bjE7bjAuNDE7bjI7bjAuODtuMztuMC45NDt9czY6UFJJRVNUe24xO24xO24yO24xO24zO24xO31zNzpXQVJMT0NLe24xO24wLjU4O24yO24wLjUxO24zO24wLjc5O31zNjpIVU5URVJ7bjE7bjAuNjc7bjI7bjAuODM7bjM7bjAuNDU7fXM1OkRSVUlEe24xO24xO24yO24wLjQ5O24zO24wLjA0O31zNTpST0dVRXtuMTtuMTtuMjtuMC45NjtuMztuMC40MTt9czY6U0hBTUFOe24xO24wO24yO24wLjQ0O24zO24wLjg3O319czExOmNsYW1wTWFyZ2lubjM1O3M5OnRleHRDb2xvcntuMTtuMTtuMjtuMTtuMztuMTt9czIzOmNhc3RQcm90ZWN0ZWRCb3JkZXJUaW50e24xO24xO24yO24xO24zO24xO31zNzpkZWJ1ZmZzdHM4OmdjZEFscGhhbjE7czE0Om5vblRhcmdldEFscGhhbjAuOTk7czE0OmNhc3RCb3JkZXJUaW50e24xO24xO24yO24xO24zO24xO31zNTpuYW1lWW4yO3MxNDpzaG93SGVhbHRoVGV4dGZzMTI6YmFybGVzc0FyZW5hbjA7czEyOmhlYWxlckVuZW15WW4wO3MxMTpoZWFsZXJQYXJ0eXRzMTQ6c3BlbGxPdmVycmlkZXN7fXMxNTpkZWJ1ZmZBcmVuYU9ubHlmczEzOmxldmVsRm9udFNpemVuMTY7czM6Z2NkZnMxMjpoZWFsZXJQYXJ0eVhuMDtzOTpnY2RIZWlnaHRuMTg7czY6aGVpZ2h0bjEyO3M5OmNhc3RTcGFya3RzOTpzaG93TGV2ZWxmczEyOmhlYWxlclBhcnR5WW4wO3MxMjpzaG93Q2FzdFRpbWV0czEzOmZyaWVuZGx5Q29sb3J7bjE7bjAuMjtuMjtuMC44O24zO24wLjM7fXMxMDpkZWJ1ZmZTaXplbjMwO3MxMTp0YXJnZXRTY2FsZW4xLjE7czEwOnRvdGVtSWNvbnN0czE3OnRhcmdldEJvcmRlckNvbG9ye24xO24xO24yO24xO24zO24xO240O24wLjk7fXM3OmJnQ29sb3J7bjE7bjAuMDU7bjI7bjAuMDU7bjM7bjAuMDU7bjQ7bjAuODU7fXMxMTpkZWJ1ZmZXaWR0aG4zMDtzNzpkZWJ1ZmZZbjA7czEyOnNob3dDYXN0SWNvbnRzMjA6Y2FzdE5vSW50ZXJydXB0Q29sb3J7bjE7bjAuNjtuMjtuMC42O24zO24wLjY7fXMxMDpzaGFkb3dTaXplbjQ7czEwOmNhc3RIZWlnaHRuMTI7czg6Z2NkV2lkdGhuMTg7czE3OmNhc3RJbnRlcnJ1cHRIb2xkbjE7czEzOmNsYXNzSWNvblNpemVuMTk7czE2OmhvdmVyQm9yZGVyQ29sb3J7bjE7bjE7bjI7bjE7bjM7bjE7bjQ7bjAuNTt9czc6Z2NkU2l6ZW4yMjtzMTA6YmFybGVzc1B2RW4wO3MxMDpzdGFja1NwZWVkbjEyO3M1OndpZHRobjEyODtzMTI6bmV1dHJhbENvbG9ye24xO24wLjk1O24yO24wLjg1O24zO24wLjI7fXMxNzp0b3RlbUhpZGVGcmllbmRseWZzODpnY2RUaW1lcnRzNjp0b3RlbVluMDtzMTE6aGVhbHRoVHJhaWx0czEwOmFyZW5hSURQb3NzNDpuYW1lczE1OnRvdGVtUGxhdGVTY2FsZW4xO30="

SP.PRESETS = {
	{ id = "arena_mark", name = "Arena: aliados con marca",
		desc = "Rivales con placa completa. Tu equipo sin barra: nombre grande con su color y el icono de su clase encima.",
		set = { barlessArena = 2, allyMarker = true, targetScale = 1.2,
			debuffWidth = 32, debuffHeight = 32, healerEnemySize = 20 } },
	{ id = "arena_both", name = "Arena: placas en ambos",
		desc = "Rivales y tu equipo con placa. Los aliados salen en azul y algo mas pequenos.",
		set = { barlessArena = 0, friendlyScale = 0.85, targetScale = 1.2 } },
	{ id = "blizzard", name = "Blizzard clasico",
		desc = "El marco dorado de siempre para todos, mejorado.",
		set = { shape = "old", classIcon = false, shadow = false, barlessArena = 0 } },
	{ id = "minimal", name = "Minimalista",
		desc = "Barras finas para los rivales y solo el nombre para tu equipo.",
		set = { width = 110, height = 7, castHeight = 10, fontSize = 10, castFontSize = 7, showLevel = false,
			classIcon = false, shadow = false, healthTrail = false, barlessArena = 3,
			debuffWidth = 24, debuffHeight = 24, gcdWidth = 22, gcdHeight = 22 } },
	{ id = "bg", name = "Campos de batalla", zone = "bg",
		desc = "Para muchas placas: aliados solo con nombre, placas mas pequenas y menos efectos.",
		set = { scale = 0.9, barlessBG = 3, friendlyScale = 0.75, nonTargetAlpha = 0.5,
			healthTrail = false, gcd = false } },
	{ id = "hemswork", name = "Perfil de Hemswork",
		desc = "La configuracion que usa Hemswork, el autor del addon.",
		import = HEMSWORK_PROFILE },
}

local function Copy(v)
	if type(v) ~= "table" then return v end
	local t = {}
	for k, x in pairs(v) do t[k] = Copy(x) end
	return t
end

-- un perfil puede usar la textura de otro addon (Gladdy): si no lo tienes, la de Blizzard
local function FixTexture(c)
	if type(c.texture) == "string" and string.find(c.texture, "Gladdy", 1, true)
		and not (IsAddOnLoaded and IsAddOnLoaded("Gladdy")) then
		c.texture = SP.defaults.texture
	end
end

-- la configuracion completa de un perfil (para su vista previa), sin aplicarlo
local presetCfg = {}
function SP.PresetConfig(p)
	if presetCfg[p.id] then return presetCfg[p.id] end
	local c = Copy(SP.defaults)
	if p.import then
		local t = SP.DecodeProfile(p.import)
		for k, v in pairs(t or {}) do
			local d = SP.defaults[k]
			if d ~= nil and type(d) == type(v) then c[k] = Copy(v) end
		end
	else
		for k, v in pairs(p.set) do c[k] = Copy(v) end
	end
	c.previewZone = p.zone -- la vista previa del aliado mira esta zona (arena por defecto)
	FixTexture(c)
	presetCfg[p.id] = c
	return c
end

function SP.ApplyPreset(id)
	local preset
	for _, p in ipairs(SP.PRESETS) do if p.id == id then preset = p end end
	if not preset then return end
	local cfg = SP.cfg
	local keep = { "language", "setupDone", "spellOverrides", "customSpells", "totems" }
	local saved = {}
	for _, k in ipairs(keep) do saved[k] = cfg[k] end
	if preset.import then
		SP.ImportProfile(preset.import)
	else
		SP.Reset()
		for k, v in pairs(preset.set) do cfg[k] = Copy(v) end
	end
	for _, k in ipairs(keep) do if saved[k] ~= nil then cfg[k] = saved[k] end end
	FixTexture(cfg)
	if SP.DebuffsChanged then SP.DebuffsChanged() end
	Apply()
	cfg.activePreset = preset.id
	for _, w in ipairs(widgets) do w:Refresh() end
	UpdateDeps()
	if RefreshCards then RefreshCards() end
end

StaticPopupDialogs["HEMSWORKPLATES_PRESET"] = {
	text = "%s", button1 = YES, button2 = NO,
	OnAccept = function(self, data) SP.ApplyPreset(data) end,
	timeout = 0, whileDead = 1, hideOnEscape = 1,
}

local function AskPreset(p)
	local d = StaticPopup_Show("HEMSWORKPLATES_PRESET",
		string.format(T("Aplicar el perfil \"%s\"? Tus ajustes actuales se reemplazan (puedes exportarlos antes en Perfiles)."), T(p.name)))
	if d then d.data = p.id end
end

-- tarjeta de un perfil: vista previa (rival arriba, tu equipo abajo), nombre
-- y si esta en uso. Se aplica pulsando la tarjeta; la descripcion va en el tooltip
local CARD_W, CARD_H = 166, 150
local allCards = {}

function RefreshCards()
	for _, c in ipairs(allCards) do c:UpdateStatus() end
end

local function ProfileCard(parent, p, onClick)
	local card = CreateFrame("Button", nil, parent)
	card:SetWidth(CARD_W)
	card:SetHeight(CARD_H)
	Skin(card, PANEL)

	local zone = CreateFrame("Frame", nil, card)
	zone:SetPoint("TOPLEFT", 4, -4)
	zone:SetPoint("TOPRIGHT", -4, -4)
	zone:SetHeight(100)
	local bg = zone:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(0.02, 0.02, 0.025, 1)
	zone:SetScript("OnShow", function(self)
		if not self.enemy then
			local c = SP.PresetConfig(p)
			self.enemy = SP.NewPreview(self, "enemy", c, 0.7, true)
			self.enemy:SetPoint("CENTER", self, "CENTER", 0, 26)
			self.ally = SP.NewPreview(self, "ally", c, 0.7, true)
			self.ally:SetPoint("CENTER", self, "CENTER", 0, -50)
		end
		SP.PaintPreview(self.enemy)
		SP.PaintPreview(self.ally)
	end)

	card.title = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	card.title:SetPoint("BOTTOMLEFT", 8, 24)
	card.title:SetWidth(CARD_W - 16)
	card.title:SetJustifyH("LEFT")
	card.title:SetText(T(p.name))
	card.status = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	card.status:SetPoint("BOTTOMLEFT", 8, 9)

	function card:UpdateStatus()
		if SP.cfg and SP.cfg.activePreset == p.id then
			self.status:SetText(T("En uso"))
			self.status:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
			self:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		else
			self.status:SetText(T("Clic para aplicar"))
			self.status:SetTextColor(0.5, 0.5, 0.5)
			self:SetBackdropBorderColor(EDGE[1], EDGE[2], EDGE[3], EDGE[4])
		end
	end
	card:SetScript("OnClick", function() onClick(p, card) end)
	card:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(T(p.name), ACCENT[1], ACCENT[2], ACCENT[3])
		GameTooltip:AddLine(T(p.desc), 1, 1, 1, true)
		GameTooltip:Show()
	end)
	card:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:UpdateStatus()
	end)
	card:SetScript("OnShow", function(self) self:UpdateStatus() end)
	card:UpdateStatus()
	allCards[#allCards + 1] = card
	return card
end

-- coloca las tarjetas en filas de 3 desde (x, y) de parent; devuelve el alto usado
local function CardGrid(parent, x, y, onClick, each)
	for i, p in ipairs(SP.PRESETS) do
		local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
		local card = ProfileCard(parent, p, onClick)
		card:SetPoint("TOPLEFT", x + col * (CARD_W + 8), y - row * (CARD_H + 8))
		if each then each(card, p, y - row * (CARD_H + 8)) end
	end
	return math.ceil(#SP.PRESETS / 3) * (CARD_H + 8)
end

local function BuildHomePage(L)
	L:Title(T("Perfiles"))
	L:Note(T("Pulsa un perfil para aplicarlo. Pasa el raton por encima para ver de que va."))
	local used = CardGrid(L.cur, 12, L.y, AskPreset, function(card, p, y)
		AddIndex(L, T(p.name), p.desc, y, "card")
	end)
	L.y = L.y - used

	L:Header(T("Tu configuracion"))
	L:Button(T("Importar / exportar perfil"), function() SP.ShowProfiles() end,
		"Copia tu configuracion como texto para pasarla a otro personaje o cuenta, o pega la de otra persona.")
	L:Button(T("Restablecer todo"), function()
		SP.Reset()
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateDeps()
		RefreshCards()
	end, "Vuelve todas las opciones a sus valores por defecto.")

	L:Header(T("Ayuda"))
	L:Button(T("Asistente de configuracion"), function() SP.ShowWizard() end,
		"Tres pasos: idioma, perfil y tamano. Lo puedes repetir cuando quieras con /hms setup.")
	L:Button(T("Probar en mi target"), function() SP.TestTarget() end,
		"Muestra durante 8 s un cast, un debuff, el GCD y la cruz de healer en la placa de tu target, para ver donde queda todo.")
end

-- menu: las secciones de arriba y, abajo y mas discretas, las de listas y avanzado
local SECTIONS = {
	{ "Perfiles", BuildHomePage },
	{ "Placa", BuildPlatePage },
	{ "Castbar", BuildCastPage },
	{ "Iconos", BuildIconsPage },
	{ "Arena y grupo", BuildArenaPage },
	{ "Colores", BuildColorsPage },
	{ "Hechizos", BuildSpellsPage, flat = true, bottom = true },
	{ "Totems", BuildTotemsPage, flat = true, bottom = true },
	{ "Avanzado", BuildAdvancedPage, bottom = true },
}

local SIDE_W, W, H = 150, 720, 560

-- quita mayusculas, acentos y codigos de color para comparar al buscar
local ACCENTS = { ["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u", ["ñ"] = "n", ["ü"] = "u",
	["Á"] = "a", ["É"] = "e", ["Í"] = "i", ["Ó"] = "o", ["Ú"] = "u", ["Ñ"] = "n" }
local function Norm(s)
	s = string.gsub(s or "", "|c%x%x%x%x%x%x%x%x", "")
	s = string.gsub(s, "|r", "")
	s = string.gsub(s, "|T.-|t", "")
	for a, b in pairs(ACCENTS) do s = string.gsub(s, a, b) end
	return strlower(s)
end

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

	-- barra de titulo, se arrastra desde aqui
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

	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", SIDE_W + 2, -32)
	content:SetPoint("BOTTOMRIGHT", -2, 2)

	local pages, buttons, scrolls = {}, {}, {}
	local results
	local function Paint(b, on)
		if on then
			b.mark:Show()
			b.bg:SetTexture(1, 1, 1, 0.07)
			b.text:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
		else
			b.mark:Hide()
			b.bg:SetTexture(0, 0, 0, 0)
			if b.bottom then b.text:SetTextColor(0.55, 0.55, 0.55) else b.text:SetTextColor(0.85, 0.85, 0.85) end
		end
	end
	local function Select(i)
		for j, pg in ipairs(pages) do
			if j == i then pg:Show() else pg:Hide() end
			Paint(buttons[j], j == i)
		end
		if results then results:Hide() end
		frame.selected = i
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateDeps()
	end

	-- buscador, encima de las secciones
	local search = CreateFrame("EditBox", UName(), side, "InputBoxTemplate")
	search:SetPoint("TOPLEFT", 14, -8)
	search:SetPoint("TOPRIGHT", -8, -8)
	search:SetHeight(20)
	search:SetAutoFocus(false)
	search:SetFontObject("GameFontHighlightSmall")
	local ph = search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	ph:SetPoint("LEFT", 2, 0)
	ph:SetText(T("Buscar opcion..."))
	search:SetScript("OnEditFocusGained", function() ph:Hide() end)
	search:SetScript("OnEditFocusLost", function(self) if (self:GetText() or "") == "" then ph:Show() end end)
	search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)

	-- separador antes de las secciones de abajo
	local nBottom = 0
	for _, def in ipairs(SECTIONS) do if def.bottom then nBottom = nBottom + 1 end end
	local sep = side:CreateTexture(nil, "ARTWORK")
	sep:SetHeight(1)
	sep:SetPoint("BOTTOMLEFT", 12, 12 + nBottom * 24)
	sep:SetPoint("BOTTOMRIGHT", -12, 12 + nBottom * 24)
	sep:SetTexture(EDGE[1], EDGE[2], EDGE[3], 1)

	local top, low = 0, 0
	for i, def in ipairs(SECTIONS) do
		local b = CreateFrame("Button", nil, side)
		b.bottom = def.bottom
		if def.bottom then
			low = low + 1
			b:SetHeight(22)
			b:SetPoint("BOTTOMLEFT", 0, 8 + (nBottom - low) * 24)
			b:SetPoint("BOTTOMRIGHT", -1, 8 + (nBottom - low) * 24)
		else
			top = top + 1
			b:SetHeight(28)
			b:SetPoint("TOPLEFT", 0, -36 - (top - 1) * 30)
			b:SetPoint("TOPRIGHT", -1, -36 - (top - 1) * 30)
		end
		b.bg = b:CreateTexture(nil, "BACKGROUND")
		b.bg:SetAllPoints()
		b.mark = b:CreateTexture(nil, "ARTWORK")
		b.mark:SetPoint("TOPLEFT")
		b.mark:SetPoint("BOTTOMLEFT")
		b.mark:SetWidth(3)
		b.mark:SetTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		b.text = b:CreateFontString(nil, "OVERLAY", def.bottom and "GameFontNormalSmall" or "GameFontNormal")
		b.text:SetPoint("LEFT", 16, 0)
		b.text:SetText(T(def[1]))
		local hl = b:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetTexture(1, 1, 1, 0.05)
		b:SetScript("OnClick", function() Select(i) end)
		buttons[i] = b

		curSec = i
		local pg = CreateFrame("Frame", nil, content)
		pg:SetAllPoints(content)
		if def.flat then
			-- Hechizos y Totems: la pagina entera, con su propia lista
			def[2](NewLayout(pg, true))
		else
			local sf = CreateFrame("ScrollFrame", UName(), pg, "UIPanelScrollFrameTemplate")
			sf:SetPoint("TOPLEFT", 0, -4)
			sf:SetPoint("BOTTOMRIGHT", -26, 4)
			local page = CreateFrame("Frame", nil, sf)
			page:SetWidth(CW)
			sf:SetScrollChild(page)
			local L = NewLayout(page)
			-- si todo cabe, sin barra de scroll (se mira al abrir y al plegar/desplegar)
			local sbar = _G[sf:GetName() .. "ScrollBar"]
			local function FitBar()
				if sbar then
					if page:GetHeight() <= sf:GetHeight() then sbar:Hide() else sbar:Show() end
				end
			end
			L.onResize = FitBar
			def[2](L)
			L:Height()
			sf:SetScript("OnShow", FitBar)
			scrolls[i] = sf
		end
		pages[i] = pg
	end
	curSec = nil

	-- resultados de la busqueda: una lista de "Seccion > Opcion"
	results = CreateFrame("Frame", nil, content)
	results:SetAllPoints(content)
	results:Hide()
	local rsf = CreateFrame("ScrollFrame", UName(), results, "UIPanelScrollFrameTemplate")
	rsf:SetPoint("TOPLEFT", 0, -4)
	rsf:SetPoint("BOTTOMRIGHT", -26, 4)
	local rlist = CreateFrame("Frame", nil, rsf)
	rlist:SetWidth(CW)
	rlist:SetHeight(10)
	rsf:SetScrollChild(rlist)
	local rtitle = rlist:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	rtitle:SetPoint("TOPLEFT", 12, -10)
	rtitle:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
	local rows = {}

	-- brillo que marca la opcion encontrada
	local flash = CreateFrame("Frame", nil, frame)
	flash:Hide()
	flash:SetScript("OnUpdate", function(self, dt)
		self.t = self.t - dt
		if self.t <= 0 then self.tex:Hide(); self:Hide() return end
		self.tex:SetAlpha(0.3 * self.t / 1.5)
	end)

	local function GoTo(e)
		Select(e.sec)
		-- si esta dentro de "Mas opciones", se despliega primero
		local g = e.block.group
		if g and not g.open then
			g.open = true
			g:Update()
			e.L:Relayout()
		end
		local sf = scrolls[e.sec]
		if sf then
			local maxS = sf:GetVerticalScrollRange() or 0
			sf:SetVerticalScroll(math.max(0, math.min(maxS, -((e.block.top or 0) + e.y) - 40)))
		end
		if not e.block.flashTex then
			e.block.flashTex = e.block:CreateTexture(nil, "BACKGROUND")
			e.block.flashTex:SetTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		end
		local t = e.block.flashTex
		t:ClearAllPoints()
		t:SetPoint("TOPLEFT", 8, e.y)
		t:SetWidth(CW - 16)
		t:SetHeight(e.kind == "card" and CARD_H or e.kind == "header" and 24 or ROW_H)
		t:Show()
		flash.tex, flash.t = t, 1.5
		flash:Show()
	end

	local ignore
	local function ShowResults(q)
		local hits, seen = {}, {}
		for pass = 1, 2 do
			for _, e in ipairs(INDEX) do
				local key = e.sec .. ":" .. e.label
				local hay = pass == 1 and Norm(e.label) or Norm(e.tip)
				if not seen[key] and string.find(hay, q, 1, true) then
					seen[key] = true
					hits[#hits + 1] = e
				end
			end
		end
		for _, pg in ipairs(pages) do pg:Hide() end
		for _, b in ipairs(buttons) do Paint(b, false) end
		rtitle:SetText(#hits > 0 and string.format(T("%d resultados"), #hits) or T("No hay opciones con ese nombre"))
		for i = 1, math.max(#hits, #rows) do
			local e, r = hits[i], rows[i]
			if e and not r then
				r = CreateFrame("Button", nil, rlist)
				r:SetHeight(20)
				r:SetPoint("TOPLEFT", 8, -32 - (i - 1) * 22)
				r:SetPoint("TOPRIGHT", -8, -32 - (i - 1) * 22)
				r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				r.text:SetPoint("LEFT", 6, 0)
				r.text:SetPoint("RIGHT", -6, 0)
				r.text:SetJustifyH("LEFT")
				local hl = r:CreateTexture(nil, "HIGHLIGHT")
				hl:SetAllPoints()
				hl:SetTexture(1, 1, 1, 0.08)
				r:SetScript("OnClick", function(self)
					ignore = true
					search:SetText("")
					search:ClearFocus()
					ignore = nil
					GoTo(self.e)
				end)
				rows[i] = r
			end
			if e then
				r.e = e
				r.text:SetText("|cffffc833" .. T(SECTIONS[e.sec][1]) .. "|r  >  " .. e.label)
				r:Show()
			elseif r then
				r:Hide()
			end
		end
		rlist:SetHeight(40 + #hits * 22)
		results:Show()
	end

	search:SetScript("OnTextChanged", function(self)
		if ignore then return end
		local q = Norm(self:GetText())
		if #q >= 2 then
			ShowResults(q)
		elseif results:IsShown() then
			Select(frame.selected or 1)
		end
	end)

	frame:SetScript("OnShow", function()
		for _, w in ipairs(widgets) do w:Refresh() end
		UpdateDeps()
		RefreshCards()
	end)
	Select(1)
	-- los frames nacen visibles; lo escondo para que el primer /hms lo abra
	frame:Hide()
end

function SP.ToggleConfig()
	if not SP.cfg then return end
	if not frame then BuildFrame() end
	if frame:IsShown() then frame:Hide() else frame:Show() end
end

function SP.OpenConfig()
	if not SP.cfg then return end
	if not frame then BuildFrame() end
	frame:Show()
end

------------------------------ ASISTENTE ----------------------------
-- tres pasos (idioma, perfil y tamano) la primera vez que se entra con el
-- addon, o con /hms setup. Los textos se rehacen si cambias el idioma.
local wizard
local SIZE_OPTIONS = { { "Pequeno", 0.85 }, { "Mediano", 1 }, { "Grande", 1.2 } }

function SP.ShowWizard()
	if not SP.cfg then return end
	if wizard then wizard.Go(1); wizard:Show() return end
	local f = CreateFrame("Frame", "HemsworkPlatesWizard", UIParent)
	f:SetWidth(560)
	f:SetHeight(470)
	f:SetPoint("CENTER")
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetToplevel(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	Skin(f)
	tinsert(UISpecialFrames, "HemsworkPlatesWizard")

	local labels = {} -- { fontstring o boton, texto en espanol }
	local function Label(obj, key) labels[#labels + 1] = { obj, key }; obj:SetText(T(key)) end
	local function Relabel()
		for _, l in ipairs(labels) do l[1]:SetText(T(l[2])) end
		RefreshCards()
	end

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -14)
	title:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
	Label(title, "Configuracion rapida")
	local stepText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	stepText:SetPoint("TOP", 0, -36)
	local ask = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ask:SetPoint("TOP", 0, -56)
	ask:SetWidth(520)

	local steps = {}
	local function StepBox()
		local box = CreateFrame("Frame", nil, f)
		box:SetPoint("TOPLEFT", 20, -80)
		box:SetPoint("BOTTOMRIGHT", -20, 48)
		box:Hide()
		steps[#steps + 1] = box
		return box
	end
	local function Choices(list, onPick)
		local box = StepBox()
		local buttons = {}
		for i, o in ipairs(list) do
			local b = FlatButton(box, 220, 26, "")
			b:SetPoint("TOP", 0, -(i - 1) * 30)
			Label(b, o.name)
			b:SetScript("OnClick", function()
				for _, x in ipairs(buttons) do x:SetBackdropBorderColor(EDGE[1], EDGE[2], EDGE[3], EDGE[4]) end
				b:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
				onPick(o)
			end)
			buttons[i] = b
		end
	end

	Choices({ { name = "Español", value = "es" }, { name = "English", value = "en" }, { name = "Automatico", value = "auto" } },
		function(o)
			SP.cfg.language = o.value
			if SP.UpdateLanguage then SP.UpdateLanguage() end
			Relabel()
			f.Go(1)
			Apply()
		end)

	-- paso 2: las mismas tarjetas que en Perfiles; aqui se aplican sin preguntar
	local box = StepBox()
	CardGrid(box, 4, 0, function(p) SP.ApplyPreset(p.id) end, function(card, p) Label(card.title, p.name) end)

	local sizeList = {}
	for _, s in ipairs(SIZE_OPTIONS) do sizeList[#sizeList + 1] = { name = s[1], value = s[2] } end
	Choices(sizeList, function(o)
		SP.cfg.scale = o.value
		Apply()
	end)

	local ASK = { "Elige el idioma", "Elige un perfil para empezar", "Elige el tamano de las placas" }
	local back = FlatButton(f, 100, 24, "")
	local nextB = FlatButton(f, 120, 24, "")
	local skip = FlatButton(f, 100, 24, "")
	back:SetPoint("BOTTOMLEFT", 14, 12)
	skip:SetPoint("BOTTOM", 0, 12)
	nextB:SetPoint("BOTTOMRIGHT", -14, 12)
	Label(back, "Atras")
	Label(skip, "Saltar")

	local cur = 1
	local function Finish()
		SP.cfg.setupDone = true
		f:Hide()
		DEFAULT_CHAT_FRAME:AddMessage(T("|cff66ccffHemsworkPlates:|r listo. Escribe /hms para cambiar lo que quieras o /hms setup para repetir el asistente."))
	end
	function f.Go(n)
		cur = n
		for i, s in ipairs(steps) do if i == n then s:Show() else s:Hide() end end
		stepText:SetText(string.format(T("Paso %d de %d"), n, #steps))
		ask:SetText(T(ASK[n]))
		nextB:SetText(T(n == #steps and "Terminar" or "Siguiente"))
		if n == 1 then back:Hide() else back:Show() end
	end
	back:SetScript("OnClick", function() if cur > 1 then f.Go(cur - 1) end end)
	nextB:SetScript("OnClick", function() if cur < #steps then f.Go(cur + 1) else Finish() end end)
	skip:SetScript("OnClick", Finish)
	f:SetScript("OnHide", function() SP.cfg.setupDone = true end)

	wizard = f
	f.Go(1)
	f:Show()
end

-- la primera vez: el asistente sale unos segundos despues de entrar al juego
local starter = CreateFrame("Frame")
starter:RegisterEvent("PLAYER_ENTERING_WORLD")
starter:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if not SP.cfg or SP.cfg.setupDone then return end
	local wait = 3
	self:SetScript("OnUpdate", function(s, dt)
		wait = wait - dt
		if wait > 0 then return end
		s:SetScript("OnUpdate", nil)
		if not SP.cfg.setupDone and not InCombatLockdown() then SP.ShowWizard() end
	end)
end)

------------------------- MENU DE INTERFAZ --------------------------
-- entrada en Esc > Interfaz > AddOns que lleva al panel propio
local iop = CreateFrame("Frame", "HemsworkPlatesInterfacePanel", InterfaceOptionsFramePanelContainer or UIParent)
iop.name = "HemsworkPlates"
iop:Hide()
iop:SetScript("OnShow", function(self)
	if self.built then return end
	self.built = true
	local t = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	t:SetPoint("TOPLEFT", 16, -16)
	t:SetText("HemsworkPlates")
	local d = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -10)
	d:SetWidth(380)
	d:SetJustifyH("LEFT")
	d:SetText(T("Las opciones de HemsworkPlates estan en su propia ventana."))
	local function Btn(text, y, onClick)
		local b = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		b:SetWidth(220)
		b:SetHeight(24)
		b:SetPoint("TOPLEFT", 16, y)
		b:SetText(text)
		b:SetScript("OnClick", function()
			if InterfaceOptionsFrame then InterfaceOptionsFrame:Hide() end
			if GameMenuFrame and GameMenuFrame:IsShown() then HideUIPanel(GameMenuFrame) end
			onClick()
		end)
	end
	Btn(T("Abrir opciones"), -80, SP.OpenConfig)
	Btn(T("Asistente de configuracion"), -110, SP.ShowWizard)
	local c = self:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	c:SetPoint("TOPLEFT", 16, -150)
	c:SetWidth(380)
	c:SetJustifyH("LEFT")
	c:SetText(T("Comandos: /hms abre las opciones, /hms setup el asistente y /hms test prueba los iconos en tu target."))
end)
if InterfaceOptions_AddCategory then InterfaceOptions_AddCategory(iop) end
