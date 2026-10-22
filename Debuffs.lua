--------------------------------------------------------------------
-- HemsworkPlates - Debuffs importantes (integrado desde la WeakAura
-- "[Nameplate] BigDebuffs 3.3.5")
-- Muestra en cada placa enemiga el aura mas importante: primero por
-- categoria (orden fijo) y dentro de ella por prioridad (100 = maxima);
-- a igual prioridad gana la que le quede mas tiempo.
--------------------------------------------------------------------
local addonName, SP = ...

local DEBUFF_SPELLS = {
    immunities = {
        [45438] = {priority = 100, name = "Bloque de Hielo"},                      -- Mago
        [642]   = {priority = 100, name = "Protección Divina"},                  -- Paladín
        [31224] = {priority = 100, name = "Capa de Sombras"},               -- Pícaro
        [47585] = {priority = 100, name = "Dispersión"},                     -- Sacerdote
        [48707] = {priority = 100, name = "Armadura Antimágica"},               -- Caballero de la Muerte
        [34471] = {priority = 100, name = "La Bestia Interior"},               -- Cazador (Inmunidad CC)
        [19263] = {priority = 100, name = "Deterrence"},                     -- Cazador
        [46924] = {priority = 100, name = "Tormenta de Cuchillas"},                     -- Guerrero
        [23920] = {priority = 100, name = "Reflejo de Hechizos"},               -- Guerrero
        [3169]  = {priority = 100, name = "Poción de Invulnerabilidad Limitada"}, -- Poción
        [16621] = {priority = 100, name = "Correo Invulnerable"},              -- Joya
        [4511]  = {priority = 100, name = "Cambio de Fase"},                    -- Brujo
        [20230] = {priority = 100, name = "Represalia"},                    -- Guerrero
        [19753] = {priority = 100, name = "Intervención Divina"},            -- Paladín
        [27827] = {priority = 100, name = "Espíritu de la Redención"},           -- Sacerdote
    },
    
    cc = {
        [47481] = {priority = 100, name = "Morder"},                           -- CdM (Pet)
        [49203] = {priority = 100, name = "Frío Hambriento"},                 -- CdM
        [51209] = {priority = 100, name = "Frío Hambriento"},                 -- CdM
        [33786] = {priority = 100, name = "Ciclón"},                        -- Druida
        [18658] = {priority = 100, name = "Hibernación"},                      -- Druida
        [8983]  = {priority = 100, name = "Golpe"},                           -- Druida
        [49803] = {priority = 100, name = "Embestida"},                         -- Druida
        [49802] = {priority = 100, name = "Mutilación"},                           -- Druida
        [9005]  = {priority = 100, name = "Golpe de Embestida"},                    -- Druida
        [14309] = {priority = 100, name = "Efecto Trampa Congelante"},           -- Cazador
        [60210] = {priority = 100, name = "Efecto Flecha Congelante"},          -- Cazador
        [14327] = {priority = 100, name = "Asustar a Bestia"},                    -- Cazador
        [49012] = {priority = 100, name = "Aguijón de Wyrn"},                   -- Cazador
        [19503] = {priority = 100, name = "Disparo Dispersante"},                   -- Cazador
        [24394] = {priority = 100, name = "Intimidación"},                   -- Cazador
        [53359] = {priority = 100, name = "Disparo Quimera - Escorpión"},         -- Cazador (Desarmado)
        [12826] = {priority = 100, name = "Polimorfismo"},                      -- Mago
        [28271] = {priority = 100, name = "Polimorfismo"},                      -- Mago
        [44572] = {priority = 100, name = "Congelación Profunda"},                    -- Mago
        [12355] = {priority = 100, name = "Impacto"},                         -- Mago
        [42950] = {priority = 100, name = "Aliento de Dragón"},                -- Mago
        [31661] = {priority = 100, name = "Aliento de Dragón"},                -- Mago
        [10308] = {priority = 100, name = "Martillo de Justicia"},              -- Paladín
        [20066] = {priority = 100, name = "Penitencia"},                     -- Paladín
        [20170] = {priority = 100, name = "Aturdimiento por Sello"},                      -- Paladín
        [10326] = {priority = 100, name = "Desterrar Mal"},                      -- Paladín
        [48817] = {priority = 100, name = "Cólera Divina"},                     -- Paladín
        [605]   = {priority = 100, name = "Control Mental"},                   -- Sacerdote
        [64044] = {priority = 100, name = "Horror Psíquico"},                 -- Sacerdote
        [64058] = {priority = 100, name = "Horror Psíquico"},                 -- Sacerdote
        [10890] = {priority = 100, name = "Grito Psíquico"},                 -- Sacerdote
        [51724] = {priority = 100, name = "Estupefacción"},                            -- Pícaro
        [2094]  = {priority = 100, name = "Ceguera"},                          -- Pícaro
        [1776]  = {priority = 100, name = "Gancho"},                          -- Pícaro
        [1833]  = {priority = 100, name = "Golpe Barato"},                     -- Pícaro
        [8643]  = {priority = 100, name = "Golpe Renal"},                    -- Pícaro
        [51514] = {priority = 100, name = "Hexo"},                            -- Chamán
        [58861] = {priority = 100, name = "Golpe (Lobo Espiritual)"},             -- Chamán
        [6215]  = {priority = 100, name = "Miedo"},                           -- Brujo
        [47860] = {priority = 100, name = "Golpe de Muerte"},                     -- Brujo
        [6358]  = {priority = 100, name = "Seducción"},                      -- Brujo
        [17928] = {priority = 100, name = "Aullido de Terror"},                 -- Brujo
        [18647] = {priority = 100, name = "Desterrar"},                         -- Brujo
        [47847] = {priority = 100, name = "Furia de Sombra"},                     -- Brujo
        [30283] = {priority = 100, name = "Furia de Sombra"},                     -- Brujo
        [32752] = {priority = 100, name = "Desorientación Invocadora"},       -- Brujo
        [18093] = {priority = 100, name = "Piroclasma"},                      -- Brujo
        [30457] = {priority = 100, name = "Vulnerabilidad Completa"},        -- Joya
        [5246]  = {priority = 100, name = "Grito Intimidante"},             -- Guerrero
        [46968] = {priority = 100, name = "Onda de Choque"},                      -- Guerrero
        [7922]  = {priority = 100, name = "Aturdimiento de Carga"},                    -- Guerrero
        [47995] = {priority = 100, name = "Aturdimiento de Intercepción"},                 -- Guerrero
        [20253] = {priority = 100, name = "Aturdimiento de Intercepción"},                 -- Guerrero
        [12809] = {priority = 100, name = "Golpe de Conmoción"},                -- Guerrero
        [12798] = {priority = 100, name = "Aturdimiento de Venganza"},                   -- Guerrero
        [5530]  = {priority = 100, name = "Aturdimiento Mazo Spec"},                 -- Guerrero
        [20549] = {priority = 100, name = "Pisada de Guerra"},                      -- Racial
        [28730] = {priority = 100, name = "Torrente Arcano"},                 -- Racial
        [25046] = {priority = 100, name = "Torrente Arcano"},                 -- Racial
        [50613] = {priority = 100, name = "Torrente Arcano"},                 -- Racial
        [30153] = {priority = 100, name = "Golpe de Guardia Vil"},                  -- Brujo Pet
        [19482] = {priority = 100, name = "Golpe de Guardián de Perdición"},                -- Brujo Pet
        [22703] = {priority = 100, name = "Efecto Infierno"},                 -- Brujo
        [60995] = {priority = 100, name = "Carga de Demonio"},                   -- Brujo
        [1090]  = {priority = 100, name = "Polvo Mágico"},                     -- Joya
        [13327] = {priority = 100, name = "Carga Imprudente"},                -- Joya
        [835]   = {priority = 100, name = "Amuleto Mareal"},                    -- Joya
        [13237] = {priority = 100, name = "Mortero Góblin"},                  -- Joya
        [19769] = {priority = 100, name = "Granada de Torio"},                -- Granada
        [4068]  = {priority = 100, name = "Granada de Hierro"},                   -- Granada
        [15753] = {priority = 100, name = "Aturdimiento Boomerang de Linken"},        -- Joya
        [18798] = {priority = 100, name = "Banda Congelante"},                  -- Joya
        [39796] = {priority = 100, name = "Tótem Garra de Piedra"},                -- Chamán
        [62505] = {priority = 100, name = "Mutilación"},                           -- Druida
        [16922] = {priority = 100, name = "Aturdimiento por Fuego Estelar"},                  -- Druida
    },
    
    silence = {
        [47476] = {priority = 100,  name = "Estrangular"},                   -- CdM
        [15487] = {priority = 100,  name = "Silencio"},                       -- Sacerdote
        [34490] = {priority = 100,  name = "Disparo Silenciador"},                -- Cazador
        [55021] = {priority = 100,  name = "Contrahechizo Mejorado"},         -- Mago
        [31117] = {priority = 100,  name = "Silencio Aflicción Inestable"},   -- Brujo
        [24259] = {priority = 100,  name = "Bloqueo de Hechizo"},                    -- Brujo
        [1330]  = {priority = 100,  name = "Garrote - Silencio"},             -- Pícaro
        [18425] = {priority = 100,  name = "Patada Mejorada"},                 -- Pícaro
        [63529] = {priority = 100,  name = "Silenciado - Escudo del Templario"},     -- Paladín
        [18498] = {priority = 100,  name = "Silenciado - Orden de Amordazar"},          -- Guerrero
        [28730] = {priority = 100,  name = "Torrente Arcano"},                -- Racial
    },
    
    roots = {
        [42917] = {priority = 100,  name = "Nova de Hielo"},                    -- Mago
        [55080] = {priority = 100,  name = "Barrera Fracturada"},             -- Mago
        [33395] = {priority = 100,  name = "Congelación"},                        -- Elemental de Agua
        [53308] = {priority = 100,  name = "Raíces Enredadoras"},              -- Druida
        [339]   = {priority = 100,  name = "Raíces Enredadoras"},              -- Druida
        [19675] = {priority = 100,  name = "Efecto Embestida Felina"},           -- Druida
        [53148] = {priority = 100,  name = "Embestida Felina"},                  -- Druida
        [64695] = {priority = 100,  name = "Tótem Tierra Grabada"},                     -- Chamán
        [63685] = {priority = 100,  name = "Congelación (Mejora)"},          -- Chamán
        [4167]  = {priority = 100,  name = "Red"},                           -- Pet Cazador
        [53548] = {priority = 100,  name = "Alfiler"},                           -- Pet Cazador
        [55509] = {priority = 100,  name = "Spray Venenoso de Red"},               -- Pet Cazador
        [19185] = {priority = 100,  name = "Trampa"},                    -- Cazador
        [47168] = {priority = 100,  name = "Ala Mejorada"},             -- Cazador
        [48999] = {priority = 100,  name = "Contraataque"},                 -- Cazador
        [25999] = {priority = 100,  name = "Carga de Jabalí"},                   -- Cazador
        [3034]  = {priority = 100,  name = "Veneno de Víbora"},                   -- Cazador
        [23694] = {priority = 100,  name = "Cojera Mejorada"},            -- Guerrero
        [58373] = {priority = 100,  name = "Glifo de Cojera"},            -- Guerrero
        [45524] = {priority = 100,  name = "Cadenas de Hielo"},                 -- CdM
        [12494] = {priority = 100,  name = "Congelación por Escarcha"},                     -- Mago
        [122]   = {priority = 100,  name = "Nova de Hielo"},                    -- Mago
        [18223] = {priority = 100,  name = "Maldición del Agotamiento"},           -- Brujo
        [1714]  = {priority = 100,  name = "Maldición de Lenguas"},              -- Brujo
        [12548] = {priority = 100,  name = "Choque de Hielo"},                   -- Chamán
        [3409]  = {priority = 100,  name = "Veneno de Parálisis"},              -- Pícaro
        [19306] = {priority = 100,  name = "Raíz de Contraataque"},            -- Cazador
    },
    
    disarms = {
        [676]   = {priority = 100,  name = "Desarme"},                        -- Guerrero
        [51722] = {priority = 100,  name = "Desmantelamiento"},                     -- Pícaro
        [64058] = {priority = 100,  name = "Horror Psíquico Desarmado"},         -- Sacerdote
        [53359] = {priority = 100,  name = "Disparo Quimera - Escorpión"},        -- Cazador
        [64346] = {priority = 100,  name = "Represalia Ardiente"},                 -- Mago
        [53543] = {priority = 100,  name = "Arrebatar"},                        -- Pet Cazador
    },
    
    defensives = {
        [48792] = {priority = 100,  name = "Fortaleza Atada por Hielo"},             -- CdM
        [49039] = {priority = 100,  name = "Lichborne"},                      -- CdM
        [47484] = {priority = 100,  name = "Acurrucarse"},                         -- CdM
        [50461] = {priority = 100,  name = "Zona Antimágica"},                -- CdM
        [10278] = {priority = 100,  name = "Mano de Protección"},            -- Paladín
        [6940]  = {priority = 100,  name = "Mano de Sacrificio"},              -- Paladín
        [64205] = {priority = 100,  name = "Sacrificio Divino"},               -- Paladín
        [1044]  = {priority = 100,  name = "Mano de Libertad"},                -- Paladín
        [54428] = {priority = 100,  name = "Plegaria Divina"},                    -- Paladín
        [31821] = {priority = 100,  name = "Maestría de Aura"},                   -- Paladín
        [31852] = {priority = 100,  name = "Defensor Ardiente"},                -- Paladín
        [58597] = {priority = 100,  name = "Proc Escudo Sagrado"},             -- Paladín
        [33206] = {priority = 100,  name = "Supresión del Dolor"},               -- Sacerdote
        [47788] = {priority = 100,  name = "Espíritu Guardián"},                -- Sacerdote
        [20711] = {priority = 100,  name = "Espíritu de la Redención"},           -- Sacerdote
        [64843] = {priority = 100,  name = "Himno Divino"},                    -- Sacerdote
        [64901] = {priority = 100,  name = "Himno de Esperanza"},                   -- Sacerdote
        [6346]  = {priority = 90,  name = "Salvaguarda del Miedo"},                      -- Sacerdote
        [14892] = {priority = 100,  name = "Inspiración"},                    -- Sacerdote
        [14751] = {priority = 100,  name = "Enfoque Interior"},                    -- Sacerdote
        [48066] = {priority = 100,  name = "Escudo del Poder: Escudo"},             -- Sacerdote
        [17]    = {priority = 100,  name = "Escudo del Poder: Escudo"},             -- Sacerdote
        [26669] = {priority = 100,  name = "Evasión"},                        -- Pícaro
        [45182] = {priority = 100,  name = "Muerte Falsa"},                 -- Pícaro
        [2565]  = {priority = 100,  name = "Bloqueo de Escudo"},                   -- Guerrero
        [871]   = {priority = 100,  name = "Muro de Escudo"},                    -- Guerrero
        [12975] = {priority = 100,  name = "Última Oportunidad"},                     -- Guerrero
        [3411]  = {priority = 100,  name = "Interceptación"},                      -- Guerrero
        [55694] = {priority = 100,  name = "Regeneración Enfurecida"},           -- Guerrero
        [8178]  = {priority = 100,  name = "Efecto Tótem Anclaje"},        -- Chamán
        [16188] = {priority = 100,  name = "Rapidez de la Naturaleza"},             -- Chamán
        [30823] = {priority = 100,  name = "Furia Chamánica"},               -- Chamán
        [54216] = {priority = 100,  name = "Llamada del Maestro"},                  -- Pet Cazador
        [53271] = {priority = 100,  name = "Llamada del Maestro"},                  -- Cazador
        [1742]  = {priority = 100,  name = "Acobardamiento"},                          -- Pet Cazador
        [26064] = {priority = 100,  name = "Escudo de Caparazón"},                   -- Pet Cazador
        [53476] = {priority = 100,  name = "Interceptación"},                     -- Pet Cazador
        [53480] = {priority = 100,  name = "Rugido de Sacrificio"},              -- Pet Cazador
        [22812] = {priority = 100,  name = "Piel de Corteza"},                       -- Druida
        [22842] = {priority = 100,  name = "Regeneración Frenética"},          -- Druida
        [61336] = {priority = 100,  name = "Instintos de Supervivencia"},             -- Druida
        [5384]  = {priority = 100,  name = "Muerte Simulada"},                    -- Cazador
        [20216] = {priority = 100,  name = "Favor Divino"},                   -- Paladín
        [31842] = {priority = 100,  name = "Iluminación Divina"},            -- Paladín
        [43039] = {priority = 100,  name = "Barrera de Hielo"},                    -- Mago
        [1463]  = {priority = 100,  name = "Escudo de Maná"},                    -- Mago
        [11426] = {priority = 100,  name = "Barrera de Hielo"},                    -- Mago
        [5024]  = {priority = 100,  name = "Calavera de la Perdición Inminente"},        -- Joya
        [6615]  = {priority = 100,  name = "Poción de Acción Libre"},             -- Poción
        [24364] = {priority = 100,  name = "Poción de Acción Viva"},           -- Poción
        [30456] = {priority = 100,  name = "Casi Invulnerabilidad"},          -- Joya
        [29506] = {priority = 100,  name = "Caparazón de Minero"},              -- Joya
        [12733] = {priority = 100,  name = "Joya de Herrero"},             -- Joya
        [14530] = {priority = 100,  name = "Cronómetro Perfeccionado"},                -- Joya
        [23506] = {priority = 100,  name = "Gran Maestro de Arena"},             -- Joya
    },
    
    offensives = {
        [50334] = {priority = 100,  name = "Enloquecimiento"},                       -- Druida
        [53201] = {priority = 100,  name = "Caída de Estrellas"},                      -- Druida
        [69369] = {priority = 100,  name = "Rapidez del Depredador"},          -- Druida
        [29166] = {priority = 100,  name = "Inervación"},                     -- Druida
        [1719]  = {priority = 100,  name = "Temeridad"},                       -- Guerrero
        [60503] = {priority = 100,  name = "Gusto por la Sangre"},               -- Guerrero
        [18499] = {priority = 100,  name = "Furia de Berserker"},                -- Guerrero
        [12292] = {priority = 100,  name = "Deseo de Muerte"},                    -- Guerrero
        [51713] = {priority = 100,  name = "Danza de Sombra"},                  -- Pícaro
        [51690] = {priority = 100,  name = "Matanza Mortífera"},                 -- Pícaro
        [13750] = {priority = 100,  name = "Prisa de Adrenalina"},               -- Pícaro
        [13877] = {priority = 100,  name = "Aluvión de Cuchillas"},                  -- Pícaro
        [2825]  = {priority = 99,  name = "Sed de Sangre"},                      -- Chamán
        [32182] = {priority = 99,  name = "Heroísmo"},                        -- Chamán
        [16191] = {priority = 99,  name = "Tótem de Marea de Maná"},                -- Chamán
        [31884] = {priority = 100,  name = "Cólera Vengadora"},                -- Paladín
        [47241] = {priority = 100,  name = "Metamorfosis"},                 -- Brujo
        [18708] = {priority = 100,  name = "Dominación Vil"},                -- Brujo
        [19574] = {priority = 100,  name = "Furia Bestial"},                 -- Cazador
        [3045]  = {priority = 100,  name = "Fuego Rápido"},                    -- Cazador
        [13159] = {priority = 100,  name = "Aspecto de la Manada"},            -- Cazador
        [5118]  = {priority = 100,  name = "Aspecto del Guepardo"},         -- Cazador
        [10060] = {priority = 100,  name = "Infusión de Poder"},                -- Sacerdote
        [44544] = {priority = 100,  name = "Dedos de Escarcha"},              -- Mago
        [12042] = {priority = 100,  name = "Poder Arcano"},                  -- Mago
        [12043] = {priority = 100,  name = "Presencia de la Mente"},              -- Mago
        [12472] = {priority = 100,  name = "Venas Heladas"},                     -- Mago
        [66]    = {priority = 100,  name = "Invisibilidad"},                  -- Mago
        [54748] = {priority = 100,  name = "Determinación Ardiente"},         -- Mago
        [49028] = {priority = 100,  name = "Arma de Runas Danzante"},           -- CdM
        [47528] = {priority = 99,  name = "Congelación Mental"},                    -- CdM
        [26090] = {priority = 99,  name = "Martillazo"},                         -- Pet Cazador
        [1850]  = {priority = 100,  name = "Carrera"},                          -- Druida
        [16689] = {priority = 100,  name = "Buff Gracias de la Naturaleza"},           -- Druida
        [33357] = {priority = 100,  name = "Carrera"},                          -- Druida
        [64850] = {priority = 100,  name = "Asalto Implacable"},           -- Guerrero
        [33961] = {priority = 100,  name = "Reflejo de Hechizos"},              -- Joya
    },
    
    others = {
        [34709] = {priority = 10,  name = "Buff de Visión de Sombra"},               -- Debuff Especial
        [43183] = {priority = 9,   name = "Bebida"},                          -- Bebida
        [22734] = {priority = 9,   name = "Bebida"},                          -- Bebida
        [46755] = {priority = 9,   name = "Bebida"},                          -- Bebida
        [27089] = {priority = 9,   name = "Bebida"},                          -- Bebida
        [57073] = {priority = 9,   name = "Bebida"},                          -- Bebida
        [41425] = {priority = 9,   name = "Hipotermia"},                    -- Debuff Bloque de Hielo
        [25771] = {priority = 9,   name = "Penitencia"},                    -- Debuff Protección Divina
        [453]   = {priority = 9,   name = "Tranquilidad Mental"},                    -- Sacerdote
        [770]   = {priority = 9,   name = "Fuego Féerico"},                    -- Druida
        [19434] = {priority = 9,   name = "Disparo Certero"},                     -- Cazador
        [12294] = {priority = 9,   name = "Golpe Mortal"},                  -- Guerrero
        [13218] = {priority = 9,   name = "Veneno de Herida"},                   -- Pícaro
        [56112] = {priority = 9,   name = "Ataques Furiosos"},                -- Guerrero
        [23605] = {priority = 9,   name = "Caída de Día"},                      -- Brujo
        [13494] = {priority = 9,   name = "Manipulador de Muchedumbres Manual"},          -- Joya
        [23451] = {priority = 9,   name = "Velocidad de Batalla"},             -- Buff BG
        [23493] = {priority = 9,   name = "Sanación de Batalla"},              -- Buff BG
        [23505] = {priority = 9,   name = "Daño de Batalla"},            -- Buff BG
        [55277] = {priority = 9,   name = "Tótem Garra de Piedra"},                -- Chamán
        [58875] = {priority = 9,   name = "Caminata Espiritual"},                    -- Chamán
        [47986] = {priority = 9,   name = "Sacrificio"},                      -- Brujo
        [59578] = {priority = 9,   name = "Arte de la Guerra"},                 -- Paladín
        [768]   = {priority = 9,   name = "Forma Felina"},                       -- Druida
        [783]   = {priority = 9,   name = "Forma de Viaje"},                    -- Druida
        [9634]  = {priority = 9,   name = "Forma de Oso Atroz"},                 -- Druida
        [24858] = {priority = 9,   name = "Forma de Druida Luna"},                   -- Druida
        [33891] = {priority = 9,   name = "Ã�rbol de la Vida"},                   -- Druida
        [53312] = {priority = 9,   name = "Gracias de la Naturaleza"},                 -- Druida
        [53313] = {priority = 9,   name = "Raíces Enredadoras de Gracias"},         -- Druida
        [71]    = {priority = 9,   name = "Postura Defensiva"},               -- Guerrero
        [2457]  = {priority = 9,   name = "Postura de Batalla"},                  -- Guerrero
        [2458]  = {priority = 9,   name = "Postura de Berserker"},               -- Guerrero
    },
}


