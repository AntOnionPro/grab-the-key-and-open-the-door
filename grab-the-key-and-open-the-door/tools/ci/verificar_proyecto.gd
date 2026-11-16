extends SceneTree
## Carga cada script, escena y recurso del proyecto y termina con codigo 1 si alguno falla.
##
## Lo ejecuta la CI (.github/workflows/godot-ci.yml) despues de importar el proyecto:
## godot --headless --path grab-the-key-and-open-the-door \
##   --script res://tools/ci/verificar_proyecto.gd
##
## Importar no basta: el editor no compila los scripts ni abre las escenas al importar.
## Sin esto, un error de sintaxis o una escena que apunta a un archivo borrado pasarian
## sin que nadie lo note hasta abrir el proyecto.
##
## Que detecta cada parte:
## - Escena o recurso con una dependencia inexistente: load() devuelve null y este script
##   termina con codigo 1.
## - Script con error de sintaxis: load() si lo devuelve, pero Godot imprime
##   "SCRIPT ERROR: Parse Error". El workflow busca ese texto en la salida y falla.

const EXTENSIONES := ["gd", "tscn", "scn", "tres", "res"]

# addons/ es codigo de terceros: los plugins de editor no cargan fuera del editor y darian
# falsos errores.
const CARPETAS_EXCLUIDAS := ["res://.godot", "res://addons"]


func _initialize() -> void:
	var archivos := _buscar_archivos("res://")
	var fallidos: Array[String] = []

	for ruta in archivos:
		if ResourceLoader.load(ruta) == null:
			fallidos.append(ruta)

	print("Archivos verificados: %d" % archivos.size())

	if fallidos.is_empty():
		print("Todos los archivos cargaron.")
		quit(0)
		return

	for ruta in fallidos:
		printerr("ERROR: no se pudo cargar %s" % ruta)
	quit(1)


func _buscar_archivos(carpeta: String) -> Array[String]:
	var encontrados: Array[String] = []
	var dir := DirAccess.open(carpeta)

	if dir == null:
		printerr("ERROR: no se pudo abrir la carpeta %s" % carpeta)
		return encontrados

	dir.list_dir_begin()
	var nombre := dir.get_next()

	while nombre != "":
		var ruta := carpeta.path_join(nombre)
		if dir.current_is_dir():
			if ruta not in CARPETAS_EXCLUIDAS:
				encontrados.append_array(_buscar_archivos(ruta))
		elif nombre.get_extension() in EXTENSIONES:
			encontrados.append(ruta)
		nombre = dir.get_next()

	dir.list_dir_end()
	return encontrados
