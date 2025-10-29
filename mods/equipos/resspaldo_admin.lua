-- admin.lua - Panel admin con diseño oscuro integrado y layout corregido
local api = _G.equipos_api or error("admin.lua requiere _G.equipos_api")
local zonas = api.zonas
local config = api.config
local es_administrador = api.es_administrador or function() return true end
local registro = api.registro
local modpath = api.modpath

local admin_tab_idx = {}
local admin_last_msg = {}

local function admin_help_text()
  return [[📘 Guía Administrador - Ludus Technical (mod 'equipos')

✅ Funciones principales:
 - Crear zonas por equipos y definir spawn.
 - Iniciar, reiniciar y controlar partidas.
 - Administrar usuarios y aplicar penalizaciones.
 - Consultar registros y exportar logs.

💡 Usa el campo superior en cada pestaña para ingresar datos y luego presioná el botón correspondiente.]]
end

-- Layout general (tema oscuro)
local FS_W, FS_H = 14, 13
local MARGIN_X = 0.6
local TAB_Y = 0.9
local FIELD_H = 0.9
local BTN_W, BTN_H = 3.5, 0.95
local GAP_X, GAP_Y = 0.6, 0.55
local BUTTON_START_Y = 4.5
local LAST_MSG_Y = 9.8
local LAST_MSG_H = 2.5

-- Helpers
local function col_x(c) return MARGIN_X + c * (BTN_W + GAP_X) end
local function row_y(r) return BUTTON_START_Y + r * (BTN_H + GAP_Y) end

-- Campo gris integrado al tema oscuro
local function field_dark(x, y, w, name, placeholder)
  return ("bgcolor[#CCCCCC;false]field[%.2f,%.2f;%.2f,%.2f;%s;%s]")
    :format(x, y, w, FIELD_H, name, minetest.formspec_escape(placeholder or ""))
end

local function button_at(x, y, name, text)
  return ("button[%.2f,%.2f;%.2f,%.2f;%s;%s]")
    :format(x, y, BTN_W, BTN_H, name, minetest.formspec_escape(text))
end

local function button_exit_at(x, y, name, text)
  return ("button_exit[%.2f,%.2f;2.5,0.9;%s;%s]")
    :format(x, y, name, minetest.formspec_escape(text))
end

-- ---------------- SPAWN ----------------
local function build_formspec_spawn()
  local parts = {}
  table.insert(parts, ("label[%.2f,%.2f;SPAWN]"):format(MARGIN_X, TAB_Y + 0.1))
  local total_w = FS_W - 2 * MARGIN_X
  table.insert(parts, field_dark(MARGIN_X, 1.6, total_w * 0.65, "fld_spawn_id", "ID de spawn (opcional)"))
  table.insert(parts, button_at(col_x(0), row_y(0), "btn_definir_spawn_aqui", "Definir (aquí)"))
  table.insert(parts, button_at(col_x(1), row_y(0), "btn_ver_spawn", "Ver spawn"))
  table.insert(parts, button_at(col_x(2), row_y(0), "btn_ver_spawns", "Ver todos"))
  table.insert(parts, button_at(col_x(0), row_y(1), "btn_elegir_spawn", "Elegir spawn"))
  table.insert(parts, button_at(col_x(1), row_y(1), "btn_plataforma_spawn", "Crear plataforma"))
  return table.concat(parts, "")
end

-- ---------------- ZONAS ----------------
local function build_formspec_zonas()
  local p = {}
  table.insert(p, string.format("label[%.3f,%.3f;ZONAS]", MARGIN_X, TAB_Y + 0.05))

  -- Layout en dos columnas: inputs a la izquierda, botones a la derecha
  local left_x = MARGIN_X
  local right_x = col_x(1)
  local left_w = right_x - MARGIN_X - 0.2
  local cur_y = TAB_Y + 1.2
  local vgap = 0.22

  -- Inputs (columna izquierda) - sin placeholder visible
  table.insert(p, string.format("label[%.3f,%.3f;Material (opcional)]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_mat;]", left_x, cur_y, left_w, FIELD_H))
  cur_y = cur_y + FIELD_H + vgap

  table.insert(p, string.format("label[%.3f,%.3f;N (zona)]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_zona_n;]", left_x, cur_y, left_w, FIELD_H))
  cur_y = cur_y + FIELD_H + vgap

  table.insert(p, string.format("label[%.3f,%.3f;Base]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_base;]", left_x, cur_y, left_w, FIELD_H))
  cur_y = cur_y + FIELD_H + vgap

  table.insert(p, string.format("label[%.3f,%.3f;Altura]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_altura;]", left_x, cur_y, left_w, FIELD_H))
  cur_y = cur_y + FIELD_H + vgap

  table.insert(p, string.format("label[%.3f,%.3f;Separación]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_sep;]", left_x, cur_y, left_w, FIELD_H))

  -- Botones (columna derecha) - organizados en filas verticales
  local by = TAB_Y + 1.2
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_crear_zonas;Crear TODAS las zonas]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_limpiar_todas_zonas;Limpiar TODAS las zonas]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_ver_zonas;Ver zonas]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y * 1.2
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_crear_zona;Crear zona N]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_limpiar_zona;Limpiar zona N]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_tp_zona;TP]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_tamano;Aplicar tamaño]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_separacion;Aplicar separación]", right_x, by, BTN_W, BTN_H))

  return table.concat(p, "")