-- Orden de las categorias (1 = se muestra antes que cualquier otra)
local CAT_ORDER = { "immunities", "cc", "silence", "roots", "disarms", "defensives", "offensives", "others" }
SP.DEBUFF_CATS = CAT_ORDER

-- Tabla plana spellID -> { indice de categoria, prioridad, categoria }
local LOOKUP = {}
for ci, cat in ipairs(CAT_ORDER) do
	for id, d in pairs(DEBUFF_SPELLS[cat]) do
		LOOKUP[id] = { ci, d.priority, cat }
	end
end
DEBUFF_SPELLS = nil

-- Bloqueos de escuela por interrupcion: Pummel, Shield Bash, Kick, etc. no
-- dejan aura en el objetivo, asi que se detectan con SPELL_INTERRUPT del
-- registro de combate y se muestran como un silencio de prioridad maxima.
-- Duraciones de WotLK (segundos).
local LOCKOUTS = {
	[6552] = 4,   -- Pummel (Guerrero)
	[72] = 6,     -- Shield Bash (Guerrero)
	[1766] = 5,   -- Kick (Picaro)
	[2139] = 8,   -- Counterspell (Mago)
	[57994] = 2,  -- Wind Shear (Chaman)
	[47528] = 4,  -- Mind Freeze (Caballero de la Muerte)
	[19244] = 5,  -- Spell Lock rango 1 (Manafago)
	[19647] = 6,  -- Spell Lock rango 2 (Manafago)
	[19675] = 4,  -- Feral Charge - Bear (Druida)
	[26090] = 2,  -- Pummel (mascota gorila)
}
local SILENCE_INDEX
for i, cat in ipairs(CAT_ORDER) do if cat == "silence" then SILENCE_INDEX = i end end

