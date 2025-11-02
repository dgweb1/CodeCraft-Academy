-- zonas.lua - posiciones, creación y limpieza de zonas
local config = dofile(minetest.get_modpath("equipos") .. "/config.lua")
-- al inicio (si no existe ya)
local M = M or {}

-- Lista de spawns
local lista_spawns = {}
local spawn_actual_index = 1
-- garantizar tabla por defecto para evitar nils
M.zonas_equipo = config.zonas_equipo or {}

M.tamano      = { x = tonumber(config.zona_base_default) or 9, y = tonumber(config.zona_altura_default) or 6, z = tonumber(config.zona_base_default) or 9 }
M.separacion  = tonumber(config.zona_separacion_default) or 8

local filas    = tonumber(config.zonas_filas_default)    or 3
local columnas = tonumber(config.zonas_columnas_default) or 5
local offset_bajo_spawn = tonumber(config.offset_bajo_spawn) or 35

-- Persistencia simple de spawns
local function archivo_path() return minetest.get_worldpath() .. "/equipos_spawns.mt" end
local function guardar_lista_spawns()
  local f = io.open(archivo_path(), "w"); if not f then return false end
  f:write(minetest.serialize({ lista = lista_spawns, index = spawn_actual_index }))
  f:close(); return true
end
local function cargar_lista_spawns()
  local f = io.open(archivo_path(), "r"); if not f then return end
  local content = f:read("*all"); f:close()
  local ok, data = pcall(minetest.deserialize, content)
  if ok and type(data)=="table" and type(data.lista)=="table" then
    lista_spawns = data.lista
    spawn_actual_index = tonumber(data.index) or 1
    if spawn_actual_index < 1 then spawn_actual_index = 1 end
  end
end
cargar_lista_spawns()

-- Helpers spawn
local function get_spawn_actual_pos()
  local s = lista_spawns[spawn_actual_index]
  if s and s.pos then return s.pos end
  return config.spawn_global_default
end
M.get_spawn_actual  = get_spawn_actual_pos
M.get_spawn_global  = get_spawn_actual_pos -- alias

M.get_spawn_list    = function() return lista_spawns end
M.get_spawn_index   = function() return spawn_actual_index end

-- Plataforma 3x3 en spawn (NO llamar en init inmediato si no quieres tocar mundo)
function M.crear_plataforma_spawn()
  local s   = get_spawn_actual_pos()
  if not s then return false, "Spawn no definido." end
  local mat = config.spawn_material or "default:stone"
  local y   = s.y - 1
  for x = s.x - 1, s.x + 1 do
    for z = s.z - 1, s.z + 1 do
      minetest.set_node({ x = x, y = y, z = z }, { name = mat })
    end
  end
  return true, "Plataforma creada en spawn: " .. minetest.pos_to_string(s)
end

-- Genera centros y cajas de zonas, manteniendo gap constante (paso = base + separacion)
function M.generar_posiciones_zonas()
  if not M.zonas_equipo or #M.zonas_equipo == 0 then return false, "No hay zonas definidas." end
  local spawn  = get_spawn_actual_pos()
  if not spawn then return false, "Spawn no definido." end
  local base   = math.floor(M.tamano.x or 9)
  local alt    = math.floor(M.tamano.y or 6)
  local paso   = base + (M.separacion or 8)
  local base_y = spawn.y - offset_bajo_spawn

  local start_x = spawn.x - ((columnas - 1) * paso) / 2
  local start_z = spawn.z - ((filas    - 1) * paso) / 2

  for i = 1, #M.zonas_equipo do
    local row = math.floor((i-1) / columnas)
    local col = (i-1) % columnas
    local cx = math.floor(start_x + col * paso + 0.5)
    local cz = math.floor(start_z + row * paso + 0.5)
    local cy = math.floor(base_y + math.ceil(alt/2))
    local medio = math.floor(base/2)
    local p1 = { x = cx - medio, y = cy,           z = cz - medio }
    local p2 = { x = cx + medio, y = cy + alt - 1, z = cz + medio }
    M.zonas_equipo[i].centro = { x = cx, y = cy, z = cz }
    M.zonas_equipo[i].p1 = p1
    M.zonas_equipo[i].p2 = p2
  end
  return true, ("Posiciones regeneradas (base=%d, sep=%d, paso=%d)"):format(base, M.separacion, paso)