end

-- ---------------- PARTIDA ----------------
local function build_formspec_partida()
  local parts = {}
  table.insert(parts, ("label[%.2f,%.2f;PARTIDA]"):format(MARGIN_X, TAB_Y + 0.1))
  local total_w = FS_W - 2 * MARGIN_X
  table.insert(parts, field_dark(MARGIN_X, 1.6, total_w, "fld_partida_opts", "Parámetros (opcional)"))
  table.insert(parts, button_at(col_x(0), row_y(0), "btn_iniciar_1", "Iniciar 1"))
  table.insert(parts, button_at(col_x(1), row_y(0), "btn_iniciar_3", "Iniciar 3"))
  table.insert(parts, button_at(col_x(2), row_y(0), "btn_iniciar_5", "Iniciar 5"))
  table.insert(parts, button_at(col_x(1), row_y(1), "btn_reset_partida", "Reset partida"))
  return table.concat(parts, "")
end

-- ---------------- CASTIGO ----------------
local function build_formspec_castigo()
  local parts = {}
  table.insert(parts, ("label[%.2f,%.2f;CASTIGO]"):format(MARGIN_X, TAB_Y + 0.1))
  local total_w = FS_W - 2 * MARGIN_X
  table.insert(parts, field_dark(MARGIN_X, 1.6, total_w * 0.45, "fld_min_castigo", "Minutos (por defecto 2)"))
  table.insert(parts, button_at(col_x(0), row_y(0), "btn_def_zona_castigo", "Definir zona (aquí)"))
  table.insert(parts, button_at(col_x(1), row_y(0), "btn_ver_zona_castigo", "Ver zona castigo"))
  return table.concat(parts, "")
end

local function build_formspec_usuarios()
  local p = {}
  table.insert(p, string.format("label[%.3f,%.3f;USUARIOS / DISCIPLINA]", MARGIN_X, TAB_Y + 0.05))

  -- Dos columnas: inputs izquierda, botones derecha
  local left_x = MARGIN_X
  local right_x = col_x(1)
  local left_w = right_x - MARGIN_X - 0.2
  local cur_y = TAB_Y + 1.2
  local vgap = 0.22

  -- Inputs (izquierda)
  table.insert(p, string.format("label[%.3f,%.3f;Jugador (nombre)]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_jugador;]", left_x, cur_y, left_w, FIELD_H))
  cur_y = cur_y + FIELD_H + vgap

  table.insert(p, string.format("label[%.3f,%.3f;Minutos]", left_x, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_min;]", left_x, cur_y, left_w * 0.45, FIELD_H))
  table.insert(p, string.format("label[%.3f,%.3f;Pts]", left_x + left_w * 0.5, cur_y - 0.32))
  table.insert(p, string.format("field[%.3f,%.3f;%.3f,%.3f;fld_pen_pts;]", left_x + left_w * 0.5, cur_y, left_w * 0.45, FIELD_H))

  -- Botones (derecha), distribuidos verticalmente
  local by = TAB_Y + 1.2
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_pausar;Pausar]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_liberar;Liberar]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_penalizar;Penalizar]", right_x, by, BTN_W, BTN_H))
  by = by + BTN_H + GAP_Y
  table.insert(p, string.format("button[%.3f,%.3f;%.3f,%.3f;btn_autorizar;Autorizar]", right_x, by, BTN_W, BTN_H))

  return table.concat(p, "")
end

