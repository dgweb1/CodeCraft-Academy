# Guía de Configuración para GitHub

## 🚀 Configuración Inicial del Repositorio

Esta guía te ayudará a configurar el repositorio de CodeCraft Academy para trabajar desde múltiples equipos.

### 1. Crear Repositorio en GitHub

1. Ve a [GitHub.com](https://github.com)
2. Inicia sesión en tu cuenta
3. Haz clic en el botón "+" y selecciona "New repository"
4. Configuración recomendada:
   - **Repository name**: `CodeCraft-Academy`
   - **Description**: `Plataforma educativa de programación colaborativa en 3D`
   - **Visibility**: Public (o Private si prefieres)
   - **NO marcar** "Add a README file" (ya tenemos uno)
   - **NO marcar** "Add .gitignore" (ya tenemos uno)
   - **License**: MIT (opcional)

### 2. Inicializar Git en tu Proyecto

Abre PowerShell en el directorio del proyecto y ejecuta:

```powershell
# Navegar al directorio del proyecto
cd "e:\Escritorio\Juego2025\luanti-5.14.0-win64\games\LudusTechnical"

# Inicializar repositorio Git
git init

# Configurar tu información (sustituye con tus datos)
git config user.name "Tu Nombre"
git config user.email "tu.email@ejemplo.com"

# Agregar todos los archivos
git add .

# Primer commit
git commit -m "🎉 Configuración inicial de CodeCraft Academy"

# Conectar con GitHub (sustituye TU_USUARIO con tu nombre de usuario)
git remote add origin https://github.com/TU_USUARIO/CodeCraft-Academy.git

# Subir al repositorio
git push -u origin main
```

### 3. Configuración para Trabajo Multi-Equipo

#### En tu PC Principal (ya configurado):
```powershell
# Verificar estado
git status

# Sincronizar antes de trabajar
git pull origin main

# Después de hacer cambios
git add .
git commit -m "Descripción de tus cambios"
git push origin main
```

#### En tu Notebook:
```powershell
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/CodeCraft-Academy.git

# Entrar al directorio
cd CodeCraft-Academy

# Mover a la ubicación correcta de Luanti
# (Ajusta la ruta según tu instalación de Luanti)
```

### 4. Flujo de Trabajo Recomendado

#### Antes de Trabajar (en cualquier equipo):
```powershell
git pull origin main
```

#### Después de Trabajar:
```powershell
git add .
git commit -m "Descripción clara de los cambios realizados"
git push origin main
```

#### Ejemplos de Mensajes de Commit:
- `✨ Agregar nuevo componente LED al simulador Arduino`
- `🐛 Corregir error en la asignación de equipos`
- `📚 Actualizar guía pedagógica con nuevas actividades`
- `🎨 Mejorar interfaz del editor de código`
- `⚙️ Configurar nuevos comandos de administración`

### 5. Archivos Importantes para GitHub

#### `.gitignore` (ya creado)
Excluye archivos que no deben subirse:
- Archivos de mundo (`world.mt`, `map_meta.txt`)
- Configuración local
- Archivos temporales
- Logs del sistema

#### `README_GITHUB.md` (ya creado)
- Descripción completa del proyecto
- Instrucciones de instalación
- Guía de uso
- Información para contribuidores

### 6. Consideraciones Especiales

#### ⚠️ NO Subir Mundos
Los archivos de mundo están excluidos en `.gitignore` porque:
- Son específicos de cada instalación
- Pueden ser muy grandes
- Contienen datos temporales

#### 🔄 Sincronización de Mods
Los mods SÍ se sincronizan:
- `mods/code_blocks/`
- `mods/arduino_sim/`
- `mods/equipos/`
- Todos los demás mods del proyecto

#### 📋 Backup de Mundos
Para respaldar mundos importantes:
```powershell
# Crear backup manual
cp -r "ruta/al/mundo" "backup/mundo_$(Get-Date -Format 'yyyy-MM-dd')"
```

### 7. Comandos Git Útiles

```powershell
# Ver estado actual
git status

# Ver historial de commits
git log --oneline

# Ver diferencias
git diff

# Deshacer cambios no guardados
git checkout -- archivo.lua

# Ver archivos ignorados
git status --ignored

# Limpiar archivos no rastreados
git clean -fd
```

### 8. Resolución de Conflictos

Si trabajas desde ambos equipos simultáneamente, pueden ocurrir conflictos:

```powershell
# Si hay conflicto al hacer push
git pull origin main
# Resolver conflictos manualmente en los archivos
git add .
git commit -m "Resolver conflictos de merge"
git push origin main
```

### 9. Configuración de Branches (Opcional)

Para desarrollo más avanzado:
```powershell
# Crear rama para nueva feature
git checkout -b feature/simulador-raspberry

# Trabajar en la rama
git add .
git commit -m "Desarrollar simulador Raspberry Pi"

# Cambiar a main y hacer merge
git checkout main
git merge feature/simulador-raspberry

# Subir cambios
git push origin main
```

### 10. Verificación Final

Después de la configuración inicial, verifica:

```powershell
# Verificar conexión con GitHub
git remote -v

# Verificar configuración
git config --list

# Verificar archivos rastreados
git ls-files
```

## 🎯 Resultado Final

Una vez configurado, podrás:
- ✅ Trabajar desde tu PC y notebook indistintamente
- ✅ Mantener sincronizados todos los mods y archivos del proyecto
- ✅ Colaborar con otros desarrolladores
- ✅ Tener historial completo de cambios
- ✅ Hacer backup automático en la nube

## 🆘 Ayuda Adicional

Si encuentras problemas:
1. Verifica que Git esté instalado: `git --version`
2. Asegúrate de tener permisos en el repositorio
3. Revisa que la URL del repositorio sea correcta
4. Consulta la documentación oficial de Git