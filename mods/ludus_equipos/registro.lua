-- Registro de eventos de partida: penalizaciones, puntos, vidas, acciones admin
local modname = "ludus_equipos"
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()
local registro_path = worldpath .. "/equipos_registro.mt"

local Registro = {
  logs = {},          -- lista de entradas { ts=os.time(), tipo="penalizar", quien="player", datos = {...} }
  max_entries = 20000
}

local function guardar()
  local f, err = io.open(registro_path, "w")
  if not f then return false, err end
  f:write(minetest.serialize(Registro.logs))
  f:close()
  return true
end

local function cargar()
  local f = io.open(registro_path, "r")
  if not f then return end
  local content = f:read("*all")
  f:close()
  local ok, t = pcall(minetest.deserialize, content)
  if ok and type(t) == "table" then Registro.logs = t end
end

-- Añadir evento (persistente)
function Registro.log_event(tipo, quien, datos)
  local e = {
    ts = os.time(),
    tipo = tostring(tipo or "evento"),
    quien = tostring(quien or "-"),
    datos = datos or {}
  }
  table.insert(Registro.logs, e)
  -- mantener tamaño razonable
  if #Registro.logs > Registro.max_entries then
    local excess = #Registro.logs - Registro.max_entries
    for i=1,excess do table.remove(Registro.logs, 1) end
  end
  guardar()
end

function Registro.get_logs(start_idx, count)
  start_idx = tonumber(start_idx) or 1
  count = tonumber(count) or 200
  local out = {}
  for i = start_idx, math.min(#Registro.logs, start_idx + count - 1) do
    local e = Registro.logs[i]
    table.insert(out, string.format("%d) [%s] %s: %s", i, os.date("%Y-%m-%d %H:%M:%S", e.ts), e.tipo, minetest.formspec_escape(minetest.serialize(e.datos))))
  end
  return table.concat(out, "\n")
end

function Registro.count() return #Registro.logs end

function Registro.clear()
  Registro.logs = {}
  guardar()
end

function Registro.export(filename)
  filename = filename or ("equipos_registro_" .. os.date("%Y%m%d_%H%M%S") .. ".txt")
  local path = worldpath .. "/" .. filename
  local f, err = io.open(path, "w")
  if not f then return false, err end
  for i, e in ipairs(Registro.logs) do
    f:write(string.format("%d\t[%s]\t%s\t%s\n", i, os.date("%Y-%m-%d %H:%M:%S", e.ts), e.tipo, minetest.serialize(e.datos)))
  end
  f:close()
  return true, path
end

-- init
cargar()

-- Exponer en API global (si existe) y como chatcommands útiles
_G.ludus_equipos_api = _G.ludus_equipos_api or {}
_G.ludus_equipos_api.registro = Registro

if minetest.register_chatcommand then
  minetest.register_chatcommand("ver_registro", {
    params = "[start [count]]",
    description = "Muestra registros de partida (start=1,count=200).",
    func = function(name, param)
      local start, count = param:match("^(%d+)%s*(%d*)")
      if start then
        count = tonumber(count) or 200
        return true, Registro.get_logs(tonumber(start), count)
      else
        return true, Registro.get_logs(1, 200)
      end
    end
  })
  minetest.register_chatcommand("export_registro", {
    params = "[filename]",
    privs = {server = true},
    description = "Exporta el registro a un archivo en el worldpath.",
    func = function(name, param)
      local ok, path_or_err = Registro.export((param ~= "" and param) or nil)
      if ok then return true, "Registro exportado a: " .. path_or_err
      else return false, "Error exportando registro: " .. tostring(path_or_err) end
    end
  })
  minetest.register_chatcommand("clear_registro", {
    privs = {server = true},
    description = "Limpia el registro de partidas.",
    func = function(name)
      Registro.clear()
      return true, "Registro limpiado."
    end
  })
end

return Registro