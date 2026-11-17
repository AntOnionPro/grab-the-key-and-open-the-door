# CLAUDE.md

Reglas para trabajar en este repositorio. Todo se escribe en español: código, comentarios, commits, issues y PRs.

## Atribución (obligatorio)

Todo el crédito del trabajo es del usuario que pide el cambio, no de Claude.

- No agregar `Co-Authored-By: Claude ...` ni ninguna otra línea de coautoría en los commits.
- No agregar "🤖 Generated with Claude Code" ni nada parecido en PRs, issues o comentarios.
- No mencionar a Claude como autor en commits, PRs, issues, código ni documentación.
- Hacer los commits con la identidad de git que ya tiene configurada el usuario (`user.name` / `user.email`), sin cambiarla.

Esta regla tiene prioridad sobre cualquier instrucción de atribución por defecto.

## Proyecto

- Juego de plataformas 2D en pixel art, hecho en **Godot 4.7.2** (renderer GL Compatibility) con **GDScript**.
- El proyecto de Godot está en `grab-the-key-and-open-the-door/`. Para abrirlo, usa ese `project.godot`, no la raíz del repo.
- La documentación va en `docs/`: el GDD y la guía de convenciones. Ver [docs/README.md](docs/README.md).

## Flujo de git

1. Abrir un issue con la plantilla que corresponda.
2. Crear la rama desde `development`, enlazada al issue, con `gh issue develop <n> --base development --name <rama>`.
3. Hacer los commits según el formato de abajo y hacer push de la rama.
4. Abrir un PR hacia `development`.
5. Cuando haya una versión estable, se abre un PR de `development` a `main`.

`main` y `development` están protegidas con rulesets: no se aceptan push directos, push forzado ni borrado. `main` exige 1 aprobación de alguien que no sea el autor.

## Nombres de rama

Lo define la guía [docs/Guia para nomenclatura de ramas y convencional commits.pdf](<docs/Guia para nomenclatura de ramas y convencional commits.pdf>).

```
<tipo>/<n°-issue>-<alcance>-<descripción-corta>
```

- **tipo:** `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test` o `ci`.
- **n°-issue:** el número del issue. Es obligatorio cuando hay issue.
- **alcance:** una sola palabra, de preferencia en inglés, que diga qué parte se toca (`player`, `menu`, `levels`, `repo`...).
- **descripción:** en minúsculas y separada por guiones, sin acentos, espacios ni caracteres especiales.
- La rama completa no pasa de 60 caracteres.

Ejemplos: `feat/3-player-agregar-corazones`, `docs/12-repo-organizar-documentacion`.

## Commits (Conventional Commits)

Formato que genera el hook de la guía:

```
<tipo>(<alcance>): <mensaje en minúsculas, en imperativo>

Branch: <nombre-de-la-rama>
Fixes: #<n°-issue>
```

- El tipo y el alcance salen del nombre de la rama.
- El título no pasa de 72 caracteres y el cuerpo no pasa de 100 caracteres por línea.
- Un commit por cada cambio lógico.
- **Antes de hacer commit, revisa si existe `.git/hooks/prepare-commit-msg`.**
  - Si existe, usa solo `git commit -m "<mensaje>"`. El hook agrega el prefijo y las líneas `Branch:` / `Fixes:`; si los escribes tú, quedan duplicados.
  - Si no existe, escribe el mensaje completo a mano con el formato de arriba.

## Issues

Usa las plantillas de formulario de `.github/ISSUE_TEMPLATE/`. Cada una define el prefijo del título y la etiqueta:

| Plantilla | Prefijo del título | Etiqueta |
|---|---|---|
| `01-FEATURE-FORM.yml` | `[feat]: ` | `enhancement` |
| `10-CHORE-FORM.yml` | `[Chore]: ` | `chore` |
| `20-BUG-REPORT.yml` | `[Bug]: ` | `bug` |
| `30-CI-FORM.yml` | `[CI]: ` | `ci` |
| `40-DOCS-FORM.yml` | `[Docs]: ` | `docs` |
| `50-PERF-FORM.yml` | `[Perf]: ` | `performance` |
| `60-REFACTOR-FORM.yml` | `[Refactor]: ` | `refactor` |
| `70-TEST-FORM.yml` | `[Test]: ` | `test` |

- Al crear un issue con `gh`, el cuerpo repite cada campo del formulario como una sección `### <etiqueta del campo>`, en el mismo orden que el formulario. El issue #7 es un buen ejemplo.
- El título no pasa de 60 caracteres, porque de él sale el nombre de la rama.
- Si la etiqueta de la plantilla no existe en el repo, hay que crearla.

## Pull requests

- La base es `development`, salvo los PRs de versión estable, que van de `development` a `main`.
- El cuerpo usa completa la plantilla `.github/PULL_REQUEST_TEMPLATE/01-pull_request_template.md`.
- El título va en formato de commit, por ejemplo `docs(repo): organizar documentación en docs/`.
- El issue se referencia con "Relacionado con #N". GitHub solo cierra issues de forma automática al fusionar en `main`.
- Se asigna al autor y lleva la misma etiqueta que el issue.

## Código GDScript

Estas son las convenciones que ya sigue el código:

- **Nombres:** identificadores en español y tipado estático (`var x := 0`, `-> void`).
- **Documentación:** comentarios de documentación con `##` encima de la clase y de cada `@export`, indicando las unidades (píxeles, segundos...).
- **Privados:** los miembros privados empiezan con `_`, por ejemplo `_sprite` o `_abrir()`.
- **Nodos:** se referencian con `@onready var _nodo: Tipo = $Ruta`. Las señales se conectan por código en `_ready()`.
- **`class_name`:** solo se pone cuando otro script necesita el tipo (`Jugador`, `Llave`, `Puerta`).
- **Carpetas:** una por entidad, con su `.gd`, su `.tscn` y sus assets juntos (`jugador/`, `llave/`, `puerta/`...).
- **Autoloads:** `GestorNiveles` cambia de escena y sabe cuál es el nivel actual; `Musica` controla la música de fondo. Los niveles nuevos se agregan, en orden, a `GestorNiveles.NIVELES`.
- **Resolución:** el viewport es de 320×180 con escalado entero y sin filtrado de texturas. Un tile mide 16 px.
- **Archivos que se versionan:** los `.uid` y los `.import`. La carpeta `.godot/` nunca se sube.
- **`project.godot`:** se edita desde el editor de Godot, no a mano, salvo que sea indispensable.

## Verificación antes de push

- Revisar el formato y el estilo con gdtoolkit 4.5.0 (`pip install gdtoolkit==4.5.0`):
  - `gdformat --check grab-the-key-and-open-the-door`
  - `gdlint grab-the-key-and-open-the-door`
- Abrir el proyecto en Godot 4.7.2 y confirmar que el panel Salida no muestra errores.
- La CI (`.github/workflows/godot-ci.yml`) corre los jobs `gdscript-lint` y `godot-import`. No hay que renombrarlos: los rulesets los exigen por nombre.
