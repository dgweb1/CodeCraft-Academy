-- init.lua - Sistema de equipos (consolida comandos, panel admin y fixes)
local modname = "equipos"
local modpath = minetest.get_modpath(modname)
local config  = dofile(modpath .. "/config.lua")

-- Cargar zonas de forma segura
local zonas_ok, zonas_mod = pcall(dofile, modpath .. "/zonas.lua")
local zonas = (zonas_ok and zonas_mod) or {}

-- Cargar módulo de registro (eventos de partida)
local ok_reg, registro_mod = pcall(dofile, modpath .. "/registro.lua")
if not ok_reg then
  minetest.log("warning", "[equipos] No se pudo cargar registro.lua: " .. tostring(registro_mod))
end

-- Skins por defecto
local skin_default_entrada = config.skin_default_entrada or "character_1"
local skin_default_partida = config.skin_default_partida or skin_default_entrada

-- Asignaciones: jugador -> nombre de equipo
local asignaciones = {}
math.randomseed(os.time())

-- ========= Persistencias simples =========
local worldpath = minetest.get_worldpath()
local expulsados_file   = worldpath .. "/equipos_expulsados.mt"
local castigo_file      = worldpath .. "/equipos_castigo.mt"

local expulsados = {}      -- set de nombres expulsados
local zona_castigo_pos = nil
local zona_castigo_duracion = 120 -- seg

local function save_table(path, t)
  local f = io.open(path, "w"); if not f then return false end
  f:write(minetest.serialize(t)); f:close(); return true
end
local function load_table(path)
  local f = io.open(path, "r"); if not f then return nil end
  local s = f:read("*all"); f:close()
  local ok, data = pcall(minetest.deserialize, s)
  if ok and type(data)=="table" then return data end
  return nil
end

do
  local e = load_table(expulsados_file); if type(e)=="table" then expulsados = e end
  local c = load_table(castigo_file)
  if type(c)=="table" then
    zona_castigo_pos = c.pos
    if tonumber(c.dur) then zona_castigo_duracion = tonumber(c.dur) end
  end
end

-- ===== Persistencia adicional: zonas, spawns y pausados =====
local zonas_file   = worldpath .. "/equipos_zonas.mt"
local spawns_file  = worldpath .. "/equipos_spawns.mt"
local pausados_file= worldpath .. "/equipos_pausados.mt"