-- ---------------- INVENTARIO ----------------
local function build_formspec_inventario()
  local parts = {}
  table.insert(parts, ("label[%.2f,%.2f;INVENTARIO]"):format(MARGIN_X, TAB_Y + 0.1))
  local total_w = FS_W - 2 * MARGIN_X
  table.insert(parts, field_dark(MARGIN_X, 1.6, total_w * 0.5, "fld_limite", "Límite de bloques"))
  table.insert(parts, button_at(col_x(0), row_y(0), "btn_limite_bloques", "Aplicar límite"))
  return table.concat(parts, "")
end

-- ---------------- REGISTRO ----------------
local function build_formspec_registro()
  local parts = {}
  table.insert(parts, ("label[%.2f,%.2f;REGISTRO]"):format(MARGIN_X, TAB_Y + 0.1))
  local total_w = FS_W - 2 * MARGIN_X
  table.insert(parts, field_dark(MARGIN_X, 1.6, total_w * 0.45, "fld_reg_count", "Ver últimos N (200)"))
  table.insert(parts, field_dark(MARGIN_X + total_w * 0.5, 1.6, total_w * 0.45, "fld_reg_fname", "Nombre de archivo"))
  table.insert(parts, button_at(col_x(0), row_y(0), "btn_ver_registro", "Ver registro"))
  table.insert(parts, button_at(col_x(1), row_y(0), "btn_export_registro", "Exportar"))
  table.insert(parts, button_at(col_x(2), row_y(0), "btn_clear_registro", "Limpiar"))
  return table.concat(parts, "")
end

-- ---------------- AYUDA ----------------
local function build_formspec_ayuda()
  local text = admin_help_text()
  return ("textarea[%.2f,1.1;%.2f,%.2f;help;;%s]")
    :format(MARGIN_X, FS_W - 2 * MARGIN_X, FS_H - 2.6, minetest.formspec_escape(text))
end

-- Mostrar panel
local function show_admin_formspec(name, tabidx)
  if not es_administrador(name) then
    minetest.chat_send_player(name, "Solo administradores."); return
  end
  admin_tab_idx[name] = tabidx or admin_tab_idx[name] or 1
  local tabs = {"Spawn","Zonas","Partida","Castigo","Usuarios","Inventario","Registro","Ayuda"}
  local fs = {
    ("formspec_version[4]size[%d,%d]bgcolor[#2E2E2E;true]"):format(FS_W, FS_H),
    ("label[%.2f,0.5;Panel Admin - Mod 'equipos']"):format(MARGIN_X),
    ("tabheader[%.2f,0.9;admin_tabs;%s;%d;true;true]"):format(MARGIN_X, table.concat(tabs, ","), admin_tab_idx[name])
  }
  local idx = admin_tab_idx[name]
  if     idx == 1 then table.insert(fs, build_formspec_spawn())
  elseif idx == 2 then table.insert(fs, build_formspec_zonas())
  elseif idx == 3 then table.insert(fs, build_formspec_partida())
  elseif idx == 4 then table.insert(fs, build_formspec_castigo())
  elseif idx == 5 then table.insert(fs, build_formspec_usuarios())
  elseif idx == 6 then table.insert(fs, build_formspec_inventario())
  elseif idx == 7 then table.insert(fs, build_formspec_registro())
  else                  table.insert(fs, build_formspec_ayuda())
  end

  if idx ~= #tabs then
    local last = admin_last_msg[name] or ""
    table.insert(fs, ("textarea[%.2f,%.2f;%.2f,%.2f;last_msg;;%s]")
      :format(MARGIN_X, LAST_MSG_Y, FS_W - 2 * MARGIN_X, LAST_MSG_H, minetest.formspec_escape(last)))
  end
  table.insert(fs, button_exit_at(FS_W - 3.2, FS_H - 1.0, "btn_cerrar", "Cerrar"))
  minetest.show_formspec(name, "equipos:admin_help", table.concat(fs, ""))
end

-- ---------------- Registro de eventos (sin cambios funcionales) ----------------
local function log_action(tipo, quien, datos)
  if registro and registro.log_event then registro.log_event(tipo, quien, datos) end
end