local lockout = {} -- GUID -> { icon, dur, exp }
function SP.AddLockout(guid, spellId)
	local d = guid and LOCKOUTS[spellId]
	if not d then return end
	local _, _, icon = GetSpellInfo(spellId)
	local t = lockout[guid] or {}
	t.icon, t.dur, t.exp = icon, d, GetTime() + d
	lockout[guid] = t
	return true
end

-- Aura ganadora de la unidad (debuffs y buffs, como la WeakAura)
local function Best(unit, cfg)
	local now = GetTime()
	local bCi, bPri, bRem, bIcon, bDur, bExp
	local guid = UnitGUID(unit)
	local lo = guid and lockout[guid]
	if lo then
		if lo.exp <= now then
			lockout[guid] = nil
		elseif cfg.debuffLockouts and cfg.debuffCats.silence ~= false then
			bCi, bPri, bRem, bIcon, bDur, bExp = SILENCE_INDEX, 100, lo.exp - now, lo.icon, lo.dur, lo.exp
		end
	end
	for pass = 1, 2 do
		local get = pass == 1 and UnitDebuff or UnitBuff
		for i = 1, 40 do
			local name, _, icon, _, _, dur, exp, _, _, _, id = get(unit, i)
			if not name then break end
			local l = LOOKUP[id]
			if l and cfg.debuffCats[l[3]] ~= false and exp and exp > now then
				local ci, pri, rem = l[1], l[2], exp - now
				if not bCi or ci < bCi or (ci == bCi and (pri > bPri or (pri == bPri and rem > bRem))) then
					bCi, bPri, bRem, bIcon = ci, pri, rem, icon
					bDur = (dur and dur > 0) and dur or rem
					bExp = exp
				end
			end
		end
	end
	return bIcon, bDur, bExp