end

-- Ver zonas (centros)
function M.ver_zonas()
  if not M.zonas_equipo or #M.zonas_equipo == 0 then return "No hay zonas definidas." end
  M.generar_posiciones_zonas()
  local out = {}
  for i, z in ipairs(M.zonas_equipo) do
    local centro = z.centro or {x=0,y=0,z=0}
    table.insert(out, string.format("%d) %s -> %s", i, z.nombre or ("Zona "..i), minetest.pos_to_string(centro)))
  end
  return table.concat(out, "\n")
end

-- Ver spawns
function M.ver_spawns()
  local lines = {}
  for i, s in ipairs(lista_spawns) do
    local display_index = i - 1
    table.insert(lines, string.format("%d) %s %s", display_index, s.nombre or ("Spawn "..display_index), minetest.pos_to_string(s.pos)))
  end
  return table.concat(lines, "\n")
end

-- Ver un spawn por id (display id empezando en 0)
function M.ver_spawn(display_id)
  local idn = tonumber(display_id)
  if idn == nil then return "ID inválido" end
  local idx = idn + 1
  local s = lista_spawns[idx]
  if not s then return "Spawn no encontrado: "..tostring(display_id) end
  return (s.nombre or ("Spawn "..display_id)) .. " " .. minetest.pos_to_string(s.pos)
end

-- Elegir spawn (id mostrado inicia en 0)
function M.elegir_spawn(display_id)
  local idn = tonumber(display_id)
  if idn == nil then return false, "ID inválido" end
  local idx = idn + 1
  if not lista_spawns[idx] then return false, "Spawn no encontrado: " .. tostring(display_id) end
  spawn_actual_index = idx
  M.generar_posiciones_zonas()
  guardar_lista_spawns()
  return true, "Spawn elegido: " .. (lista_spawns[idx].nombre or ("Spawn "..display_id))
end

-- Definir spawn (coords opcionales; si no, usa tu posición)
function M.definir_spawn(caller_name, param)
  local player = minetest.get_player_by_name(caller_name)
  if not player then return false, "Jugador no encontrado." end
  local args = {}
  for token in string.gmatch(param or "", "%S+") do table.insert(args, token) end
  local pos
  if #args == 3 then
    pos = { x = tonumber(args[1]), y = tonumber(args[2]), z = tonumber(args[3]) }
    if not pos.x or not pos.y or not pos.z then return false, "Coordenadas inválidas." end
  else
    pos = vector.round(player:get_pos())
    if not pos then return false, "No se pudo obtener posición del jugador." end
  end

  local new_index = #lista_spawns + 1
  local display   = new_index - 1
  local name      = "Spawn " .. display
  table.insert(lista_spawns, { nombre = name, pos = pos })
  spawn_actual_index = new_index

  guardar_lista_spawns()
  M.generar_posiciones_zonas()
  player:set_pos(pos)
  return true, "Spawn definido y activado: " .. minetest.pos_to_string(pos) .. " (id " .. tostring(display) .. ")"
end

-- Ajustar separación
function M.set_separacion(n)
  n = tonumber(n)
  if not n or n <= 0 then return false, "Separación inválida." end
  M.separacion = n
  M.generar_posiciones_zonas()
  return true, "Separación actualizada a " .. tostring(n)
end
function M.get_separacion() return M.separacion end

