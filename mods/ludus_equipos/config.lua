-- =========================================
-- CONFIGURACIÓN DEL MOD DE EQUIPOS
-- =========================================
local config = {}

-- 🎨 Skins por defecto
config.skin_default_entrada = "character_33" -- al ingresar o tras reset
config.skin_default_partida = "character_1"  -- al iniciar partida

-- 🌍 Spawn predeterminado
config.spawn_global_default = {x = 0, y = 50, z = 0}

-- 🧱 Bloque de construcción del área de spawn
config.spawn_material = "default:stone"

-- ⚙️ Parámetros de zonas
config.zona_base_default       = 10
config.zona_altura_default     = 3
config.zona_separacion_default = 20
config.zona_base_min           = 3
config.zona_altura_min         = 3
config.zona_base_max           = 100
config.zona_altura_max         = 50

-- Grid / layout defaults (usadas por zonas.lua)
config.zonas_filas_default    = 3
config.zonas_columnas_default = 5
config.offset_bajo_spawn      = 35

-- 🔢 Límites de inventario
config.max_bloques = 13 -- máximo por nombre de bloque (no herramientas)

-- ❤️ Vidas y puntos
config.vidas_iniciales  = 3
config.puntos_iniciales = 10

-- 👑 Administradores del servidor
config.administradores = {"creador", "profe_daniel", "admin"}

-- 👥 Usuarios permitidos (50 estudiantes + administradores)
config.usuarios_permitidos = {}
for i = 1, 60 do
  table.insert(config.usuarios_permitidos, "estudiante"..i)
end
for _, adm in ipairs(config.administradores) do
  table.insert(config.usuarios_permitidos, adm)
end

-- 🧭 Definición de equipos (15 zonas)
config.zonas_equipo = {
  {nombre = "Equipo Alfa",    color = "#FF0000", material = "default:stone",         skin = "character_1"},
  {nombre = "Equipo Beta",    color = "#00FF00", material = "default:wood",          skin = "character_2"},
  {nombre = "Equipo Gamma",   color = "#0000FF", material = "default:glass",         skin = "character_3"},
  {nombre = "Equipo Delta",   color = "#FFFF00", material = "default:sandstone",     skin = "character_4"},
  {nombre = "Equipo Épsilon", color = "#FF00FF", material = "default:brick",         skin = "character_5"},
  {nombre = "Equipo Zeta",    color = "#00FFFF", material = "default:steelblock",    skin = "character_6"},
  {nombre = "Equipo Eta",     color = "#FFA500", material = "default:clay",          skin = "character_7"},
  {nombre = "Equipo Theta",   color = "#A020F0", material = "default:obsidian",      skin = "character_8"},
  {nombre = "Equipo Iota",    color = "#808080", material = "default:desert_sand",   skin = "character_9"},
  {nombre = "Equipo Kappa",   color = "#FFFFFF", material = "default:snowblock",     skin = "character_10"},
  {nombre = "Equipo Lambda",  color = "#8B4513", material = "default:dirt",          skin = "character_11"},
  {nombre = "Equipo Mu",      color = "#4682B4", material = "default:ice",           skin = "character_12"},
  {nombre = "Equipo Nu",      color = "#B22222", material = "default:desert_stone",  skin = "character_13"},
  {nombre = "Equipo Xi",      color = "#2E8B57", material = "default:junglewood",    skin = "character_14"},
  {nombre = "Equipo Omicron", color = "#DAA520", material = "default:goldblock",     skin = "character_15"},
}

return config
-- =========================================