end

---------------------------- CIRCULO DE COOLDOWN ---------------------------
-- Mismo metodo que la WeakAura: franjas de textura en vez del modelo Cooldown
-- del cliente 3.3.5, que deja de dibujarse al pulsar teclas o moverse.
-- Zona oscura = tiempo transcurrido, en sentido horario desde las 12.
local PI, PI2, tan = math.pi, 2 * math.pi, math.tan

local function Rect(f, n, x1, x2, top, bh, L)
	local t = f.pool[n]
	if not t then
		t = f.sw:CreateTexture(nil, "OVERLAY")
		t:SetTexture(0, 0, 0, 0.5)
		f.pool[n] = t
	end
	if x2 - x1 > 0.05 then
		t:ClearAllPoints()
		t:SetPoint("TOPLEFT", f.sw, "TOPLEFT", x1 + L, -top)
		t:SetWidth(x2 - x1)
		t:SetHeight(bh)
		t:Show()
	else
		t:Hide()
	end
end

local function Draw(f, w, h, p)
	local R = math.floor(h + 0.5)
	if R < 2 then R = 2 end
	local bh = h / R
	local L = w / 2
	local th = (1 - p) * PI2
	for row = 0, R - 1 do
		local top = row * bh
		local dy = h / 2 - (row + 0.5) * bh
		if math.abs(dy) < 0.001 then dy = 0.001 end
		local a1, a2, b1, b2 = 0, 0, 0, 0
		if dy > 0 then
			if th <= 1.5 * PI then
				a1, a2 = -L, 0
			else
				a1, a2 = math.max(-L, -dy * tan(PI2 - th)), 0
			end
			if th <= 0 then
				b1, b2 = 0, L
			elseif th < PI / 2 then
				b1, b2 = dy * tan(th), L
			end
		else
			local ady = -dy
			if th <= PI / 2 then
				a1, a2 = -L, L
			elseif th < 1.5 * PI then
				a1, a2 = -L, math.min(L, ady * tan(PI - th))
			end
		end
		Rect(f, 2 * row + 1, -a2, -a1, top, bh, L)
		Rect(f, 2 * row + 2, -b2, -b1, top, bh, L)
	end
	for n = 2 * R + 1, #f.pool do f.pool[n]:Hide() end
