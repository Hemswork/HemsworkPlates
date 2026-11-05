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
	["Ancho cast bar"] = "Castbar width",
	["Mover cast bar arriba/abajo"] = "Move castbar up/down",
	["Escala"] = "Scale",
	["Opacidad sin target"] = "Non-target opacity",
	["Modificar opacidad sin target"] = "Override non-target opacity",
	["Sustituye la opacidad del juego en las placas que no son tu target (solo cuando tienes un target). Desactivado: se usa la del juego."] =
		"Replaces the game's opacity on plates that are not your target (only while you have a target). Off: the game's own opacity is used.",
	["De 0% (invisibles) a 99% (casi sin transparencia). Puedes escribir el valor exacto."] =
		"From 0% (invisible) to 99% (almost no transparency). You can type the exact value.",
	["Ancho del nombre"] = "Name width",
	["Hechizos"] = "Spells",
	["Hechizos de los debuffs"] = "Debuff spells",
	["Marca los que quieres ver, cambia su categoria o prioridad, o anade los tuyos por ID. La categoria manda; dentro de ella gana la prioridad mas alta."] = "Tick the ones you want to see, change their category or priority, or add your own by ID. Category comes first; within it the highest priority wins.",
	["Categoria"] = "Category",
	["Todas"] = "All",
	["Buscar"] = "Search",
	["Anadir ID"] = "Add ID",
	["Anadir"] = "Add",
	["anadido en"] = "added to",
	["ID de hechizo no valido"] = "Invalid spell ID",
	["Hechizo"] = "Spell",
	["Ver"] = "Show",
	["Prioridad"] = "Priority",
	["Quitar de la lista"] = "Remove from list",
	["Volver al valor original"] = "Back to the original value",
	["Pulsa para filtrar la lista por categoria."] = "Click to filter the list by category.",
	["Busca por nombre o por ID de hechizo."] = "Search by spell name or ID.",
	["Vuelve la lista de hechizos a la original: quita tus hechizos y deshace los cambios."] = "Returns the spell list to the original: removes your spells and undoes your changes.",
	["ID del hechizo (por ejemplo el de Wowhead). Se anade en la categoria elegida a la derecha."] = "Spell ID (for example from Wowhead). It is added to the category chosen on the right.",
	["Categoria en la que se anadira el hechizo (pulsa para cambiar)."] = "Category the spell will be added to (click to change).",
	["Tamano de la calavera"] = "Skull size",
	["Calavera de Blizzard que sustituye al nivel ?? en jefes y elites sin nivel."] = "Blizzard skull that replaces the ?? level on bosses and level-less elites.",
	["Borde de los iconos"] = "Icon border",
	["Estilo del borde de iconos"] = "Icon border style",
	["Blizzard (como BigDebuffs)"] = "Blizzard (like BigDebuffs)",
	["Plano (negro)"] = "Flat (black)",
	["Borde de los iconos de debuffs, GCD, interrupciones y cast. Blizzard = el mismo marco de BigDebuffs; Plano = solo una linea negra."] =
		"Border of the debuff, GCD, interrupt and cast icons. Blizzard = the same frame BigDebuffs uses; Flat = just a black line.",
	["Tinte del borde de iconos"] = "Icon border tint",
	["Es un tinte: blanco = marco original de Blizzard; gris oscuro o negro lo oscurece."] = "This is a tint: white = original Blizzard frame; dark grey or black darkens it.",
	["Oscuridad del fondo de barra"] = "Bar background darkness",
	["Opacidad del interior de las barras (la parte vacia). 100% = fondo totalmente oscuro; baja el valor para verlo mas transparente."] =
		"Opacity of the bar interior (the empty part). 100% = fully dark background; lower it to make it more transparent.",
	["Tamano del nivel"] = "Level text size",
	["Tamano de letra del nivel (el numero junto a la barra, por ejemplo 80)."] = "Font size of the level (the number next to the bar, e.g. 80).",
	["Mover icono totem X"] = "Move totem icon X",
	["Mover icono totem Y"] = "Move totem icon Y",
	["Mueve el icono del totem en horizontal."] = "Moves the totem icon horizontally.",
	["Mueve el icono del totem en vertical."] = "Moves the totem icon vertically.",
	["Ancho maximo del nombre: si no cabe se recorta con ... para que vaya siempre en una sola fila."] =
		"Maximum name width: if it does not fit it is cut with ... so it always stays on a single row.",
	["Tinte de borde"] = "Border tint",
	["Es un tinte, no un color normal: blanco deja el borde original; gris oscuro o negro lo oscurece."] =
		"This is a tint, not a regular color: white keeps the original border; dark grey or black darkens it.",
	["Marco dorado de la barra de vida. Solo en el estilo Antiguo (Blizzard)."] = "Golden frame of the health bar. Old (Blizzard) style only.",
	["Tinte de borde del cast"] = "Castbar border tint",
	["Marco plateado del castbar. Solo en los estilos Clasico y Antiguo."] = "Silver castbar frame. Classic and Old styles only.",
	["Tinte de borde (no interrumpible)"] = "Border tint (uninterruptible)",
	["Marco con escudo del castbar cuando el hechizo no se puede interrumpir. Solo en los estilos Clasico y Antiguo."] =
		"Shielded castbar frame when the spell cannot be interrupted. Classic and Old styles only.",
	["Escala de la placa del totem"] = "Totem plate scale",
	["Agranda o achica solo las placas de los totems (modos Placa e Icono + Placa). No afecta a las demas placas."] =
		"Enlarges or shrinks only totem plates (Plate and Icon + Plate modes). Other plates are not affected.",
	["Icono + Placa"] = "Icon + Plate",
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
	["Totem                                              Modo                      Icono propio (ruta o ID de hechizo + Enter)"] =
		"Totem                                              Mode                      Custom icon (path or spell ID + Enter)",

	-- Debuffs
	["Mostrar debuffs importantes"] = "Show important debuffs",
	["Solo en enemigos"] = "Enemies only",
	["Solo en arena"] = "Arena only",
	["Tiempo restante en el icono"] = "Time remaining on icon",
	["Tamano del icono"] = "Icon size",
	["Ancho del icono"] = "Icon width",
	["Alto del icono"] = "Icon height",
	["Mover icono X"] = "Move icon X",
	["Mover icono Y"] = "Move icon Y",
	["Positivo a la derecha, negativo a la izquierda."] = "Positive moves right, negative moves left.",
	["Positivo sube, negativo baja."] = "Positive moves up, negative moves down.",
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
	["Ancho extra del castbar (se suma a la derecha). Con 0 queda el ancho original."] = "Extra castbar width (added to the right). At 0 the original width is kept.",
	["Positivo sube el castbar, negativo lo baja. Con 0 queda en su posicion original."] = "Positive moves the castbar up, negative moves it down. At 0 it stays in its original position.",
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
