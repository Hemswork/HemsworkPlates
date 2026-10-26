--------------------------------------------------------------------
-- HemsworkPlates - Idiomas (espanol / ingles)
-- Los textos se escriben en espanol en el codigo; SP.T() devuelve la
-- traduccion inglesa cuando el idioma activo es ingles.
-- Idioma: opcion "language" ("auto", "es", "en"). En "auto" se usa
-- espanol con clientes esES/esMX e ingles con cualquier otro.
--------------------------------------------------------------------
local addonName, SP = ...

local EN = {
	-- Pestanas y botones
	["General"] = "General",
	["Texto"] = "Text",
	["Colores"] = "Colors",
	["Extras"] = "Extras",
	["Totems"] = "Totems",
	["Debuffs"] = "Debuffs",
	["Restablecer todo"] = "Reset all",
	["Perfiles"] = "Profiles",
	["Cambios en vivo"] = "Changes apply live",

	-- General
	["Ancho"] = "Width",
	["Alto de barra"] = "Bar height",
	["Alto cast bar"] = "Castbar height",
	["Escala"] = "Scale",
	["Opacidad sin target"] = "Non-target opacity",
	["Tamano icono cast"] = "Cast icon size",
	["Grosor del borde"] = "Border thickness",
	["Pixel perfect (bordes nitidos)"] = "Pixel perfect (crisp borders)",
	["Forma de las barras"] = "Bar style",
	["Textura de la barra"] = "Bar texture",
	["Apilar placas (evitar solapamiento)"] = "Stack plates (avoid overlap)",
	["Separacion"] = "Spacing",
	["Velocidad de apilado"] = "Stacking speed",
	["Mostrar cast bar"] = "Show castbar",
	["Icono del hechizo"] = "Spell icon",
	["Tiempo restante del cast"] = "Cast time remaining",
	["Nombre del hechizo en el cast"] = "Spell name on castbar",
	["Mover horizontal (X)"] = "Move horizontally (X)",
	["Mover vertical (Y)"] = "Move vertically (Y)",
	["Plana"] = "Flat",
	["Clasico WotLK"] = "WotLK Classic",
	["Antiguo (Blizzard)"] = "Old (Blizzard)",
	["Cuadrada"] = "Square",
	["Redonda"] = "Round",

	-- Texto
	["Fuente"] = "Font",
	["Contorno"] = "Outline",
	["Contorno grueso"] = "Thick outline",
	["Ninguno"] = "None",
	["Ruta de fuente personalizada (Enter)"] = "Custom font path (Enter)",
	["Tamano de texto"] = "Text size",
	["Tamano texto del cast"] = "Castbar text size",
	["Separacion del nivel"] = "Level spacing",
	["Mostrar nombre"] = "Show name",
	["Mostrar nivel"] = "Show level",
	["Mostrar texto de vida"] = "Show health text",
	["Color del texto"] = "Text color",
	["Mover nombre X"] = "Move name X",
	["Mover nombre Y"] = "Move name Y",
	["Idioma / Language"] = "Language / Idioma",
	["Automatico"] = "Automatic",
	["Haz /reload para cambiar el idioma de todo el panel."] = "Type /reload to change the language of the whole panel.",

	-- Colores
	["Color de clase en jugadores"] = "Class colors on players",
	["Hostil"] = "Hostile",
	["Neutral"] = "Neutral",
	["Amistoso"] = "Friendly",
	["Tapeado por otro"] = "Tapped by others",
	["Fondo de barra"] = "Bar background",
	["Borde"] = "Border",
	["Borde del target"] = "Target border",
	["Color de cast bar"] = "Castbar color",
	["Cast no interrumpible"] = "Uninterruptible cast",
	["Cast interrumpido"] = "Interrupted cast",

	-- Extras
	["Brillo en el target"] = "Target glow",
	["Color brillo target"] = "Target glow color",
	["Intensidad brillo target"] = "Target glow intensity",
	["Brillo al pasar el raton"] = "Mouseover glow",
	["Color brillo raton"] = "Mouseover glow color",
	["Intensidad brillo raton"] = "Mouseover glow intensity",
	["Tamano del brillo"] = "Glow size",
	["Formato del texto de vida"] = "Health text format",
	["Ocultar texto con vida al maximo"] = "Hide text at full health",
	["Escala del target"] = "Target scale",
	["Escala de aliados"] = "Friendly scale",
	["Mantener target en pantalla"] = "Keep target on screen",
	["Margen superior"] = "Top margin",
	["Tiempo de 'Interrupted' (s)"] = "'Interrupted' duration (s)",
	["Mostrar quien corto el cast"] = "Show who interrupted",
	["Estilo de cast en target y focus"] = "Castbar style on target and focus",
	["Porcentaje (85%)"] = "Percent (85%)",
	["Porcentaje 1 dec. (85.3%)"] = "Percent 1 dec. (85.3%)",
	["Actual (12.5k)"] = "Current (12.5k)",
	["Actual / Max"] = "Current / Max",
	["Actual (Porc.)"] = "Current (Percent)",
	["Deficit (-2.1k)"] = "Deficit (-2.1k)",

	-- PvP
	["Numeros de arena (enemigos)"] = "Arena numbers (enemies)",
	["Numeros de grupo (aliados)"] = "Party numbers (allies)",
	["Posicion del numero de arena"] = "Arena number position",
	["A la izquierda de la barra"] = "Left of the bar",
	["En lugar del nombre"] = "Instead of the name",
	["Aliados con color de clase"] = "Allies with class colors",
	["Color de jugadores aliados"] = "Friendly player color",
	["Tamano de aliados"] = "Friendly size",
	["Aliados solo con nombre"] = "Friendly name-only plates",
	["Mundo abierto"] = "Open world",
	["Mazmorras y bandas"] = "Dungeons and raids",
	["Campos de batalla"] = "Battlegrounds",
	["Arenas"] = "Arenas",
	["Barras normales en tu target"] = "Normal bars on your target",
	["Desactivado"] = "Disabled",
	["Solo PNJs"] = "NPCs only",
	["Solo jugadores"] = "Players only",
	["Jugadores y PNJs"] = "Players and NPCs",

	-- Totems
	["Totems como icono"] = "Totems as icons",
	["Ocultar totems aliados"] = "Hide friendly totems",
	["Tamano icono totem"] = "Totem icon size",
	["Icono"] = "Icon",
	["Oculto"] = "Hidden",
	["Placa"] = "Plate",
	["Totem                                              Modo             Icono propio (ruta o ID de hechizo + Enter)"] =
		"Totem                                              Mode             Custom icon (path or spell ID + Enter)",

	-- Debuffs
	["Mostrar debuffs importantes"] = "Show important debuffs",
	["Solo en enemigos"] = "Enemies only",
	["Solo en arena"] = "Arena only",
	["Tiempo restante en el icono"] = "Time remaining on icon",
	["Tamano del icono"] = "Icon size",
	["Posicion"] = "Position",
	["A la derecha"] = "Right",
	["A la izquierda"] = "Left",
	["Categorias (por prioridad)"] = "Categories (by priority)",
	["Bloqueos de interrupcion (Pummel, Kick...)"] = "Interrupt lockouts (Pummel, Kick...)",
	["Inmunidades"] = "Immunities",
	["Control (CC)"] = "Crowd control (CC)",
	["Silencios"] = "Silences",
	["Raices"] = "Roots",
	["Desarmes"] = "Disarms",
	["Defensivos"] = "Defensives",
	["Ofensivos"] = "Offensives",
	["Otros"] = "Others",

	-- GCD
	["Mostrar GCD de enemigos de arena"] = "Show arena enemy GCDs",
	["Invertir el barrido"] = "Reverse sweep",
	["Ocultar el barrido"] = "Hide sweep",
	["Opacidad del barrido"] = "Sweep opacity",
	["Probar en mi target (15 s)"] = "Test on my target (15 s)",
	["Muestra el ultimo hechizo de cada rival de arena con un barrido que dura su GCD (clase, haste y procs instantaneos). Basado en NameplateArenaGCDs."] =
		"Shows each arena opponent's last spell with a sweep that lasts its GCD (class, haste and instant-cast procs). Based on NameplateArenaGCDs.",

	-- Perfiles
	["Perfiles: importar / exportar"] = "Profiles: import / export",
	["Exportar: copia el texto con Ctrl+C.  Importar: pegalo con Ctrl+V y pulsa Importar."] =
		"Export: copy the text with Ctrl+C.  Import: paste it with Ctrl+V and press Import.",
	["Exportar"] = "Export",
	["Importar"] = "Import",
	["Cerrar"] = "Close",
	["Texto seleccionado: pulsa Ctrl+C para copiarlo"] = "Text selected: press Ctrl+C to copy it",
	["Perfil importado y aplicado"] = "Profile imported and applied",
	["No se pudo importar: "] = "Could not import: ",
	["el texto no es un perfil de HemsworkPlates"] = "the text is not a HemsworkPlates profile",
	["el perfil esta incompleto o danado (copialo entero)"] = "the profile is incomplete or damaged (copy all of it)",

	-- Panel nuevo: secciones, bloques, notas y tooltips
	["Aspecto"] = "Look",
	["Castbar"] = "Castbar",
	["Resaltado"] = "Highlight",
	["Arena"] = "Arena",
	["GCD"] = "GCD",
	["Estilo"] = "Style",
	["Tamano"] = "Size",
	["Apilado"] = "Stacking",
	["Interrupciones"] = "Interrupts",
	["Colores del cast"] = "Castbar colors",
	["Nombre y nivel"] = "Name and level",
	["Texto de vida"] = "Health text",
	["Color de clase"] = "Class colors",
	["Reaccion"] = "Reaction",
	["Barra"] = "Bar",
	["Tu target"] = "Your target",
	["Numeros de arena"] = "Arena numbers",
	["Aliados"] = "Allies",
	["Debuffs importantes"] = "Important debuffs",
	["GCD de arena"] = "Arena GCDs",
	["Restablecer"] = "Reset",
	["Importar / exportar perfil"] = "Import / export profile",
	["Exporta tu configuracion como un texto para copiarla a otro personaje o cuenta, o importa la de otra persona."] =
		"Export your settings as text to copy them to another character or account, or import someone else's.",
	["Vuelve todas las opciones a sus valores por defecto."] = "Sets every option back to its default value.",
	["Las placas amistosas muestran solo el nombre, sin barra, en las zonas que elijas."] =
		"Friendly plates show only the name, without a bar, in the zones you choose.",
	["Ajusta tamanos y posiciones a pixeles exactos de tu pantalla para que los bordes se vean nitidos."] =
		"Snaps sizes and positions to exact screen pixels so borders look crisp.",
	["Solo en los estilos Cuadrada y Redonda."] = "Only for the Square and Round styles.",
	["Opacidad de las placas que no son tu target (solo cuando tienes un target)."] =
		"Opacity of plates that are not your target (only while you have a target).",
	["Separa las placas que se solapan. El juego ya las separa por su cuenta; activalo solo si lo prefieres."] =
		"Pushes overlapping plates apart. The game already spreads them; enable it only if you prefer it.",
	["Cuanto tiempo se queda la barra parada en rojo al cortar un cast."] = "How long the bar stays frozen in red when a cast is interrupted.",
	["Aplica el rojo de 'Interrupted' y el color de no interrumpible a los castbars de los marcos de target y focus."] =
		"Applies the red 'Interrupted' and uninterruptible colors to the target and focus frame castbars.",
	["Ruta de un archivo .ttf, por ejemplo Interface\\AddOns\\MiFuente\\fuente.ttf"] =
		"Path to a .ttf file, for example Interface\\AddOns\\MyFont\\font.ttf",
	["Con 0 el nombre queda en el centro exacto de la barra."] = "At 0 the name sits exactly centered over the bar.",
	["Automatico: espanol si tu cliente esta en espanol, ingles en cualquier otro."] =
		"Automatic: Spanish if your client is in Spanish, English for any other language.",
	["Si la placa de tu target se sale por arriba de la pantalla, se queda pegada al borde superior."] =
		"If your target's plate goes above the screen, it sticks to the top edge.",
	["Muestra 1-5 en cada rival de arena (en rojo)."] = "Shows 1-5 on each arena opponent (in red).",
	["Muestra el numero de cada companero de arena (en verde)."] = "Shows each arena teammate's number (in green).",
	["Desmarcado: tus aliados salen en un color fijo (azul) para no confundirlos con los enemigos."] =
		"Unchecked: your allies use a fixed color (blue) so they are never mixed up with enemies.",
	["Muestra en cada placa enemiga el aura mas importante segun su categoria y prioridad."] =
		"Shows the most important aura on each enemy plate, by category and priority.",
	["Pummel, Shield Bash, Kick, etc. no dejan aura: se detectan en el registro de combate y se muestran como silencio."] =
		"Pummel, Shield Bash, Kick, etc. leave no aura: they are detected from the combat log and shown as silences.",

	-- Mensajes del chat
	["|cff66ccffHemsworkPlates|r cargado: version %s (Warmane, sin Awesome WotLK)"] =
		"|cff66ccffHemsworkPlates|r loaded: version %s (Warmane, no Awesome WotLK)",
	["|cff66ccffHemsworkPlates:|r hay una version nueva (|cffffffff%s|r, tienes la %s). Descargala en |cffffffff%s|r"] =
		"|cff66ccffHemsworkPlates:|r a new version is available (|cffffffff%s|r, you have %s). Download it at |cffffffff%s|r",
	["|cff66ccffHemsworkPlates|r cargado: version 1.0.1 Warmane (sin Awesome WotLK)"] =
		"|cff66ccffHemsworkPlates|r loaded: version 1.0.1 Warmane (no Awesome WotLK)",
	["|cff66ccffHemsworkPlates|r cargado: version 1.0.1 (bloqueos de interrupcion)"] =
		"|cff66ccffHemsworkPlates|r loaded: version 1.0.1",
	["|cffff5555HemsworkPlates:|r no se encontro C_NamePlate. Requiere Awesome WotLK."] =
		"|cffff5555HemsworkPlates:|r C_NamePlate not found. Awesome WotLK is required.",
	["|cffffaa00HemsworkPlates:|r pico de %.0f ms (%s). Usa /hms perf"] = "|cffffaa00HemsworkPlates:|r %.0f ms spike (%s). Use /hms perf",
	["|cffffaa00HemsworkPlates:|r pico de %.0f ms en %s. Usa /hms perf"] = "|cffffaa00HemsworkPlates:|r %.0f ms spike in %s. Use /hms perf",
	["%d actualizaciones, %d restyle, %d placas creadas"] = "%d updates, %d restyles, %d plates built",
	[" placas creadas)"] = " plates built)",
	["HemsworkPlates: no hay placas activas, apunta a un mob cercano."] = "HemsworkPlates: no active plates, face a nearby mob.",
	["HemsworkPlates: pon de target a alguien que este casteando."] = "HemsworkPlates: target someone who is casting.",
	["  no hay barras visibles cerca de la placa"] = "  no visible bars near the plate",
	["|cff66ccffHemsworkPlates rendimiento|r ("] = "|cff66ccffHemsworkPlates performance|r (",
	[" s medidos)"] = " s measured)",
	["  Por frame: media %.2f ms, peor %.1f ms"] = "  Per frame: average %.2f ms, worst %.1f ms",
	["  En el peor frame: "] = "  In the worst frame: ",
	["  Peor evento: %.1f ms %s"] = "  Worst event: %.1f ms %s",
	["  Por segundo: %.1f actualizaciones, %.1f casts, %.2f restyle"] = "  Per second: %.1f updates, %.1f casts, %.2f restyles",
	["  Placas creadas: %d   Memoria del addon: %.0f KB"] = "  Plates built: %d   Addon memory: %.0f KB",
	["HemsworkPlates: medidor reiniciado."] = "HemsworkPlates: profiler reset.",
	["|cff66ccffHemsworkPlates geometria nativa:|r"] = "|cff66ccffHemsworkPlates native geometry:|r",
	[": sin medir (usando respaldo)"] = ": not measured (using fallback)",
	["HemsworkPlates: geometria borrada, se volvera a medir tras /reload."] = "HemsworkPlates: geometry cleared, it will be measured again after /reload.",
	["HemsworkPlates: configuracion restablecida."] = "HemsworkPlates: settings reset.",
	["|cffffaa00HemsworkPlates:|r el addon |cffffffffNamePlateArenaGCDs|r sigue activo. "] =
		"|cffffaa00HemsworkPlates:|r the |cffffffffNamePlateArenaGCDs|r addon is still enabled. ",
	["HemsworkPlates ya incluye el GCD de arena: desactivalo en la lista de AddOns para no ver los iconos dos veces."] =
		"HemsworkPlates already includes arena GCDs: disable it in the AddOns list to avoid duplicate icons.",
	["|cff66ccffHemsworkPlates:|r pon de target a alguien con placa visible."] =
		"|cff66ccffHemsworkPlates:|r target someone with a visible nameplate.",
}

local lang
function SP.UpdateLanguage()
	local pref = SP.cfg and SP.cfg.language or "auto"
	if pref == "es" or pref == "en" then
		lang = pref
	else
		local l = GetLocale()
		lang = (l == "esES" or l == "esMX") and "es" or "en"
	end
	return lang
end

function SP.T(s)
	if not lang then SP.UpdateLanguage() end
	if lang == "en" then return EN[s] or s end
	return s
end