end

local function OnUpdate(f, elapsed)
	f.acc = f.acc + elapsed
	if f.acc < 0.03 then return end
	f.acc = 0
	local now = GetTime()
	local rem = f.exp - now
	if rem <= 0 then f:Hide() return end
	local p = 1 - rem / f.dur
	if p < 0 then p = 0 elseif p > 1 then p = 1 end
	local w, h = f:GetWidth(), f:GetHeight()
	if w ~= f.lw or h ~= f.lh or math.abs(p - f.lastP) >= 0.001 then
		f.lw, f.lh, f.lastP = w, h, p
		Draw(f, w, h, p)
	end
	if f.showTimer then
		local s = rem >= 10 and string.format("%d", rem) or string.format("%.1f", rem)
		if s ~= f.lastS then f.lastS = s; f.text:SetText(s) end
	end
end

------------------------------ API PARA EL NUCLEO ------------------------------
function SP.BuildDebuff(sp)
	local f = CreateFrame("Frame", nil, sp)
	f:SetFrameLevel(sp:GetFrameLevel() + 10)
	f.edge = f:CreateTexture(nil, "BACKGROUND")
	f.edge:SetTexture(0, 0, 0, 1)
	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetAllPoints(f)
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.sw = CreateFrame("Frame", nil, f)
	f.sw:SetAllPoints(f)
	f.sw:SetFrameLevel(f:GetFrameLevel() + 1)
	f.pool = {}
	f.text = f.sw:CreateFontString(nil, "OVERLAY")
	f.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
	f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
	f.acc, f.lw, f.lh, f.lastP = 0, 0, 0, -1
	f:SetScript("OnUpdate", OnUpdate)
	f:Hide()
	sp.debuff = f
