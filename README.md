# HemsworkPlates

**[English](#english) · [Español](#español)**

---

## English

Arena-focused nameplates for **World of Warcraft 3.3.5a (WotLK)**, made for **Warmane** and any server that does not allow client patches.
Classic Blizzard look, pixel-perfect bars, castbars for every arena opponent, important debuffs, arena GCDs and everything configurable in-game with `/hms`, in a dark side-menu panel with tooltips.

> ✅ **No Awesome WotLK and no client patches needed.**
> Nameplates are found among the game's own frames and matched **by name** with `arena1-5`, `party1-4`, their pets, `target`, `focus` and `mouseover`. Inside arenas this gives full information for every opponent.

### Features

**Easy to set up**
- **Setup wizard** the first time you log in (language, profile and size). Run it again with `/hms setup`.
- **Quick profiles** with one click, each with a preview of an enemy and an ally: Arena with marked allies, Arena with plates on both, Classic Blizzard, Minimalist, Battlegrounds and **Hemswork's own profile**.
- **Group marker**: party members shown without a bar get their class icon above them and a bigger, class-colored name.
- **Simple panel**: six sections with the main options, the rarely used ones folded under "More options", and a **search box** that finds any option.
- **Test on my target** (`/hms test`): shows a cast, a debuff, the GCD and the healer cross on your target to see where everything goes.
- Also in **Esc → Interface → AddOns → HemsworkPlates**.

**Look**
- Two styles: **WotLK Classic** (default) and **Old (Blizzard)** with the original golden frame.
- **Centered over the head**: the middle of the bar sits right above the character.
- **Soft shadow** around the bar, **damage trail** (a light segment that shrinks to the new health) and a **spark** on the castbar.
- **Class icon** on the left of player plates.
- **Pixel-perfect** sizes and positions for crisp borders at any resolution.
- Class colors for enemy players and reaction colors (hostile / neutral / friendly / tapped).
- **Friendly players in Blizzard blue** (color configurable) so allies and enemies never get mixed up in arena.
- Name centered over the bar, level colored by difficulty.
- Health text with 6 formats: percent, percent with decimal, current, current/max, current (percent) and deficit.
- Move the whole plate and the name freely (X / Y).

**Castbar**
- Blizzard's silver castbar border, gold fill, spark and spell icon.
- Optional spell name and remaining time, with their own font size.
- **Interrupted casts** freeze in red showing **"Interrupted: who"** (nameplates, target frame and focus frame).
- **Uninterruptible casts** get their own style: silver fill, Blizzard shield border and grey icon.

**Important debuffs**
- The most important aura on each enemy plate, picked by category: immunities > CC > silences > roots > disarms > defensives > offensives > others (259 spells with their own priorities).
- **Interrupt lockouts** (Pummel, Shield Bash, Kick, Counterspell, Wind Shear, Mind Freeze, Spell Lock…) shown as silences, even though they leave no aura.
- Custom cooldown swipe that does not vanish when you press keys.
- **Spell list editor** (`/hms` → Spells): turn spells off, change their category or priority, or add your own by spell ID.
- Icon width, height and position adjustable separately; Blizzard (silver) or flat icon border.

**Arena GCDs**
- When an arena opponent uses a spell, its icon appears next to their plate with a sweep that lasts their **global cooldown**, taking class, haste buffs and instant-cast procs into account.

**PvP and utilities**
- **Arena numbers** (1–5) next to the bar or replacing the name; red for enemies, green for your team.
- **Healer icon**: green cross next to the name of enemy and party healers, detected by their spells (and by Gladius spec detection if you use it). Size and position set separately for enemies and party.
- **Totems as icons**, configurable one by one (icon, hidden, normal plate or icon + plate, custom icon).
- **Mage Mirror Images** no longer steal the mage's castbar.
- **Friendly plates with name only**, configurable per zone.
- Bigger target plate, smaller friendly plates, and the target plate kept inside the screen.
- **Profiles**: export your settings as text and import them on another character or account.
- **English and Spanish**: detected from your game client or chosen in `/hms` → Text → Language.
- **Update notice**: if someone in your group, arena team, battleground or guild has a newer version, you get a chat message with the download link.
- Compatible with WeakAuras auras that use `WeakAuras.GetUnitNameplate`.

### Limits (no Awesome WotLK)

- Castbars and important debuffs work for units the game exposes: **arena opponents**, party, target, focus and mouseover. Other plates show health, name, level and colors.
- Pets with the same name (for example two Water Elementals) can be mixed up.
- Class colors on enemy players use the game option `ShowClassColorInNameplate`, which the addon turns on.
- Arena GCD spell names come from an English spell table, so GCDs work best on an English client.

### Installation

1. Download **`HemsworkPlates-x.y.z.zip`** from the [latest release](https://github.com/Hemswork/HemsworkPlates/releases/latest).
2. Unzip it into `World of Warcraft/Interface/AddOns/`. The folder is already named **`HemsworkPlates`**.
3. Start the game and enable **HemsworkPlates** in the AddOns list.
4. If you use **NamePlateArenaGCDs**, disable it: its features are already included.

### Commands

| Command | Description |
|---|---|
| `/hms` | Open the options panel (also `/plates`) |
| `/hms perfil` | Import / export profiles |
| `/hms setup` | Run the setup wizard again |
| `/hms test` | Show a test cast, debuff, GCD and healer cross on your target |
| `/hms gcd` | Test the arena GCD icon on your target |
| `/hms reset` | Reset all settings to defaults |
| `/hms perf` | Show performance stats (`/hms perf reset` to restart) |

### Credits

- Arena GCD tracking based on **NameplateArenaGCDs** by Fruitdealer1337, itself based on **ArenaGCDs** by Oscarforge.
- Original nameplate measurements taken from **RefinedBlizzPlates** by Khal.

---

## Español

Placas de nombre pensadas para arenas en **World of Warcraft 3.3.5a (WotLK)**, hechas para **Warmane** y cualquier servidor que no permita parches del cliente.
Aspecto clásico de Blizzard, barras pixel-perfect, castbar de todos los rivales de arena, debuffs importantes, GCD de arena y todo configurable dentro del juego con `/hms`, en un panel oscuro con menú lateral y descripciones al pasar el ratón.

> ✅ **No necesita Awesome WotLK ni parches del cliente.**
> Las placas se buscan entre los marcos del propio juego y se emparejan **por nombre** con `arena1-5`, `party1-4`, sus mascotas, `target`, `focus` y `mouseover`. Dentro de la arena esto da información completa de cada rival.

### Funciones

**Fácil de configurar**
- **Asistente** la primera vez que entras (idioma, perfil y tamaño). Se repite con `/hms setup`.
- **Perfiles rápidos** de un clic, cada uno con una vista previa de un rival y un aliado: Arena con aliados marcados, Arena con placas en ambos, Blizzard clásico, Minimalista, Campos de batalla y **el perfil de Hemswork**.
- **Marca sobre tu grupo**: tus compañeros que salen sin barra llevan el icono de su clase encima y el nombre más grande con su color.
- **Panel sencillo**: seis secciones con lo importante, lo que casi nadie toca plegado en "Más opciones" y un **buscador** que encuentra cualquier opción.
- **Probar en mi target** (`/hms test`): muestra un cast, un debuff, el GCD y la cruz de healer en tu target para ver dónde queda todo.
- También en **Esc → Interfaz → AddOns → HemsworkPlates**.

**Aspecto**
- Dos estilos: **Clásico WotLK** (por defecto) y **Antiguo (Blizzard)** con el marco dorado original.
- **Centrada sobre la cabeza**: la mitad de la barra queda justo encima del personaje.
- **Sombra suave** alrededor de la barra, **rastro de daño** (un trozo claro que se encoge hasta la vida nueva) y **chispa** en el castbar.
- **Icono de clase** a la izquierda de las placas de jugadores.
- Tamaños y posiciones **pixel-perfect** para bordes nítidos en cualquier resolución.
- Color de clase en jugadores enemigos y de reacción (hostil / neutral / amistoso / tapeado).
- **Jugadores aliados en el azul de Blizzard** (color configurable), para no confundir aliados y enemigos en arena.
- Nombre centrado sobre la barra y nivel coloreado por dificultad.
- Texto de vida con 6 formatos: porcentaje, porcentaje con decimal, actual, actual/máx, actual (%) y déficit.
- Puedes mover la placa entera y el nombre libremente (X / Y).

**Castbar**
- Marco plateado de Blizzard, relleno dorado, chispa e icono del hechizo.
- Nombre del hechizo y tiempo restante opcionales, con su propio tamaño de letra.
- **Casts interrumpidos**: la barra se queda parada en rojo con **"Interrupted: quién"** (placas, marco del target y del focus).
- **Casts no interrumpibles** con estilo propio: relleno plateado, escudo de Blizzard e icono en gris.

**Debuffs importantes**
- El aura más importante de cada placa enemiga según su categoría: inmunidades > CC > silencios > raíces > desarmes > defensivos > ofensivos > otros (259 hechizos con prioridades propias).
- **Bloqueos de interrupción** (Pummel, Shield Bash, Kick, Counterspell, Wind Shear, Mind Freeze, Spell Lock…) mostrados como silencio, aunque no dejen aura.
- Círculo de cooldown propio que no desaparece al pulsar teclas.
- **Editor de la lista de hechizos** (`/hms` → Hechizos): quita hechizos, cambia su categoría o prioridad, o añade los tuyos por ID.
- Ancho, alto y posición de los iconos por separado; borde de iconos de Blizzard (plateado) o plano.

**GCD de arena**
- Cuando un rival de arena lanza un hechizo, su icono aparece junto a su placa con un barrido que dura su **cooldown global**, teniendo en cuenta la clase, los buffs de haste y los procs de cast instantáneo.

**PvP y utilidades**
- **Números de arena** (1–5) junto a la barra o en lugar del nombre; rojo para enemigos y verde para tu equipo.
- **Icono de sanador**: cruz verde junto al nombre de los healers rivales y de tu grupo, detectados por sus hechizos (y por la detección de especialización de Gladius si lo usas). Tamaño y posición por separado para rivales y grupo.
- **Tótems como icono**, configurables uno a uno (icono, oculto, placa normal o icono + placa, icono propio).
- Las **imágenes del mago** (Mirror Image) ya no se quedan con su castbar.
- **Aliados solo con nombre**, configurable por zona.
- Placa del target más grande, aliados más pequeños y la placa del target siempre dentro de la pantalla.
- **Perfiles**: exporta tu configuración como texto e impórtala en otro personaje o cuenta.
- **Español e inglés**: se detecta según el idioma de tu cliente o se elige en `/hms` → Texto → Idioma.
- **Aviso de actualización**: si alguien de tu grupo, equipo de arena, campo de batalla o hermandad tiene una versión más nueva, te sale un mensaje en el chat con el enlace de descarga.
- Compatible con auras de WeakAuras que usan `WeakAuras.GetUnitNameplate`.

### Límites (sin Awesome WotLK)

- El castbar y los debuffs importantes funcionan con las unidades que el juego expone: **rivales de arena**, grupo, target, focus y mouseover. El resto de placas muestran vida, nombre, nivel y colores.
- Las mascotas con el mismo nombre (por ejemplo, dos Water Elemental) pueden confundirse.
- El color de clase de los jugadores enemigos usa la opción del juego `ShowClassColorInNameplate`, que el addon activa.
- Los nombres de hechizo del GCD de arena salen de una tabla en inglés, así que funciona mejor con el cliente en inglés.

### Instalación

1. Descarga **`HemsworkPlates-x.y.z.zip`** de la [última versión publicada](https://github.com/Hemswork/HemsworkPlates/releases/latest).
2. Descomprímelo en `World of Warcraft/Interface/AddOns/`. La carpeta ya se llama **`HemsworkPlates`**.
3. Abre el juego y activa **HemsworkPlates** en la lista de AddOns.
4. Si usas **NamePlateArenaGCDs**, desactívalo: sus funciones ya vienen incluidas.

### Comandos

| Comando | Descripción |
|---|---|
| `/hms` | Abre el panel de opciones (también `/plates`) |
| `/hms perfil` | Importar / exportar perfiles |
| `/hms setup` | Vuelve a abrir el asistente |
| `/hms test` | Muestra un cast, debuff, GCD y cruz de healer de prueba en tu target |
| `/hms gcd` | Prueba el icono de GCD de arena en tu target |
| `/hms reset` | Restablece toda la configuración |
| `/hms perf` | Muestra el rendimiento del addon (`/hms perf reset` para reiniciar) |

### Créditos

- GCD de arena basado en **NameplateArenaGCDs** de Fruitdealer1337, que a su vez se basa en **ArenaGCDs** de Oscarforge.
- Medidas de la placa original tomadas de **RefinedBlizzPlates** de Khal.