-- Manejo de eventos (mantenemos toda la lógica previa, sin cambios en nombres/acciones)
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "equipos:admin_help" then return end
  if not player or not player.is_player or not player:is_player() then return end
  local name = player:get_player_name()
  if not es_administrador(name) then return end

  if fields.admin_tabs then
    local val = tonumber(fields.admin_tabs)
    if val then admin_tab_idx[name] = val end
    show_admin_formspec(name, admin_tab_idx[name]); return
  end

  -- SPAWN
  if fields.btn_definir_spawn_aqui then
    if minetest.chatcommands and minetest.chatcommands.definir_spawn then
      local ok, msg = minetest.chatcommands.definir_spawn.func(name, "")
      admin_last_msg[name] = msg or (ok and "Spawn definido." or "Error")
      if ok then log_action("definir_spawn", name, { msg = msg }) end
    else admin_last_msg[name] = "Comando /definir_spawn no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_ver_spawn then
    if minetest.chatcommands and minetest.chatcommands.ver_spawn then
      local ok, msg = minetest.chatcommands.ver_spawn.func(name, fields.fld_spawn_id or "")
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
    else admin_last_msg[name] = "Comando /ver_spawn no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_ver_spawns then
    if minetest.chatcommands and minetest.chatcommands.ver_spawns then
      local ok, msg = minetest.chatcommands.ver_spawns.func(name)
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
    else admin_last_msg[name] = "Comando /ver_spawns no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_elegir_spawn then
    local id = (fields.fld_spawn_id or ""):match("%S+") or ""
    if id == "" then admin_last_msg[name] = "Ingresá un ID."
    else
      if minetest.chatcommands and minetest.chatcommands.elegir_spawn then
        local ok, msg = minetest.chatcommands.elegir_spawn.func(name, id)
        admin_last_msg[name] = msg or (ok and "Spawn elegido." or "Error")
        if ok then log_action("elegir_spawn", name, { id = id }) end
      else admin_last_msg[name] = "Comando /elegir_spawn no disponible." end
    end
    show_admin_formspec(name); return
  end
  if fields.btn_plataforma_spawn then
    if zonas and zonas.crear_plataforma_spawn then
      local ok, msg = zonas.crear_plataforma_spawn()
      admin_last_msg[name] = msg or (ok and "Plataforma creada." or "Error")
      if ok then log_action("plataforma_spawn", name, {}) end
    else admin_last_msg[name] = "Función crear_plataforma_spawn no disponible." end
    show_admin_formspec(name); return
  end

  -- ZONAS
  if fields.btn_crear_zonas then
    local mat = (fields.fld_mat or ""); if mat == "" then mat = nil end
    if minetest.chatcommands and minetest.chatcommands.crear_zonas then
      local ok, msg = minetest.chatcommands.crear_zonas.func(name, mat or "")
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
      if ok then log_action("crear_todas_zonas", name, { mat = mat }) end
    else admin_last_msg[name] = "Comando /crear_zonas no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_limpiar_todas_zonas then
    if minetest.chatcommands and minetest.chatcommands.limpiar_zonas then
      local ok, msg = minetest.chatcommands.limpiar_zonas.func(name)
      admin_last_msg[name] = msg or (ok and "Todas las zonas limpiadas." or "Error")
      if ok then log_action("limpiar_todas_zonas", name, {}) end
    else admin_last_msg[name] = "Comando /limpiar_zonas no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_crear_zona or fields.btn_limpiar_zona or fields.btn_tp_zona then
    local n = tonumber((fields.fld_zona_n or ""):match("%S+"))
    if not n then admin_last_msg[name] = "Ingresá N válido."; show_admin_formspec(name); return end
    if fields.btn_crear_zona then
      local mat = (fields.fld_mat or ""); if mat == "" then mat = nil end
      if minetest.chatcommands and minetest.chatcommands.crear_zona then
        local ok,msg = minetest.chatcommands.crear_zona.func(name, tostring(n).." "..(mat or ""))
        admin_last_msg[name] = msg or (ok and "OK" or "Error")
        if ok then log_action("crear_zona", name, { n = n, mat = mat }) end
      else admin_last_msg[name] = "Comando /crear_zona no disponible." end
    elseif fields.btn_limpiar_zona then
      if minetest.chatcommands and minetest.chatcommands.limpiar_zona then
        local ok,msg = minetest.chatcommands.limpiar_zona.func(name, tostring(n))
        admin_last_msg[name] = msg or (ok and "OK" or "Error")
        if ok then log_action("limpiar_zona", name, { n = n }) end
      else admin_last_msg[name] = "Comando /limpiar_zona no disponible." end
    else
      if minetest.chatcommands and minetest.chatcommands.tp_zona then
        local ok,msg = minetest.chatcommands.tp_zona.func(name, tostring(n))
        admin_last_msg[name] = msg or (ok and "OK" or "Error")
      else admin_last_msg[name] = "Comando /tp_zona no disponible." end
    end
    show_admin_formspec(name); return
  end
  if fields.btn_tamano then
    local b = tonumber((fields.fld_base or ""):match("%S+"))
    local a = tonumber((fields.fld_altura or ""):match("%S+"))
    if not b or not a then admin_last_msg[name] = "Ingresá base y altura válidas." else
      if minetest.chatcommands and minetest.chatcommands.tamano_zona then
        local ok,msg = minetest.chatcommands.tamano_zona.func(name, tostring(b).." "..tostring(a))
        admin_last_msg[name] = msg or (ok and "OK" or "Error")
        if ok then log_action("tamano_zona", name, { base = b, altura = a }) end
      else admin_last_msg[name] = "Comando /tamano_zona no disponible." end
    end
    show_admin_formspec(name); return
  end
  if fields.btn_separacion then
    local s = tonumber((fields.fld_sep or ""):match("%S+"))
    if not s then admin_last_msg[name] = "Ingresá separación válida." else
      if minetest.chatcommands and minetest.chatcommands.separacion_zonas then
        local ok,msg = minetest.chatcommands.separacion_zonas.func(name, tostring(s))
        admin_last_msg[name] = msg or (ok and "OK" or "Error")
        if ok then log_action("separacion_zonas", name, { separacion = s }) end
      else admin_last_msg[name] = "Comando /separacion_zonas no disponible." end
    end
    show_admin_formspec(name); return
  end
  if fields.btn_ver_zonas then
    if minetest.chatcommands and minetest.chatcommands.ver_zonas then
      minetest.chatcommands.ver_zonas.func(name)
      admin_last_msg[name] = "Listado de zonas enviado (chat)."
    else admin_last_msg[name] = "Comando /ver_zonas no disponible." end
    show_admin_formspec(name); return
  end

  -- PARTIDA
  if fields.btn_iniciar_1 then if minetest.chatcommands and minetest.chatcommands.iniciar_partida then minetest.chatcommands.iniciar_partida.func(name, "1"); log_action("iniciar_partida", name, { mins = 1 }) end; admin_last_msg[name] = "Comando ejecutado."; show_admin_formspec(name); return end
  if fields.btn_iniciar_3 then if minetest.chatcommands and minetest.chatcommands.iniciar_partida then minetest.chatcommands.iniciar_partida.func(name, "3"); log_action("iniciar_partida", name, { mins = 3 }) end; admin_last_msg[name] = "Comando ejecutado."; show_admin_formspec(name); return end
  if fields.btn_iniciar_5 then if minetest.chatcommands and minetest.chatcommands.iniciar_partida then minetest.chatcommands.iniciar_partida.func(name, "5"); log_action("iniciar_partida", name, { mins = 5 }) end; admin_last_msg[name] = "Comando ejecutado."; show_admin_formspec(name); return end
  if fields.btn_reset_partida then if minetest.chatcommands and minetest.chatcommands.reset_partida then minetest.chatcommands.reset_partida.func(name); log_action("reset_partida", name, {}) end; admin_last_msg[name] = "Partida reseteada."; show_admin_formspec(name); return end

  -- CASTIGO
  if fields.btn_def_zona_castigo then
    local mins = tonumber((fields.fld_min_castigo or ""):match("%S+")) or 2
    if minetest.chatcommands and minetest.chatcommands.definir_zona_castigo then
      local ok,msg = minetest.chatcommands.definir_zona_castigo.func(name, tostring(mins))
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
      if ok then log_action("definir_zona_castigo", name, { mins = mins }) end
    else admin_last_msg[name] = "Comando /definir_zona_castigo no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_ver_zona_castigo then
    if minetest.chatcommands and minetest.chatcommands.ver_zona_castigo then
      local ok,msg = minetest.chatcommands.ver_zona_castigo.func(name)
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
    else admin_last_msg[name] = "Comando /ver_zona_castigo no disponible." end
    show_admin_formspec(name); return
  end

  -- USUARIOS / DISCIPLINA
  if fields.btn_pausar then
    local jugador = (fields.fld_jugador or ""):match("%S+")
    local mins = tonumber((fields.fld_min or ""):match("%S+")) or 2
    if not jugador then admin_last_msg[name] = "Ingresá el jugador."; show_admin_formspec(name); return end
    if minetest.chatcommands and minetest.chatcommands.pausar then
      local ok,msg = minetest.chatcommands.pausar.func(name, jugador.." "..tostring(mins))
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
      if ok then log_action("pausar", name, { jugador = jugador, mins = mins }) end
    else admin_last_msg[name] = "Comando /pausar no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_liberar then
    local jugador = (fields.fld_jugador or ""):match("%S+")
    if not jugador then admin_last_msg[name] = "Ingresá el jugador."; show_admin_formspec(name); return end
    if minetest.chatcommands and minetest.chatcommands.liberar then
      local ok,msg = minetest.chatcommands.liberar.func(name, jugador)
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
      if ok then log_action("liberar", name, { jugador = jugador }) end
    else admin_last_msg[name] = "Comando /liberar no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_penalizar then
    local jugador = (fields.fld_jugador or ""):match("%S+")
    local pts = tonumber((fields.fld_pen_pts or ""):match("%S+")) or 1
    if not jugador then admin_last_msg[name] = "Ingresá el jugador."; show_admin_formspec(name); return end
    if minetest.chatcommands and minetest.chatcommands.penalizar then
      local ok,msg = minetest.chatcommands.penalizar.func(name, jugador.." "..tostring(pts))
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
      if ok then log_action("penalizar", name, { jugador = jugador, pts = pts }) end
    else admin_last_msg[name] = "Comando /penalizar no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_autorizar then
    local jugador = (fields.fld_jugador or ""):match("%S+")
    if not jugador then admin_last_msg[name] = "Ingresá el jugador."; show_admin_formspec(name); return end
    if minetest.chatcommands and minetest.chatcommands.autorizar then
      local ok,msg = minetest.chatcommands.autorizar.func(name, jugador)
      admin_last_msg[name] = msg or (ok and "OK" or "Error")
      if ok then log_action("autorizar", name, { jugador = jugador }) end
    else admin_last_msg[name] = "Comando /autorizar no disponible." end
    show_admin_formspec(name); return
  end

  -- INVENTARIO
  if fields.btn_limite_bloques then
    local val = tonumber((fields.fld_limite or ""):match("%S+"))
    if not val then admin_last_msg[name] = "Ingresá un número."; show_admin_formspec(name); return end
    if minetest.chatcommands and minetest.chatcommands.limite_bloques then
      local ok,msg = minetest.chatcommands.limite_bloques.func(name, tostring(val))
      admin_last_msg[name] = msg or (ok and "Límite actualizado." or "Error")
      if ok then log_action("limite_bloques", name, { limite = val }) end
    else admin_last_msg[name] = "Comando /limite_bloques no disponible." end
    show_admin_formspec(name); return
  end

  -- REGISTRO
  if fields.btn_ver_registro then
    if registro and registro.get_logs then
      local n = tonumber((fields.fld_reg_count or ""):match("%S+")) or 200
      admin_last_msg[name] = registro.get_logs( math.max(1, 1), n ) or ("Mostrando últimos " .. tostring(n))
    else
      admin_last_msg[name] = "Registro no disponible."
    end
    show_admin_formspec(name); return
  end
  if fields.btn_export_registro then
    if registro and registro.export then
      local fname = (fields.fld_reg_fname or ""):match("%S+") or nil
      local ok, path_or_err = registro.export(fname)
      if ok then admin_last_msg[name] = "Exportado: " .. path_or_err; log_action("export_registro", name, { path = path_or_err })
      else admin_last_msg[name] = "Error exportando: " .. tostring(path_or_err) end
    else admin_last_msg[name] = "Registro no disponible." end
    show_admin_formspec(name); return
  end
  if fields.btn_clear_registro then
    if registro and registro.clear then
      registro.clear()
      admin_last_msg[name] = "Registro limpiado."
      log_action("clear_registro", name, {})
    else admin_last_msg[name] = "Registro no disponible." end
    show_admin_formspec(name); return
  end
end)

-- Ítem y comando para abrir panel (sin cambios)
minetest.register_craftitem("equipos:manual_admin", {
  description = "Manual Admin - Ludus Technical",
  inventory_image = "default_book.png",
  stack_max = 1,
  on_use = function(itemstack, user, pointed_thing)
    if not user or not user.is_player or not user:is_player() then return itemstack end
    local name = user:get_player_name()
    show_admin_formspec(name, 1)
    return itemstack
  end,
})

minetest.register_chatcommand("panel_admin", {
  description = "Abre el panel de ayuda para administradores.",
  privs = {server = true},
  func = function(name) show_admin_formspec(name); return true end
})

minetest.register_chatcommand("ayuda_admin_equipos", {
  description = "Muestra ayuda del mod 'equipos' (panel admin).",
  func = function(name)
    minetest.chat_send_player(name, admin_help_text())
    return true
  end,
})
-- admin.lua termina aquí