end

-- Tamano y posicion (lo llama Restyle)
-- Pega un icono a la izquierda o a la derecha de la barra, centrado en vertical
-- con ella. "inner" = otro icono del mismo lado: se coloca justo por fuera.
function SP.PlaceSideIcon(f, sp, side, fs, px, inner)
	local function snap(v) return px and math.floor(v / px + 0.5) * px or v end
	local cfg = SP.cfg
	f:ClearAllPoints()
	if inner then
		if side == "left" then
			f:SetPoint("RIGHT", inner, "LEFT", -snap(4), 0)
		else
			f:SetPoint("LEFT", inner, "RIGHT", snap(4), 0)
		end
	elseif side == "left" then
		-- Deja sitio al numero de arena si va a la izquierda de la barra
		local clear = (cfg.arenaIDs and cfg.arenaIDPos ~= "name") and (fs + 10) or 4
		f:SetPoint("RIGHT", sp, "LEFT", -snap(clear), 0)
	else
		-- Deja sitio al nivel (en el estilo Antiguo, a la cajita del marco dorado)
		local clear = fs * 1.6 + 8
		if cfg.shape == "old" then clear = 21.1 * sp:GetWidth() / 102.91 + 4 end
		f:SetPoint("LEFT", sp, "RIGHT", snap(clear), 0)
	end