-- Crear zona hueca (paredes) usando material
function M.crear_zona_equipo(idx, material_override)
  idx = tonumber(idx)
  if not idx then return false, "Índice inválido." end
  if not M.zonas_equipo[idx] then return false, "Zona "..tostring(idx).." no existe." end
  M.generar_posiciones_zonas()
  local z = M.zonas_equipo[idx]
  local p1, p2 = z.p1, z.p2
  if not p1 or not p2 then return false, "Coordenadas de zona no definidas." end
  local mat = material_override or z.material or config.zona_material_default or "default:stone"
  if not minetest.registered_nodes[mat] then return false, "Material inválido: "..tostring(mat) end

  for x = p1.x, p2.x do
    for y = p1.y, p2.y do
      for zc = p1.z, p2.z do
        -- dejar hueco interior: solo paredes/techo/suelo
        if x == p1.x or x == p2.x or zc == p1.z or zc == p2.z or y == p1.y or y == p2.y then
          minetest.set_node({ x = x, y = y, z = zc }, { name = mat })
        else
          minetest.set_node({ x = x, y = y, z = zc }, { name = "air" })
        end
      end
    end
  end
  return true, "Zona "..idx.." creada."
end

function M.crear_todas_las_zonas(mat)
  M.generar_posiciones_zonas()
  for i = 1, #M.zonas_equipo do
    local ok, msg = M.crear_zona_equipo(i, mat)
    if not ok then return false, msg end
  end
  return true, "Todas las zonas creadas" .. (mat and (" con material: "..mat) or ".")
end

-- Limpiar zona(s)
function M.limpiar_zona_equipo(idx)
  idx = tonumber(idx)
  if not idx or not M.zonas_equipo[idx] then return false, "Zona inválida." end
  M.generar_posiciones_zonas()
  local z = M.zonas_equipo[idx]
  local p1, p2 = z.p1, z.p2
  if not p1 or not p2 then return false, "Coordenadas de zona no definidas." end
  for x = p1.x, p2.x do
    for y = p1.y, p2.y do
      for zc = p1.z, p2.z do
        minetest.set_node({ x = x, y = y, z = zc }, { name = "air" })
      end
    end
  end
  return true, "Zona "..idx.." limpiada."
end

function M.limpiar_todas_las_zonas()
  M.generar_posiciones_zonas()
  for i = 1, #M.zonas_equipo do
    M.limpiar_zona_equipo(i)
  end
  return true, "Todas las zonas limpiadas."
end

-- Tamaño zona (base, altura)
function M.set_tamano(base, altura)
  local b = tonumber(base)
  local a = tonumber(altura)
  if not b or not a then return false, "Tamaño inválido." end
  M.tamano.x = b; M.tamano.y = a; M.tamano.z = b
  M.generar_posiciones_zonas()
  return true, "Tamaño aplicado: base="..b.." altura="..a
end
function M.get_tamano() return M.tamano end

-- Export (ya están asignadas funciones arriba)
M.ver_spawns              = M.ver_spawns
M.elegir_spawn            = M.elegir_spawn
M.definir_spawn           = M.definir_spawn
M.set_separacion          = M.set_separacion
M.get_separacion          = M.get_separacion
M.crear_zona_equipo       = M.crear_zona_equipo
M.crear_todas_las_zonas   = M.crear_todas_las_zonas
M.limpiar_zona_equipo     = M.limpiar_zona_equipo
M.limpiar_todas_las_zonas = M.limpiar_todas_las_zonas
M.ver_zonas               = M.ver_zonas
M.get_spawn_list          = function() return lista_spawns end
M.get_spawn_index         = function() return spawn_actual_index end