-- Cargar datos de zonas/spawns/pausados si existen y volcarlos en el módulo zonas o en tablas locales
do
  -- zonas
  local zd = load_table(zonas_file)
  if zd and zonas and type(zonas) == "table" then
    if type(zd) == "table" then
      zonas.zonas_equipo = zd
      minetest.log("action", "[equipos] zonas cargadas desde persistencia ("..tostring(#zd).." zonas).")
    end
  end
  -- spawns
  local sd = load_table(spawns_file)
  if sd and zonas and type(zonas) == "table" then
    if type(sd) == "table" then
      zonas.lista_spawns = sd
      minetest.log("action", "[equipos] spawns cargados desde persistencia ("..tostring(#sd).." spawns).")
    end
  end
  -- pausados
  local pd = load_table(pausados_file)
  if pd and type(pd) == "table" then
    pausados = pd
    minetest.log("action", "[equipos] pausados cargados desde persistencia ("..tostring(#pd).." entradas).")
  end
end

-- Helpers de persistencia (uso interno)
local function persist_zonas()
  if zonas and type(zonas.zonas_equipo) == "table" then
    save_table(zonas_file, zonas.zonas_equipo)
    minetest.log("action", "[equipos] zonas guardadas ("..tostring(#zonas.zonas_equipo)..").")
  end
end
local function persist_spawns()
  if zonas then
    if type(zonas.lista_spawns) == "table" then
      save_table(spawns_file, zonas.lista_spawns)
      minetest.log("action", "[equipos] spawns guardados ("..tostring(#zonas.lista_spawns)..").")
      return
    end
    if type(zonas.get_spawns) == "function" then
      local ok, t = pcall(zonas.get_spawns)
      if ok and type(t) == "table" then
        save_table(spawns_file, t)
        minetest.log("action", "[equipos] spawns guardados (vía get_spawns).")
      end
    end
  end
end
local function persist_pausados() save_table(pausados_file, pausados); minetest.log("action", "[equipos] pausados guardados.") end
local function persist_expulsados() save_table(expulsados_file, expulsados); minetest.log("action", "[equipos] expulsados guardados.") end
local function persist_castigo() save_table(castigo_file, { pos = zona_castigo_pos, dur = zona_castigo_duracion }); minetest.log("action", "[equipos] zona_castigo guardada.") end

-- Envuelvo (wrap) funciones del módulo zonas para forzar persistencia tras cambios (si existen)
if zonas and type(zonas) == "table" then
  -- crear zona
  if type(zonas.crear_zona_equipo) == "function" then
    local _orig = zonas.crear_zona_equipo
    zonas.crear_zona_equipo = function(...)
      local ok, msg = _orig(...)
      if ok then pcall(persist_zonas) end
      return ok, msg
    end
  end
  -- crear todas
  if type(zonas.crear_todas_las_zonas) == "function" then
    local _orig = zonas.crear_todas_las_zonas
    zonas.crear_todas_las_zonas = function(...)
      local ok, msg = _orig(...)
      if ok then pcall(persist_zonas) end
      return ok, msg
    end
  end
  -- limpiar zona
  if type(zonas.limpiar_zona_equipo) == "function" then
    local _orig = zonas.limpiar_zona_equipo
    zonas.limpiar_zona_equipo = function(...)
      local ok, msg = _orig(...)
      if ok then pcall(persist_zonas) end
      return ok, msg
    end
  end
  -- limpiar todas
  if type(zonas.limpiar_todas_las_zonas) == "function" then
    local _orig = zonas.limpiar_todas_las_zonas
    zonas.limpiar_todas_las_zonas = function(...)
      local ok, msg = _orig(...)
      if ok then pcall(persist_zonas) end
      return ok, msg
    end
  end
  -- spawns: definir / eliminar
  if type(zonas.definir_spawn) == "function" then
    local _orig = zonas.definir_spawn
    zonas.definir_spawn = function(player, param)
      local ok, msg = _orig(player, param)
      if ok then pcall(persist_spawns) end
      return ok, msg
    end
  end
  if type(zonas.eliminar_spawn) == "function" then
    local _orig = zonas.eliminar_spawn
    zonas.eliminar_spawn = function(id)
      local ok, msg = _orig(id)
      if ok then pcall(persist_spawns) end
      return ok, msg
    end
  end
end

-- Asegurar guardado al cerrar el servidor
minetest.register_on_shutdown(function()
  pcall(persist_expulsados)
  pcall(persist_castigo)
  pcall(persist_pausados)
  pcall(persist_zonas)
  pcall(persist_spawns)
end)

-- Registrar guardados periódicos (evita pérdidas por crash) cada 60s
local function periodic_save()
  pcall(persist_expulsados)
  pcall(persist_castigo)
  pcall(persist_pausados)
  pcall(persist_zonas)
  pcall(persist_spawns)
  minetest.after(60, periodic_save)
end
minetest.after(30, periodic_save)

-- ========= Utilidades =========
local function es_administrador(name)
  for _, a in ipairs(config.administradores) do if a == name then return true end end
  return false
end

local function permitido_base(name)
  for _, u in ipairs(config.usuarios_permitidos) do if u == name then return true end end
  return false
end

local function safe_update_skin(player_name, skin_id)
  if not player_name or not skin_id then return end
  if rawget(_G, "skins") and type(skins.update_player_skin) == "function" then
    skins.skins[player_name] = skin_id
    local p = minetest.get_player_by_name(player_name)
    if p then
      p:get_meta():set_string("simple_skins:skin", skin_id)
      skins.update_player_skin(p)
    end
  end
end

local function send_multiline(player_name, text)
  if not text then return end
  for line in string.gmatch(text, "[^\n]+") do
    minetest.chat_send_player(player_name, line)
  end
end

-- ========= Vidas y puntos =========
local function get_vidas(name)
  local p = minetest.get_player_by_name(name); if not p then return config.vidas_iniciales end
  local n = tonumber(p:get_meta():get_string("equipos:vidas"))
  if not n then return config.vidas_iniciales end
  return n
end
local function set_vidas(name, n)
  local p = minetest.get_player_by_name(name); if not p then return end
  p:get_meta():set_string("equipos:vidas", tostring(n))
end
local function get_puntos(name)
  local p = minetest.get_player_by_name(name); if not p then return config.puntos_iniciales end
  local n = tonumber(p:get_meta():get_string("equipos:puntos"))
  if not n then return config.puntos_iniciales end
  return n
end
local function set_puntos(name, n)
  local p = minetest.get_player_by_name(name); if not p then return end
  p:get_meta():set_string("equipos:puntos", tostring(n))
end

local function perder_vida(name, motivo)
  local vidas = get_vidas(name) - 1
  set_vidas(name, vidas)
  minetest.chat_send_player(name, "❤️ Has perdido una vida" .. (motivo and (" ("..motivo..")") or "") .. ". Vidas restantes: "..math.max(vidas,0))
  if vidas <= 0 then
    expulsados[name] = true
    save_table(expulsados_file, expulsados)
    minetest.chat_send_all("⛔ "..name.." se quedó sin vidas y ha sido expulsado hasta reinicio o autorización.")
    minetest.kick_player(name, "Sin vidas. Espera reinicio de partida o autorización del administrador.")
  end
end

local function aplicar_penalizacion(name, puntos)
  puntos = tonumber(puntos) or 1
  local actual = get_puntos(name)
  local nuevo  = actual - puntos
  if nuevo <= 0 then
    set_puntos(name, config.puntos_iniciales)
    perder_vida(name, "penalizaciones ("..actual.."→0)")
  else
    set_puntos(name, nuevo)
    minetest.chat_send_player(name, "⚠ Penalización: -" .. puntos .. " punto(s). Puntos: "..nuevo)
  end
end

-- ========= Inventario: límites y drop =========
local herramientas = {"pick", "shovel", "axe", "sword", "hoe", "hammer"}
local function tool_type(name)
  for _, t in ipairs(herramientas) do
    if name:find(t, 1, true) then return t end
  end
  return nil
end

local function drop_from_stack(player, listname, index, to_drop)
  if to_drop <= 0 then return 0 end
  local inv = player:get_inventory()
  local stack = inv:get_stack(listname, index)
  if stack:is_empty() then return 0 end
  local n = math.min(to_drop, stack:get_count())
  local taken = stack:take_item(n)
  inv:set_stack(listname, index, stack)
  local pos = player:get_pos(); pos.y = pos.y + 1.5
  minetest.add_item(pos, taken)
  return n
end

-- enforce_inventory_limits: elimina inmediatamente el exceso (sin delays)
function enforce_inventory_limits(player)
  if not player or type(player) ~= "userdata" or not player.get_player_name or not player.is_player or not player:is_player() then return end
  local name = player:get_player_name()
  if es_administrador(name) then return end -- admins sin límites
  local inv  = player:get_inventory(); if not inv then return end

  local max_bloques = tonumber(config.max_bloques) or 10

  -- indexar lista main
  local main = inv:get_list("main") or {}
  local total_by_item, idxs_by_item = {}, {}
  local total_by_tooltype, idxs_by_tooltype = {}, {}

  for i, stack in ipairs(main) do
    if stack and not stack:is_empty() then
      local item = stack:get_name()
      local c = stack:get_count()
      total_by_item[item] = (total_by_item[item] or 0) + c
      idxs_by_item[item] = idxs_by_item[item] or {}
      table.insert(idxs_by_item[item], i)
      local tt = tool_type(item)
      if tt then
        total_by_tooltype[tt] = (total_by_tooltype[tt] or 0) + c
        idxs_by_tooltype[tt] = idxs_by_tooltype[tt] or {}
        table.insert(idxs_by_tooltype[tt], i)
      end
    end
  end

  local pos = player:get_pos() or {x=0,y=0,z=0}; pos.y = pos.y + 1.5

  -- 1) Herramientas: mantener 1 por tipo, eliminar extras inmediatamente
  for tt, total in pairs(total_by_tooltype) do
    if total > 1 then
      local to_remove = total - 1
      local indices = idxs_by_tooltype[tt] or {}
      -- eliminar desde el final para preservar primeras stacks
      for k = #indices, 1, -1 do
        if to_remove <= 0 then break end
        local idx = indices[k]
        local stack = inv:get_stack("main", idx)
        if stack and not stack:is_empty() then
          local available = stack:get_count()
          local keep = (k == 1) and 1 or 0
          local can_remove = math.max(0, available - keep)
          if can_remove > 0 then
            local n = math.min(can_remove, to_remove)
            -- usar funcion segura para dropear y actualizar stack
            drop_from_stack(player, "main", idx, n)
            to_remove = to_remove - n
          end
        end
      end
      minetest.chat_send_player(name, "🛠️ Solo una herramienta por tipo ('"..tt.."'). Exceso eliminado.")
    end
  end

  -- 2) Recalcular totales después de eliminar herramientas
  main = inv:get_list("main") or {}
  total_by_item, idxs_by_item = {}, {}
  for i, stack in ipairs(main) do
    if stack and not stack:is_empty() then
      local item = stack:get_name()
      local c = stack:get_count()
      total_by_item[item] = (total_by_item[item] or 0) + c
      idxs_by_item[item] = idxs_by_item[item] or {}
      table.insert(idxs_by_item[item], i)
    end
  end

  -- 3) Bloques: asegurar max_bloques por item, eliminar exceso inmediatamente
  for item, total in pairs(total_by_item) do
    if not tool_type(item) and total > max_bloques then
      local to_remove = total - max_bloques
      local indices = idxs_by_item[item] or {}
      for idx_ptr = #indices, 1, -1 do
        if to_remove <= 0 then break end
        local idx = indices[idx_ptr]
        local stack = inv:get_stack("main", idx)
        if stack and not stack:is_empty() then
          local remove_n = math.min(to_remove, stack:get_count())
          local removed = drop_from_stack(player, "main", idx, remove_n)
          to_remove = to_remove - removed
        end
      end
      minetest.chat_send_player(name, "📦 Límite de '"..item.."' = "..max_bloques..". Exceso eliminado.")
    end
  end
end

-- ===== Eventos: llamadas síncronas para eliminar el exceso en el instante =====

-- acción en inventario (arrastrar/soltar/mover)
minetest.register_on_player_inventory_action(function(player, action, ...)
  if player and type(player)=="userdata" and player.is_player and player:is_player() then
    pcall(enforce_inventory_limits, player)
  end
end)

-- pickup de items: ejecutar inmediatamente (sin after) para eliminar exceso al instante
if minetest.register_on_item_pickup then
  minetest.register_on_item_pickup(function(player, itemstack)
    -- protegerse contra player nil o no-player
    local pname = nil
    if player == nil then
      pname = "(nil)"
    elseif type(player) == "string" then
      pname = player
    elseif type(player) == "userdata" and player.get_player_name and player.is_player and player:is_player() then
      pname = player:get_player_name()
    else
      pname = "(unknown)"
    end

    minetest.log("action", "[equipos] on_item_pickup fired for " .. tostring(pname))

    -- Intentar ejecutar enforce sobre el objeto player si es válido, sino resolver por nombre
    if type(player) == "userdata" and player.get_player_name and player.is_player and player:is_player() then
      minetest.after(0.12, function()
        if player and player.is_player and player:is_player() then pcall(enforce_inventory_limits, player) end
      end)
      minetest.after(0.30, function()
        if player and player.is_player and player:is_player() then pcall(enforce_inventory_limits, player) end
      end)
    elseif pname and pname ~= "(nil)" and pname ~= "(unknown)" then
      minetest.after(0.12, function()
        local p = minetest.get_player_by_name(pname)
        if p and p.is_player and p:is_player() then pcall(enforce_inventory_limits, p) end
      end)
      minetest.after(0.30, function()
        local p = minetest.get_player_by_name(pname)
        if p and p.is_player and p:is_player() then pcall(enforce_inventory_limits, p) end
      end)
    end
  end)
else
  minetest.log("action", "[equipos] register_on_item_pickup no disponible - usando inventory_action fallback")
end

-- al minar: items pueden entrar al inventario; verificar inmediatamente
minetest.register_on_dignode(function(pos, oldnode, digger)
  if digger and digger.is_player and digger:is_player() then
    pcall(enforce_inventory_limits, digger)
  end
end)

-- al fabricar: verificar inmediatamente
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
  if player and player.is_player and player:is_player() then
    pcall(enforce_inventory_limits, player)
  end
end)

-- al unirse/respawn: doble check con pequeña espera sigue siendo útil
minetest.register_on_joinplayer(function(player)
  minetest.after(0.2, function() if player and player.is_player and player:is_player() then pcall(enforce_inventory_limits, player) end end)
end)
minetest.register_on_respawnplayer(function(player)
  minetest.after(0.2, function() if player and player.is_player and player:is_player() then pcall(enforce_inventory_limits, player) end end)
  return true
end)

-- ============================================================
-- Muerte: dropear TODO el inventario en la posición de muerte
-- ============================================================
minetest.register_on_dieplayer(function(player)
  if not player or not player.is_player or not player:is_player() then return end
  local name = player:get_player_name()
  local pos = player:get_pos() or {x=0,y=0,z=0}
  pos.y = pos.y + 0.5

  local inv = player:get_inventory()
  if inv then
    -- Dropear todas las listas relevantes: main, craft, craftpreview, armor (si existe)
    local lists = {"main","craft","craftpreview"}
    for _, listname in ipairs(lists) do
      local lst = inv:get_list(listname)
      if lst and type(lst) == "table" then
        for i = 1, #lst do
          local stack = inv:get_stack(listname, i)
          if stack and not stack:is_empty() then
            minetest.add_item(pos, stack)
          end
        end
        inv:set_list(listname, {}) -- vaciar la lista después de dropear
      end
    end
    -- intentar dropear cualquier otra lista (ej. armour) si existe
    for k,_ in pairs(inv:get_lists() or {}) do
      if k ~= "main" and k ~= "craft" and k ~= "craftpreview" then
        local lst = inv:get_list(k)
        if lst and type(lst) == "table" then
          for i = 1, #lst do
            local stack = inv:get_stack(k, i)
            if stack and not stack:is_empty() then
              minetest.add_item(pos, stack)
            end
          end
          inv:set_list(k, {})
        end
      end
    end
  end

  -- aplicar pérdida de vida / expulsión como antes (mantener lógica)
  minetest.after(0, function() perder_vida(name, "muerte") end)
end)

-- ========= Skin lock (estudiantes) =========
if rawget(_G, "skins") then
  local old_event = skins.event_CHG
  skins.event_CHG = function(event, player)
    if not player then if old_event then return old_event(event, player) end return end
    if not player.is_player or not player:is_player() then return end
    local name = player:get_player_name()
    if es_administrador(name) then if old_event then return old_event(event, player) end return end
    local forced_skin = skin_default_entrada
    if asignaciones[name] then
      local equipo_nombre = asignaciones[name]
      for _, z in ipairs(zonas.zonas_equipo or {}) do
        if z.nombre == equipo_nombre and z.skin then forced_skin = z.skin break end
      end
    end
    skins.skins[name] = forced_skin
    player:get_meta():set_string("simple_skins:skin", forced_skin)
    skins.update_player_skin(player)
    minetest.chat_send_player(name, "⚠ No puedes cambiar tu skin. Tu equipo tiene el skin: " .. tostring(forced_skin))
  end
end

-- ========= Prejoin / Join =========
minetest.register_on_prejoinplayer(function(name)
  if not permitido_base(name) then
    return "⛔ No estás autorizado para ingresar al servidor."
  end
  if expulsados[name] then
    return "⛔ No puedes ingresar: te quedaste sin vidas. Espera reinicio o autorización admin."
  end
end)

minetest.register_on_joinplayer(function(player)
  if not player or not player.is_player or not player:is_player() then return end
  local name = player:get_player_name()

  -- inicializar vidas/puntos si faltan
  if tonumber(player:get_meta():get_string("equipos:vidas")) == nil then set_vidas(name, config.vidas_iniciales) end
  if tonumber(player:get_meta():get_string("equipos:puntos")) == nil then set_puntos(name, config.puntos_iniciales) end

  local spawn = (zonas.get_spawn_actual and zonas.get_spawn_actual()) or config.spawn_global_default
  if spawn then player:set_pos(spawn) end

  if es_administrador(name) then
    -- Construir mapa de privilegios => true
    local all = {}
    for priv,_ in pairs(minetest.registered_privileges) do all[priv] = true end
    minetest.set_player_privs(name, all)
    minetest.chat_send_player(name, "👑 Bienvenido administrador.")
    -- Dar Manual Admin
    local inv = player:get_inventory()
    if inv and not inv:contains_item("main", "equipos:manual_admin") then
      inv:add_item("main", "equipos:manual_admin")
    end
  else
    minetest.set_player_privs(name, { shout = true, interact = true })
    safe_update_skin(name, skin_default_entrada)
    minetest.chat_send_player(name, "Bienvenido. Vidas: "..get_vidas(name).." | Puntos: "..get_puntos(name))
  end

  -- Enforce inventario con retardo corto
  minetest.after(0.2, function()
    local p = minetest.get_player_by_name(name)
    if p and p.is_player and p:is_player() then enforce_inventory_limits(p) end
  end)
end)

-- ========= Asignaciones y TP a su zona =========
local function tp_a_zona_asignada(player_name)
  local zonas_tab = zonas.zonas_equipo
  if not zonas_tab then return false end
  local equipo = asignaciones[player_name]; if not equipo then return false end
  for idx, z in ipairs(zonas_tab) do
    if z.nombre == equipo and z.centro then
      local t = zonas.get_tamano()
      local techo_y = (z.p2 and z.p2.y) or (z.centro.y + t.y - 1)
      local p = minetest.get_player_by_name(player_name)
      if p and p.is_player and p:is_player() then p:set_pos({ x = z.centro.x, y = techo_y + 1, z = z.centro.z }) end
      return true
    end
  end
  return false
end

-- ========= Comandos de partida =========
minetest.register_chatcommand("iniciar_partida", {
  params      = "<1|3|5>",
  description = "Reparte estudiantes 1, 3 o 5 por zona.",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local tam = tonumber(param)
    if tam ~= 1 and tam ~= 3 and tam ~= 5 then return false, "Uso: /iniciar_partida 1|3|5" end

    if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end
    local zonas_tab = zonas.zonas_equipo
    if not zonas_tab or #zonas_tab == 0 then return false, "No hay zonas definidas." end

    local estudiantes = {}
    for _, p in ipairs(minetest.get_connected_players()) do
      local pn = p:get_player_name()
      if not es_administrador(pn) then table.insert(estudiantes, pn) end
    end
    if #estudiantes == 0 then return false, "No hay estudiantes conectados." end

    -- preparar estado
    for _, pn in ipairs(estudiantes) do
      safe_update_skin(pn, skin_default_partida)
      set_vidas(pn, config.vidas_iniciales)
      set_puntos(pn, config.puntos_iniciales)
      expulsados[pn] = nil
    end
    save_table(expulsados_file, expulsados)

    -- mezclar
    for i = #estudiantes, 2, -1 do
      local j = math.random(i)
      estudiantes[i], estudiantes[j] = estudiantes[j], estudiantes[i]
    end

    asignaciones = {}
    local Z = #zonas_tab
    if tam == 1 then
      for idx, pname in ipairs(estudiantes) do
        local p = minetest.get_player_by_name(pname)
        if p and p.is_player and p:is_player() then
          local zi = ((idx - 1) % Z) + 1
          local z  = zonas_tab[zi]
          asignaciones[pname] = z.nombre or ("Equipo"..zi)
          local t = zonas.get_tamano()
          local techo_y = (z.p2 and z.p2.y) or (z.centro.y + t.y - 1)
          p:set_pos({ x = z.centro.x, y = techo_y + 1, z = z.centro.z })
          safe_update_skin(pname, z.skin or skin_default_partida)
          minetest.chat_send_player(pname, "🎯 Equipo: "..asignaciones[pname].." | Zona "..zi)
        end
      end
    else
      local grupo, idx = 1, 1
      while idx <= #estudiantes do
        for _ = 1, tam do
          local pname = estudiantes[idx]
          if pname then
            local p = minetest.get_player_by_name(pname)
            if p and p.is_player and p:is_player() then
              local zi = ((grupo - 1) % Z) + 1
              local z  = zonas_tab[zi]
              asignaciones[pname] = z.nombre or ("Equipo"..zi)
              local t = zonas.get_tamano()
              local techo_y = (z.p2 and z.p2.y) or (z.centro.y + t.y - 1)
              p:set_pos({ x = z.centro.x, y = techo_y + 1, z = z.centro.z })
              safe_update_skin(pname, z.skin or skin_default_partida)
              minetest.chat_send_player(pname, "🎯 Equipo: "..asignaciones[pname].." | Zona "..zi)
            end
          end
          idx = idx + 1
        end
        grupo = grupo + 1
      end
    end

    return true, "✅ Partida iniciada: "..#estudiantes.." estudiantes repartidos."
  end
})

minetest.register_chatcommand("reset_partida", {
  description = "Vuelve todo al estado inicial (spawn, skins, vidas/puntos, limpia expulsiones).",
  privs       = { server = true },
  func = function(name)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local spawn = (zonas.get_spawn_actual and zonas.get_spawn_actual()) or config.spawn_global_default
    for _, p in ipairs(minetest.get_connected_players()) do
      if p and p.is_player and p:is_player() then
        local pn = p:get_player_name()
        if not es_administrador(pn) then
          if spawn then p:set_pos(spawn) end
          safe_update_skin(pn, skin_default_entrada)
          minetest.set_player_privs(pn, { shout = true, interact = true })
          set_vidas(pn, config.vidas_iniciales)
          set_puntos(pn, config.puntos_iniciales)
        else
          local all = {}; for priv,_ in pairs(minetest.registered_privileges) do all[priv]=true end
          minetest.set_player_privs(pn, all)
        end
      end
    end
    asignaciones = {}
    expulsados = {}; save_table(expulsados_file, expulsados)
    return true, "🔁 Partida reseteada."
  end
})

-- ========= Zona de castigo =========
local pausados = pausados or {}
local function guardar_castigo() save_table(castigo_file, {pos = zona_castigo_pos, dur = zona_castigo_duracion}) end

local function aplicar_castigo(objetivo, motivo_txt)
  if not objetivo or pausados[objetivo] then return end
  local player = minetest.get_player_by_name(objetivo)
  if not player or not player.is_player or not player:is_player() then return end
  local pos_original = player:get_pos()
  local destino = zona_castigo_pos or (zonas.get_spawn_actual and zonas.get_spawn_actual()) or config.spawn_global_default
  player:set_pos(destino)
  player:set_physics_override({speed=0, jump=0, gravity=1})
  minetest.set_player_privs(objetivo, {shout=true})
  pausados[objetivo] = { pos_original = pos_original, tiempo = zona_castigo_duracion, inicio = os.time() }
  minetest.chat_send_all("⛔ "..objetivo.." fue enviado a la zona de castigo"..(motivo_txt and (" ("..motivo_txt..")") or "")..".")

  aplicar_penalizacion(objetivo, 1)

  minetest.after(zona_castigo_duracion, function()
    if pausados[objetivo] then
      local p = minetest.get_player_by_name(objetivo)
      if p and p.is_player and p:is_player() then
        p:set_pos(pausados[objetivo].pos_original)
        p:set_physics_override({speed=1, jump=1, gravity=1})
        minetest.set_player_privs(objetivo, {interact=true, shout=true})
        minetest.chat_send_all("✅ "..objetivo.." ha cumplido la sanción.")
      end
      pausados[objetivo] = nil
    end
  end)
end

minetest.register_chatcommand("definir_zona_castigo", {
  params      = "[x y z] [min]",
  description = "Fija zona/duración de castigo (sin coords: tu posición).",
  privs       = {server = true},
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local args = {}; for t in (param or ""):gmatch("%S+") do table.insert(args, t) end
    local pos; local min
    if #args >= 3 then
      pos = {x=tonumber(args[1]), y=tonumber(args[2]), z=tonumber(args[3])}
      if not pos.x or not pos.y or not pos.z then return false, "Coordenadas inválidas." end
      if #args >= 4 then min = tonumber(args[4]) end
    else
      local p = minetest.get_player_by_name(name); if not p then return false, "Jugador no encontrado." end
      pos = vector.round(p:get_pos())
      if #args == 1 then min = tonumber(args[1]) end
    end
    if min and min > 0 then zona_castigo_duracion = math.floor(min * 60) end
    zona_castigo_pos = pos; guardar_castigo()
    return true, string.format("Zona de castigo: %s | duración: %d s", minetest.pos_to_string(pos), zona_castigo_duracion)
  end
})

minetest.register_chatcommand("ver_zona_castigo", {
  description = "Muestra la zona de castigo y su duración.",
  privs       = {server = true},
  func = function(name)
    local pos = zona_castigo_pos or (zonas.get_spawn_actual and zonas.get_spawn_actual()) or config.spawn_global_default
    return true, string.format("Zona de castigo: %s | duración: %d s", minetest.pos_to_string(pos), zona_castigo_duracion)
  end
})

-- Autorizar (levanta expulsión)
minetest.register_chatcommand("autorizar", {
  params = "<jugador>",
  description = "Permite reingresar a un jugador expulsado (vidas/puntos reseteados).",
  privs = {server = true},
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local objetivo = (param or ""):match("%S+"); if not objetivo then return false, "Uso: /autorizar <jugador>" end
    expulsados[objetivo] = nil; save_table(expulsados_file, expulsados)
    local p = minetest.get_player_by_name(objetivo)
    if p and p.is_player and p:is_player() then
      set_vidas(objetivo, config.vidas_iniciales)
      set_puntos(objetivo, config.puntos_iniciales)
      minetest.chat_send_player(objetivo, "✅ Autorizado por "..name..". Vidas y puntos restaurados.")
    end
    return true, "Autorizado: "..objetivo
  end
})

-- Penalizar manual
minetest.register_chatcommand("penalizar", {
  params = "<jugador> [puntos]",
  description = "Resta puntos al jugador (default 1). Si llega a 0, pierde vida.",
  privs = {server = true},
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local target, pts = param:match("^(%S+)%s*(%S*)$")
    if not target then return false, "Uso: /penalizar <jugador> [puntos]" end
    aplicar_penalizacion(target, tonumber(pts) or 1)
    return true, "Penalizado: "..target
  end
})

-- ========= Zonas: crear/limpiar/ver/etc. (sin /generar_zonas público) =========
minetest.register_chatcommand("crear_zona", {
  params      = "<número> [material]",
  description = "Crea la zona n con material opcional.",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local idx, mat = param:match("^(%S+)%s*(%S*)$")
    if not idx then return false, "Uso: /crear_zona <n> [material]" end
    if mat == "" then mat = nil end
    if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end
    local ok, msg = zonas.crear_zona_equipo(idx, mat)
    if ok then return true, msg else return false, msg end
  end
})

minetest.register_chatcommand("crear_zonas", {
  params      = "[material]",
  description = "Crea todas las zonas (material opcional).",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local mat = (param and param ~= "") and param or nil
    if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end
    local ok, msg = zonas.crear_todas_las_zonas(mat)
    if ok then return true, msg else return false, msg end
  end
})

minetest.register_chatcommand("limpiar_zona", {
  params      = "<número>",
  description = "Limpia la zona n (reemplaza por air).",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local idx = tonumber(param)
    if not idx then return false, "Uso: /limpiar_zona <número>" end
    if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end
    local ok, msg = zonas.limpiar_zona_equipo(idx)
    if ok then return true, msg else return false, msg end
  end
})

minetest.register_chatcommand("limpiar_zonas", {
  description = "Limpia todas las zonas.",
  privs       = { server = true },
  func = function(name)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end
    local ok, msg = zonas.limpiar_todas_las_zonas()
    if ok then return true, msg else return false, msg end
  end
})

minetest.register_chatcommand("ver_zonas", {
  description = "Muestra coordenadas de zonas (centros).",
  privs       = { server = true },
  func = function(name)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local txt = (zonas.ver_zonas and zonas.ver_zonas()) or "No disponible."
    send_multiline(name, txt)
    return true, "Listado de zonas enviado."
  end
})

minetest.register_chatcommand("separacion_zonas", {
  params      = "<valor>",
  description = "Cambia separación (gap) entre zonas.",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local n = tonumber(param)
    if not n or n <= 0 then return false, "Uso: /separacion_zonas <valor_positivo>" end
    local ok, msg = zonas.set_separacion(n)
    if ok then return true, msg else return false, msg end
  end
})

minetest.register_chatcommand("tp_zona", {
  params      = "<n>",
  description = "Teletransporta al admin al centro de la zona n.",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local n = tonumber(param)
    if not n then return false, "Uso: /tp_zona <número>" end
    local zonas_tab = zonas.zonas_equipo
    if not zonas_tab or not zonas_tab[n] or not zonas_tab[n].centro then
      if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end
      if not zonas_tab[n] or not zonas_tab[n].centro then return false, "Zona no encontrada." end
    end
    local z = zonas_tab[n]
    local p = minetest.get_player_by_name(name)
    if not p or not p.is_player or not p:is_player() then return false, "Jugador no encontrado." end
    local techo_y = (z.p2 and z.p2.y) or (z.centro.y + zonas.get_tamano().y - 1)
    p:set_pos({ x = z.centro.x, y = techo_y + 1, z = z.centro.z })
    return true, "Teletransportado a zona " .. n
  end
})

minetest.register_chatcommand("tamano_zona", {
  params      = "<base> <altura>",
  description = "Define base (ancho=largo) y altura de las zonas.",
  privs       = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local base, altura = param:match("^(%S+)%s+(%S+)")
    base   = tonumber(base); altura = tonumber(altura)
    if not base or not altura then return false, "Uso: /tamano_zona <base> <altura>" end
    local ok, msg = zonas.set_tamano(base, altura)
    if ok then return true, msg else return false, msg end
  end
})

minetest.register_chatcommand("ver_tamano_zona", {
  description = "Muestra tamaño actual de las zonas.",
  privs       = { server = true },
  func = function(name)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local t = zonas.get_tamano()
    if not t then return false, "Tamaño no definido." end
    return true, string.format("Tamaño actual: base=%d altura=%d", t.x, t.y)
  end
})

-- Comandos robustos para ver y eliminar spawns
local function get_spawns_table()
  if zonas then
    if type(zonas.lista_spawns) == "table" then return zonas.lista_spawns end
    if type(zonas.get_spawns) == "function" then
      local ok, t = pcall(zonas.get_spawns)
      if ok and type(t) == "table" then return t end
    end
  end
  return nil
end

if not minetest.registered_chatcommands["ver_spawn"] then
  minetest.register_chatcommand("ver_spawn", {
    params = "[id]",
    description = "Muestra la posición de un spawn (id opcional, display id empieza en 0).",
    func = function(name, param)
      local spawns = get_spawns_table()
      if not spawns or #spawns == 0 then return false, "No hay spawns definidos." end

      local id = (param or ""):match("%S+")
      local idx
      if id and id ~= "" then
        local n = tonumber(id)
        if n then idx = n + 1 end
        if not idx then
          -- buscar por campo id/name si el elemento es tabla con identificador
          for i, v in ipairs(spawns) do
            if type(v)=="table" and (v.id == id or v.name == id or v.tag == id) then idx = i; break end
          end
        end
      else
        -- usar índice actual si existe en zonas
        if zonas and zonas.spawn_actual_index then idx = zonas.spawn_actual_index
        elseif zonas and type(zonas.get_spawn_index) == "function" then idx = zonas.get_spawn_index()
        else idx = 1 end
      end

      if not idx or not spawns[idx] then return false, "Spawn no encontrado: " .. tostring(id or "(por defecto)") end
      local s = spawns[idx]
      if type(s) == "table" and s.x and s.y and s.z then
        return true, string.format("Spawn '%s' -> %.2f, %.2f, %.2f (definido por %s)", tostring(id or (idx-1)), s.x, s.y, s.z, tostring(s.by or "-"))
      else
        return true, tostring(s)
      end
    end,
  })
end

if not minetest.registered_chatcommands["eliminar_spawn"] then
  minetest.register_chatcommand("eliminar_spawn", {
    params = "<id>",
    description = "Elimina un spawn por id (display id, empieza en 0).",
    privs = { server = true },
    func = function(name, param)
      local id = (param or ""):match("%S+")
      if not id then return false, "Uso: /eliminar_spawn <id>" end

      -- Si zonas provee una función eliminar, la usamos
      if zonas and type(zonas.eliminar_spawn) == "function" then
        local ok, msg = pcall(zonas.eliminar_spawn, id)
        if not ok then return false, "Error eliminando spawn: " .. tostring(msg) end
        return true, tostring(msg or ("Spawn eliminado: "..tostring(id)))
      end

      -- Fallback: intentar eliminar de lista si existe como array
      local spawns = get_spawns_table()
      if not spawns then return false, "Funcionalidad de spawns no disponible." end
      local n = tonumber(id)
      local idx = n and (n + 1)
      if not idx or not spawns[idx] then return false, "Spawn no encontrado: " .. tostring(id) end
      table.remove(spawns, idx)
      -- intentar guardar si zonas expone la función de guardado
      if zonas and type(zonas.guardar_lista_spawns) == "function" then
        pcall(zonas.guardar_lista_spawns)
      elseif zonas and type(zonas.save_spawns) == "function" then
        pcall(zonas.save_spawns)
      end
      -- regenerar posiciones si existe la función
      if zonas and type(zonas.generar_posiciones_zonas) == "function" then
        pcall(zonas.generar_posiciones_zonas)
      end
      return true, "Spawn eliminado: " .. tostring(id)
    end,
  })
end

-- ========= Eventos inventario =========
minetest.register_on_player_inventory_action(function(player)
  minetest.after(0, function()
    if player and type(player)=="userdata" and player.is_player and player:is_player() then enforce_inventory_limits(player) end
  end)
end)

-- reemplazo robusto del handler de pickup para asegurar que enforce_inventory_limits vea el inventario final
if minetest.register_on_item_pickup then
  minetest.register_on_item_pickup(function(player, itemstack)
    -- protegerse contra player nil o no-player
    local pname = nil
    if player == nil then
      pname = "(nil)"
    elseif type(player) == "string" then
      pname = player
    elseif type(player) == "userdata" and player.get_player_name and player.is_player and player:is_player() then
      pname = player:get_player_name()
    else
      pname = "(unknown)"
    end

    minetest.log("action", "[equipos] on_item_pickup fired for " .. tostring(pname))

    -- Intentar ejecutar enforce sobre el objeto player si es válido, sino resolver por nombre
    if type(player) == "userdata" and player.get_player_name and player.is_player and player:is_player() then
      minetest.after(0.12, function()
        if player and player.is_player and player:is_player() then pcall(enforce_inventory_limits, player) end
      end)
      minetest.after(0.30, function()
        if player and player.is_player and player:is_player() then pcall(enforce_inventory_limits, player) end
      end)
    elseif pname and pname ~= "(nil)" and pname ~= "(unknown)" then
      minetest.after(0.12, function()
        local p = minetest.get_player_by_name(pname)
        if p and p.is_player and p:is_player() then pcall(enforce_inventory_limits, p) end
      end)
      minetest.after(0.30, function()
        local p = minetest.get_player_by_name(pname)
        if p and p.is_player and p:is_player() then pcall(enforce_inventory_limits, p) end
      end)
    end
  end)
else
  minetest.log("action", "[equipos] register_on_item_pickup no disponible - usando inventory_action fallback")
end

minetest.register_chatcommand("limite_bloques", {
  params      = "<valor>",
  description = "Cambia el máximo de bloques idénticos por jugador (runtime).",
  privs       = {server = true},
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local nuevo = tonumber(param)
    if not nuevo or nuevo < 1 then return false, "Uso: /limite_bloques <n>" end
    config.max_bloques = nuevo
    minetest.chat_send_all("⚙️ Límite de bloques actualizado a " .. nuevo .. " por " .. name .. ".")
    return true
  end,
})

-- ========= Muerte / Respawn =========
minetest.register_on_dieplayer(function(player)
  if not player or not player.is_player or not player:is_player() then return end
  local name = player:get_player_name()
  -- limpiar inventario
  local inv = player:get_inventory()
  if inv then inv:set_list("main", {}); if inv:get_list("craft") then inv:set_list("craft", {}) end end
  -- perder vida
  minetest.after(0, function() perder_vida(name, "muerte") end)
end)

minetest.register_on_respawnplayer(function(player)
  if not player or not player.is_player or not player:is_player() then return true end
  local name = player:get_player_name()
  if not tp_a_zona_asignada(name) then
    local spawn = (zonas.get_spawn_actual and zonas.get_spawn_actual()) or config.spawn_global_default
    player:set_pos(spawn)
  end
  minetest.after(0.2, function()
    local p = minetest.get_player_by_name(name)
    if p and p.is_player and p:is_player() then enforce_inventory_limits(p) end
  end)
  return true
end)

-- ========= Inversión de daño (agresor recibe su daño) =========
minetest.register_on_player_hpchange(function(player, hp_change, reason)
  if hp_change >= 0 then return hp_change end
  if reason and reason.type == "punch" and reason.object and reason.object.is_player and reason.object:is_player() then
    local hitter = reason.object
    local hname  = hitter:get_player_name()
    -- anula daño a la víctima
    minetest.after(0, function()
      if hitter and hitter.is_player and hitter:is_player() then
        local cur = hitter:get_hp()
        local newhp = math.max(cur + hp_change, 0)
        hitter:set_hp(newhp)
        aplicar_castigo(hname, "agresión")
      end
    end)
    return 0
  end
  return hp_change
end, true)

-- ========= Panel Admin (módulo separado) =========
-- Exportar API mínima para admin.lua y cargarlo (mantiene toda la funcionalidad UI fuera de init.lua)
_G.equipos_api = {
  zonas = zonas,
  config = config,
  es_administrador = es_administrador,
  send_multiline = send_multiline,
  modpath = modpath,
}
local ok, err = pcall(dofile, modpath .. "/admin.lua")
if not ok then
  minetest.log("error", "[equipos] fallo al cargar admin.lua: " .. tostring(err))
end
_G.equipos_api = nil

if not (minetest.chatcommands and minetest.chatcommands.panel_admin) then
  minetest.register_chatcommand("panel_admin", {
    description = "Abre el panel de ayuda para administradores (fallback).",
    privs = { server = true },
    func = function(name)
      minetest.chat_send_player(name, "❌ Panel admin no disponible: admin.lua no cargado o con error. Revisa logs.")
      return false, "Panel admin no disponible."
    end
  })
end

-- ========= AYUDA general =========
minetest.register_chatcommand("ayuda", {
  description = "Muestra todos los comandos del mod 'equipos'.",
  func = function(name)
    local ayuda = [[
📘 COMANDOS DEL MOD "equipos"
🚀 SPAWN
 /definir_spawn [x y z]
 /ver_spawn
 /ver_spawns
 /elegir_spawn <id>
 /eliminar_spawn <id>
🧱 ZONAS
 /crear_zona <n> [mat]
 /crear_zonas [mat]
 /limpiar_zona <n>
 /limpiar_zonas
 /ver_zonas
 /separacion_zonas <valor>
 /tp_zona <n>
 /tamano_zona <base> <altura>
 /ver_tamano_zona
🧑‍🏫 Administración
 /iniciar_partida <1|3|5>
 /reset_partida
⛔ Castigo
 /definir_zona_castigo [x y z] [min]
 /ver_zona_castigo
 /autorizar <jugador>
⏸️ Pausas manuales
 /pausar <nombre> [min]
 /liberar <nombre>
⚙️ Inventario
 /limite_bloques <n>
🧩 Utilidades
 /penalizar <jugador> [puntos]
 /panel_admin
🧩 /ayuda
]]
    minetest.chat_send_player(name, ayuda)
    return true
  end,
})

-- ========= INIT diferido (evita tocar mundo en init) =========
minetest.after(1, function()
  pcall(function() if zonas.crear_plataforma_spawn then zonas.crear_plataforma_spawn() end end)
  pcall(function() if zonas.generar_posiciones_zonas then zonas.generar_posiciones_zonas() end end)
end)

-- ========= REGISTRAR comandos de SPAWN si faltan (genera disponibilidad desde chat) =========
-- Registros de respaldo: si zonas.lua no registró comandos, los exponemos aquí.
if not minetest.chatcommands.definir_spawn then
  minetest.register_chatcommand("definir_spawn", {
    params = "[x y z]",
    description = "Define un spawn (si no hay coords usa tu posición).",
    privs = { server = true },
    func = function(name, param)
      if zonas.definir_spawn then local ok,msg = zonas.definir_spawn(name, param); if ok then return true, msg else return false, msg end end
      return false, "Función definir_spawn no disponible."
    end
  })
end
if not minetest.chatcommands.ver_spawns then
  minetest.register_chatcommand("ver_spawns", {
    description = "Lista spawns definidos.",
    func = function(name) if zonas.ver_spawns then return true, zonas.ver_spawns() end return false, "No disponible." end
  })
end
if not minetest.chatcommands.ver_spawn then
  minetest.register_chatcommand("ver_spawn", {
    params = "<id>",
    func = function(name, param) if zonas.ver_spawn then return true, zonas.ver_spawn(param) end return false, "No disponible." end
  })
end
if not minetest.chatcommands.elegir_spawn then
  minetest.register_chatcommand("elegir_spawn", {
    params = "<id>",
    privs = { server = true },
    func = function(name, param) if zonas.elegir_spawn then local ok,msg = zonas.elegir_spawn(param); if ok then return true, msg else return false, msg end end return false, "No disponible." end
  })
end

-- Pausar / Liberar jugadores (comandos administrativos)
minetest.register_chatcommand("pausar", {
  params = "<nombre> [minutos]",
  description = "Envía temporalmente a la zona de castigo (pausa) al jugador. Duración opcional en minutos.",
  privs = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local target, mins = (param or ""):match("^(%S+)%s*(%S*)$")
    if not target or target == "" then return false, "Uso: /pausar <nombre> [minutos]" end
    local duration = tonumber(mins) and math.max(1, tonumber(mins)) * 60 or zona_castigo_duracion
    if pausados[target] then return false, target .. " ya está pausado." end

    local p = minetest.get_player_by_name(target)
    local pos_original = p and p.get_pos and vector.round(p:get_pos()) or nil
    local destino = zona_castigo_pos or (zonas.get_spawn_actual and zonas.get_spawn_actual()) or config.spawn_global_default
    if p and p.is_player and p:is_player() then
      p:set_pos(destino)
      p:set_physics_override({speed=0, jump=0, gravity=1})
      minetest.set_player_privs(target, { shout = true })
    end

    pausados[target] = { pos_original = pos_original, tiempo = duration, inicio = os.time() }
    minetest.chat_send_all("⛔ "..target.." fue pausado por "..(duration/60).." minuto(s) por "..name..".")

    -- programar liberación automática
    minetest.after(duration, function()
      if not pausados[target] then return end
      local p2 = minetest.get_player_by_name(target)
      if p2 and p2.is_player and p2:is_player() then
        if pausados[target].pos_original then
          p2:set_pos(pausados[target].pos_original)
        end
        p2:set_physics_override({speed=1, jump=1, gravity=1})
        minetest.set_player_privs(target, { interact = true, shout = true })
        minetest.chat_send_all("✅ "..target.." ha cumplido la pausa.")
      end
      pausados[target] = nil
    end)

    return true, "Pausado: "..target.." por "..(duration/60).." min."
  end,
})

minetest.register_chatcommand("liberar", {
  params = "<nombre>",
  description = "Libera manualmente a un jugador pausado (restaura posición y privilegios básicos).",
  privs = { server = true },
  func = function(name, param)
    if not es_administrador(name) then return false, "❌ Solo administradores." end
    local target = (param or ""):match("%S+")
    if not target then return false, "Uso: /liberar <nombre>" end
    if not pausados[target] then return false, target .. " no está pausado." end

    local p = minetest.get_player_by_name(target)
    if p and p.is_player and p:is_player() then
      if pausados[target].pos_original then
        p:set_pos(pausados[target].pos_original)
      end
      p:set_physics_override({speed=1, jump=1, gravity=1})
      minetest.set_player_privs(target, { interact = true, shout = true })
      minetest.chat_send_all("✅ "..target.." ha sido liberado por "..name..".")
    end

    pausados[target] = nil
    return true, "Liberado: "..target
  end,
})
