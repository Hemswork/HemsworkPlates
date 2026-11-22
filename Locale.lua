--------------------------------------------------------------------
-- HemsworkPlates - idiomas (espanol / ingles)
-- En el codigo todo va en espanol; SP.T() devuelve el ingles cuando toca.
-- Opcion "language": "auto", "es" o "en". Con "auto", espanol para
-- clientes esES/esMX e ingles para el resto.
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

	-- Texto
	["Fuente"] = "Font",
	["Contorno"] = "Outline",
	["Contorno grueso"] = "Thick outline",
	["Ninguno"] = "None",
	["Ruta de fuente personalizada (Enter)"] = "Custom font path (Enter)",
	["Tamano de texto"] = "Text size",
	["Tamano texto del cast"] = "Castbar text size",
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
	["Color de cast bar"] = "Castbar color",
	["Cast no interrumpible"] = "Uninterruptible cast",
	["Cast interrumpido"] = "Interrupted cast",

	-- Extras
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

	-- panel: secciones, bloques, notas y tooltips
	["Aspecto"] = "Look",
	["Castbar"] = "Castbar",
	["Target"] = "Target",
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

	-- Efectos
	["Efectos"] = "Effects",
	["Sombra suave"] = "Soft shadow",
	["Halo oscuro difuminado alrededor de la barra para separarla del fondo. No se usa en el estilo Antiguo (marco dorado)."] =
		"Soft dark halo around the bar so it stands out from the background. Not used with the Old style (golden frame).",
	["Rastro de dano"] = "Damage trail",
	["Al perder vida queda un momento un trozo claro que se encoge hasta el valor nuevo: se ve cuanto dano acaba de recibir."] =
		"When health drops, a light segment stays for a moment and shrinks to the new value, showing how much damage was just taken.",
	["Tamano de la sombra"] = "Shadow size",
	["Intensidad de la sombra"] = "Shadow strength",
	["Chispa en el cast"] = "Castbar spark",
	["Centrar sobre la cabeza"] = "Center over the head",
	["La mitad de la barra queda justo encima de la cabeza del personaje. Desactivalo para moverla en horizontal a mano."] =
		"The middle of the bar sits right above the character's head. Turn it off to move it horizontally yourself.",
	["Icono de clase"] = "Class icon",
	["Muestra el icono de la clase de los jugadores a la izquierda de la barra."] = "Shows the player's class icon on the left of the bar.",
	["Tamano del icono de clase"] = "Class icon size",
	["Separacion del icono de clase"] = "Class icon spacing",
	["Sanadores"] = "Healers",
	["Cruz verde junto al nombre de los healers. Se detectan por sus hechizos (Holy Shock, Penance, Riptide, Swiftmend...) y, si usas Gladius, tambien por su deteccion de especializacion."] =
		"Green cross next to healers' names. They are detected by their spells (Holy Shock, Penance, Riptide, Swiftmend...) and, if you use Gladius, by its spec detection too.",
	["Sanadores rivales"] = "Enemy healers",
	["Sanadores de tu grupo"] = "Party healers",
	["Tamano (rivales)"] = "Size (enemies)",
	["Tamano (grupo)"] = "Size (party)",
	["Mover X (rivales)"] = "Move X (enemies)",
	["Mover X (grupo)"] = "Move X (party)",
	["Mover Y (rivales)"] = "Move Y (enemies)",
	["Mover Y (grupo)"] = "Move Y (party)",
	["0 = pegado a la placa. Positivo lo aparta, negativo lo mete sobre el borde."] =
		"0 = touching the plate. Positive moves it away, negative moves it over the border.",
	["Linea brillante en el borde del relleno, como en la barra de Blizzard."] = "Bright line at the edge of the fill, like Blizzard's castbar.",

	-- Inicio, perfiles ya hechos, buscador, vista previa y asistente
	["Inicio"] = "Home",
	["Bienvenido"] = "Welcome",
	["Elige un perfil para empezar y ajusta lo basico aqui. El resto de opciones esta en las secciones de la izquierda, y el buscador de arriba encuentra cualquiera."] =
		"Pick a profile to start and adjust the basics here. Everything else is in the sections on the left, and the search box above finds any option.",
	["Perfiles rapidos"] = "Quick profiles",
	["Lo basico"] = "The basics",
	["Ayuda"] = "Help",
	["Blizzard clasico"] = "Classic Blizzard",
	["Minimalista"] = "Minimalist",
	["Campos de batalla"] = "Battlegrounds",
	["Para muchas placas: aliados solo con nombre, placas mas pequenas y menos efectos."] =
		"For lots of plates: name-only friends, smaller plates and fewer effects.",
	["Aplicar el perfil \"%s\"? Tus ajustes actuales se reemplazan (puedes exportarlos antes en Perfiles)."] =
		"Apply the \"%s\" profile? Your current settings will be replaced (you can export them first in Profiles).",
	["Aplicar"] = "Apply",
	["Rival"] = "Enemy",
	["Tu equipo"] = "Your team",
	["Enemigo"] = "Enemy",
	["Aliado"] = "Ally",
	["Cada perfil muestra como se ve un rival y alguien de tu equipo en arena."] =
		"Each profile shows how an enemy and someone on your team look in arena.",
	["Arena: aliados con marca"] = "Arena: marked allies",
	["Rivales con placa completa. Tu equipo sin barra: nombre grande con su color y el icono de su clase encima."] =
		"Enemies with full plates. Your team without bars: a big class-colored name with their class icon above it.",
	["Arena: placas en ambos"] = "Arena: plates on both",
	["Rivales y tu equipo con placa. Los aliados salen en azul y algo mas pequenos."] =
		"Enemies and your team with plates. Allies are blue and a bit smaller.",
	["El marco dorado de siempre para todos, mejorado."] = "The usual golden frame for everyone, improved.",
	["Barras finas para los rivales y solo el nombre para tu equipo."] = "Thin bars for enemies and just the name for your team.",
	["Perfil de Hemswork"] = "Hemswork's profile",
	["La configuracion que usa Hemswork, el autor del addon."] = "The setup used by Hemswork, the addon's author.",
	["Marca sobre tu grupo"] = "Mark your group",
	["Tus companeros de grupo que salen sin barra llevan el icono de su clase encima y el nombre mas grande, con su color."] =
		"Group members shown without a bar get their class icon above them and a bigger, class-colored name.",
	["Tamano del icono de la marca"] = "Marker icon size",
	["Tamano del nombre"] = "Name size",
	["Asistente de configuracion"] = "Setup wizard",
	["Tres pasos: idioma, perfil y tamano. Lo puedes repetir cuando quieras con /hms setup."] =
		"Three steps: language, profile and size. You can run it again anytime with /hms setup.",
	["Probar en mi target"] = "Test on my target",
	["Muestra durante 8 s un cast, un debuff, el GCD y la cruz de healer en la placa de tu target, para ver donde queda todo."] =
		"Shows a cast, a debuff, the GCD and the healer cross on your target's plate for 8 s, so you can see where everything goes.",
	["Comandos: /hms abre las opciones, /hms setup el asistente y /hms test prueba los iconos en tu target."] =
		"Commands: /hms opens the options, /hms setup the wizard and /hms test tries the icons on your target.",
	["Vista previa"] = "Preview",
	["Buscar opcion..."] = "Search option...",
	["%d resultados"] = "%d results",
	["No hay opciones con ese nombre"] = "No options with that name",
	["Configuracion rapida"] = "Quick setup",
	["Paso %d de %d"] = "Step %d of %d",
	["Elige el idioma"] = "Choose the language",
	["Elige un perfil para empezar"] = "Choose a profile to start with",
	["Elige el tamano de las placas"] = "Choose the plate size",
	["Pequeno"] = "Small",
	["Mediano"] = "Medium",
	["Grande"] = "Large",
	["Atras"] = "Back",
	["Saltar"] = "Skip",
	["Siguiente"] = "Next",
	["Terminar"] = "Finish",
	["|cff66ccffHemsworkPlates:|r listo. Escribe /hms para cambiar lo que quieras o /hms setup para repetir el asistente."] =
		"|cff66ccffHemsworkPlates:|r done. Type /hms to change anything or /hms setup to run the wizard again.",
	["Las opciones de HemsworkPlates estan en su propia ventana."] = "HemsworkPlates options are in their own window.",
	["Abrir opciones"] = "Open options",
	["|cff66ccffHemsworkPlates:|r selecciona a alguien con la placa visible y vuelve a probar."] =
		"|cff66ccffHemsworkPlates:|r target someone whose plate is visible and try again.",
	["|cff66ccffHemsworkPlates:|r prueba de 8 s en tu target: cast, debuff, GCD y cruz de healer."] =
		"|cff66ccffHemsworkPlates:|r 8 s test on your target: cast, debuff, GCD and healer cross.",

	-- panel nuevo (secciones, filas y tarjetas)
	["Arena y grupo"] = "Arena and group",
	["Iconos"] = "Icons",
	["Avanzado"] = "Advanced",
	["Estilo y tamano"] = "Style and size",
	["Barra y texto"] = "Bar and text",
	["Comandos"] = "Commands",
	["Tu configuracion"] = "Your settings",
	["Mas opciones (%d)"] = "More options (%d)",
	["Menos opciones"] = "Fewer options",
	["En uso"] = "In use",
	["Clic para aplicar"] = "Click to apply",
	["Pulsa un perfil para aplicarlo. Pasa el raton por encima para ver de que va."] =
		"Click a profile to apply it. Hover over it to see what it does.",
	["Copia tu configuracion como texto para pasarla a otro personaje o cuenta, o pega la de otra persona."] =
		"Copy your settings as text to move them to another character or account, or paste someone else's.",
	["Categoria %d: %s"] = "Category %d: %s",
	["Solo nombre en arenas"] = "Name only in arenas",
	["Solo nombre en campos de batalla"] = "Name only in battlegrounds",
	["Solo nombre en mundo abierto"] = "Name only in the open world",
	["Solo nombre en mazmorras y bandas"] = "Name only in dungeons and raids",
	["Las placas amistosas muestran solo el nombre, sin barra."] = "Friendly plates show only the name, without a bar.",

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