-- Registrar comandos útiles para que minetest.chatcommands[...] exista
if minetest.register_chatcommand then
  minetest.register_chatcommand("definir_spawn", {
    params = "[x y z]",
    description = "Define un spawn (si no hay coords usa tu posición).",
    privs = { server = true },
    func = function(name, param) local ok,msg = M.definir_spawn(name, param); if ok then return true, msg else return false, msg end end
  })
  minetest.register_chatcommand("ver_spawns", {
    description = "Lista spawns definidos.",
    func = function(name) return true, M.ver_spawns() end
  })
  minetest.register_chatcommand("ver_spawn", {
    params = "<id>",
    func = function(name, param) return true, M.ver_spawn(param) end
  })
  minetest.register_chatcommand("elegir_spawn", {
    params = "<id>",
    privs = { server = true },
    func = function(name, param) local ok,msg = M.elegir_spawn(param); if ok then return true, msg else return false, msg end end
  })
  minetest.register_chatcommand("eliminar_spawn", {
    params = "<id>",
    description = "Elimina un spawn por id (display id, empieza en 0).",
    privs = { server = true },
    func = function(name, param)
      if not param or param == "" then return false, "Uso: /eliminar_spawn <id>" end
      local ok, msg = M.eliminar_spawn(param)
      if ok then return true, msg else return false, msg end
    end
  })
end

-- Implementación segura para eliminar spawn (acepta display_id numérico o id/string)
function M.eliminar_spawn(display_id)
  local id = tostring(display_id or "")
  -- intentar como número (display id empieza en 0)
  local n = tonumber(id)
  local idx = n and (n + 1)

  -- si no es número, buscar por nombre/clave en la lista
  if not idx then
    for i, v in ipairs(lista_spawns) do
      if type(v) == "table" then
        if v.id == id or v.name == id or v.tag == id then idx = i; break end
      elseif tostring(v) == id then
        idx = i; break
      end
    end
  end

  if not idx or not lista_spawns[idx] then
    return false, "Spawn no encontrado: " .. id
  end

  table.remove(lista_spawns, idx)

  -- ajustar índice actual si es necesario
  if spawn_actual_index and spawn_actual_index > #lista_spawns then
    spawn_actual_index = math.max(1, #lista_spawns)
  end

  -- intentar guardar la lista mediante cualquiera de las funciones posibles
  local try_saves = { guardar_lista_spawns, save_spawns, guardar_spawns }
  for _, fn in ipairs(try_saves) do
    if type(fn) == "function" then
      pcall(fn)
      break
    end
  end

  -- regenerar posiciones si la función existe
  if type(M.generar_posiciones_zonas) == "function" then
    pcall(M.generar_posiciones_zonas)
  elseif type(generar_posiciones_zonas) == "function" then
    pcall(generar_posiciones_zonas)
  end

  return true, "Spawn eliminado: " .. id
end

-- Registrar chatcommand de forma segura (usa M.eliminar_spawn si existe)
if minetest.register_chatcommand and not minetest.registered_chatcommands["eliminar_spawn"] then
  minetest.register_chatcommand("eliminar_spawn", {
    params = "<id>",
    description = "Elimina un spawn por id (display id empieza en 0).",
    privs = { server = true },
    func = function(name, param)
      local id = (param or ""):match("%S+")
      if not id then return false, "Uso: /eliminar_spawn <id>" end

      if type(M.eliminar_spawn) == "function" then
        local ok, res_or_err = pcall(M.eliminar_spawn, id)
        if not ok then return false, "Error eliminando spawn: " .. tostring(res_or_err) end
        if type(res_or_err) == "boolean" then
          return true, "Spawn eliminado: " .. tostring(id)
        end
        return true, tostring(res_or_err)
      end

      -- fallback directo sobre lista (si existe)
      if not lista_spawns then return false, "Funcionalidad de spawns no disponible." end
      local n = tonumber(id)
      local idx = n and (n + 1)
      if not idx or not lista_spawns[idx] then return false, "Spawn no encontrado: " .. id end
      table.remove(lista_spawns, idx)
      if type(guardar_lista_spawns) == "function" then pcall(guardar_lista_spawns) end
      if type(M.generar_posiciones_zonas) == "function" then pcall(M.generar_posiciones_zonas) end
      return true, "Spawn eliminado: " .. id
    end,
  })
end

-- asegurarse de exportar la API pública
return M