end

function SP.LayoutDebuff(sp, px, fs)
	local f, cfg = sp.debuff, SP.cfg
	if not f then return end
	local function snap(v) return px and math.floor(v / px + 0.5) * px or v end
	local size = math.max(px or 1, snap(cfg.debuffSize))
	f:SetWidth(size)
	f:SetHeight(size)
	local one = px and math.max(px, snap(1)) or 1
	f.edge:ClearAllPoints()
	f.edge:SetPoint("TOPLEFT", f, "TOPLEFT", -one, one)
	f.edge:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", one, -one)
	f.text:SetFont(cfg.font, math.max(6, math.floor(size * 0.38)), "OUTLINE")
	f.showTimer = cfg.debuffTimer
	if cfg.debuffTimer then f.text:Show() else f.text:Hide() end
	SP.PlaceSideIcon(f, sp, cfg.debuffPos == "left" and "left" or "right", fs, px)
	f.lw, f.lh, f.lastP, f.lastS = 0, 0, -1, nil
end

-- Escanea las auras de la unidad (solo cuando llega UNIT_AURA o en el repaso)
function SP.UpdateDebuff(sp, unit, friendly)
	local f, cfg = sp.debuff, SP.cfg
	if not f then return end
	if not cfg.debuffs or (cfg.debuffEnemyOnly and friendly)
		or (cfg.debuffArenaOnly and select(2, IsInInstance()) ~= "arena") then
		f:Hide()
		return
	end
	local icon, dur, exp = Best(unit, cfg)
	if not icon then f:Hide() return end
	if f.exp ~= exp or f.dur ~= dur or f.tex ~= icon then
		f.exp, f.dur, f.tex = exp, dur, icon
		f.icon:SetTexture(icon)
		f.lastP, f.lastS = -1, nil
	end
	f:Show()
end
