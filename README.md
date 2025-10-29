# 🎓 CodeCraft Academy
### *Entorno Educativo de Programación Colaborativa*

**Desarrollado por**: profeDaniel & GitHub Copilot  
**Versión**: 2.0  
**Basado en**: LudusTechnical (Void + Minetest Game)

CodeCraft Academy transforma la enseñanza de programación combinando un entorno 3D inmersivo con herramientas de programación integradas (Python, Lua, Java, Arduino) y colaboración en tiempo real.

Objetivo
LudusTechical está diseñado como un entorno de evaluación escolar. Permite crear equipos aleatorios de estudiantes que comparten un mismo skin y deben resolver desafíos dentro de zonas restringidas.

Contenido
Archivos del juego

game.conf – Define el nombre legible del juego según la API de Luanti.

README.md – Este documento.

mods/default – Mod esencial de Minetest para registrar nodos básicos (tierra, piedra, agua, etc.).

mods/worldedit – Herramienta administrativa para definir áreas, copiar estructuras, etc.

mods/equipos – Mod propio que gestiona la lógica de equipos, skins, zonas y poderes administrativos.

Mod "equipos" (Ludus Core)
Este mod incluye:

Registro de equipos aleatorios (3 o 5 integrantes).

Asignación de skins compartidos por equipo.

Definición de zonas de trabajo restringidas (15 zonas en grilla 3x5).

Registro de administradores con capacidades extendidas (teletransportación, edición de nodos, control de jugadores).

Límite de Inventario: Los estudiantes solo pueden tener una cantidad limitada de bloques iguales en su inventario, forzando la gestión de recursos y el descarte de excesos.

Uso y Flujo Recomendado para Docentes
Configurar Administradores: Editar el archivo mods/equipos/config.lua y agregar los nombres de usuario de los docentes en la tabla config.administradores.

Iniciar el Entorno: Usar el comando de chat /crear_zonas para construir las 15 plataformas de trabajo.

Iniciar la Clase: Cuando los estudiantes estén conectados, usar /iniciar_partida 3 o /iniciar_partida 5.

Para ver todos los comandos, usa /ayuda dentro del juego.