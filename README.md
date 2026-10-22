# HemsworkPlates

**[English](#english) · [Español](#español)**

---

## English

Arena-focused nameplates for **World of Warcraft 3.3.5a (WotLK)**, made for **Warmane** and any server that does not allow client patches.
Classic Blizzard look, pixel-perfect bars, castbars for every arena opponent, important debuffs, arena GCDs and everything configurable in-game with `/hms`.

> ✅ **No Awesome WotLK and no client patches needed.**
> Nameplates are found among the game's own frames and matched **by name** with `arena1-5`, `party1-4`, their pets, `target`, `focus` and `mouseover`. Inside arenas this gives full information for every opponent.

### Features

**Look**
- Four styles: **WotLK Classic** (default), **Old (Blizzard)** with the original golden frame, Square and Round.
- **Pixel-perfect** sizes and positions for crisp borders at any resolution.
- Class colors for enemy players and reaction colors (hostile / neutral / friendly / tapped).
- **Friendly players in Blizzard blue** (color configurable) so allies and enemies never get mixed up in arena.
- Name centered over the bar, level colored by difficulty.
- Glow around your **target** and the plate under your **mouse**.
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

**Arena GCDs**
- When an arena opponent uses a spell, its icon appears next to their plate with a sweep that lasts their **global cooldown**, taking class, haste buffs and instant-cast procs into account.

**PvP and utilities**
- **Arena numbers** (1–5) next to the bar or replacing the name; red for enemies, green for your team.
- **Totems as icons**, configurable one by one (icon, hidden or normal plate, custom icon).
- **Friendly plates with name only**, configurable per zone.
- Bigger target plate, smaller friendly plates, and the target plate kept inside the screen.
- **Profiles**: export your settings as text and import them on another character or account.
- **English and Spanish**: detected from your game client or chosen in `/hms` → Text → Language.
- Compatible with WeakAuras auras that use `WeakAuras.GetUnitNameplate`.

### Limits (no Awesome WotLK)

- Castbars and important debuffs work for units the game exposes: **arena opponents**, party, target, focus and mouseover. Other plates show health, name, level and colors.
- Pets with the same name (for example two Water Elementals) can be mixed up.
- Class colors on enemy players use the game option `ShowClassColorInNameplate`, which the addon turns on.
- Arena GCD spell names come from an English spell table, so GCDs work best on an English client.

### Installation

1. Download the repository (**Code → Download ZIP**).
2. Copy the folder into `World of Warcraft/Interface/AddOns/` and make sure it is named **`HemsworkPlates`** (the folder must contain `HemsworkPlates.toc` directly).
3. Start the game and enable **HemsworkPlates** in the AddOns list.
4. If you use **NamePlateArenaGCDs**, disable it: its features are already included.

### Commands

| Command | Description |
|---|---|
| `/hms` | Open the options panel (also `/plates`) |
| `/hms perfil` | Import / export profiles |
| `/hms gcd` | Test the arena GCD icon on your target |
| `/hms reset` | Reset all settings to defaults |
| `/hms perf` | Show performance stats (`/hms perf reset` to restart) |

### Credits

- Arena GCD tracking based on **NameplateArenaGCDs** by Fruitdealer1337, itself based on **ArenaGCDs** by Oscarforge.
- Original nameplate measurements taken from **RefinedBlizzPlates** by Khal.

---

## Español

Placas de nombre pensadas para arenas en **World of Warcraft 3.3.5a (WotLK)**, hechas para **Warmane** y cualquier servidor que no permita parches del cliente.
Aspecto clásico de Blizzard, barras pixel-perfect, castbar de todos los rivales de arena, debuffs importantes, GCD de arena y todo configurable dentro del juego con `/hms`.

> ✅ **No necesita Awesome WotLK ni parches del cliente.**
> Las placas se buscan entre los marcos del propio juego y se emparejan **por nombre** con `arena1-5`, `party1-4`, sus mascotas, `target`, `focus` y `mouseover`. Dentro de la arena esto da información completa de cada rival.

### Funciones

**Aspecto**
- Cuatro estilos: **Clásico WotLK** (por defecto), **Antiguo (Blizzard)** con el marco dorado original, Cuadrado y Redondo.
- Tamaños y posiciones **pixel-perfect** para bordes nítidos en cualquier resolución.
- Color de clase en jugadores enemigos y de reacción (hostil / neutral / amistoso / tapeado).
- **Jugadores aliados en el azul de Blizzard** (color configurable), para no confundir aliados y enemigos en arena.
- Nombre centrado sobre la barra y nivel coloreado por dificultad.
- Brillo alrededor de tu **target** y de la placa bajo el **ratón**.
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

**GCD de arena**
- Cuando un rival de arena lanza un hechizo, su icono aparece junto a su placa con un barrido que dura su **cooldown global**, teniendo en cuenta la clase, los buffs de haste y los procs de cast instantáneo.

**PvP y utilidades**
- **Números de arena** (1–5) junto a la barra o en lugar del nombre; rojo para enemigos y verde para tu equipo.
- **Tótems como icono**, configurables uno a uno (icono, oculto o placa normal, icono propio).
- **Aliados solo con nombre**, configurable por zona.
- Placa del target más grande, aliados más pequeños y la placa del target siempre dentro de la pantalla.
- **Perfiles**: exporta tu configuración como texto e impórtala en otro personaje o cuenta.
- **Español e inglés**: se detecta según el idioma de tu cliente o se elige en `/hms` → Texto → Idioma.
- Compatible con auras de WeakAuras que usan `WeakAuras.GetUnitNameplate`.

### Límites (sin Awesome WotLK)

- El castbar y los debuffs importantes funcionan con las unidades que el juego expone: **rivales de arena**, grupo, target, focus y mouseover. El resto de placas muestran vida, nombre, nivel y colores.
- Las mascotas con el mismo nombre (por ejemplo, dos Water Elemental) pueden confundirse.
- El color de clase de los jugadores enemigos usa la opción del juego `ShowClassColorInNameplate`, que el addon activa.
- Los nombres de hechizo del GCD de arena salen de una tabla en inglés, así que funciona mejor con el cliente en inglés.

### Instalación

1. Descarga el repositorio (**Code → Download ZIP**).
2. Copia la carpeta en `World of Warcraft/Interface/AddOns/` y comprueba que se llama **`HemsworkPlates`** (dentro debe estar directamente `HemsworkPlates.toc`).
3. Abre el juego y activa **HemsworkPlates** en la lista de AddOns.
4. Si usas **NamePlateArenaGCDs**, desactívalo: sus funciones ya vienen incluidas.

### Comandos

| Comando | Descripción |
|---|---|
| `/hms` | Abre el panel de opciones (también `/plates`) |
| `/hms perfil` | Importar / exportar perfiles |
| `/hms gcd` | Prueba el icono de GCD de arena en tu target |
| `/hms reset` | Restablece toda la configuración |
| `/hms perf` | Muestra el rendimiento del addon (`/hms perf reset` para reiniciar) |

### Créditos

- GCD de arena basado en **NameplateArenaGCDs** de Fruitdealer1337, que a su vez se basa en **ArenaGCDs** de Oscarforge.
- Medidas de la placa original tomadas de **RefinedBlizzPlates** de Khal.
