extends CanvasLayer
## Interfaz que se dibuja encima del nivel: el contador de nivel abajo a la izquierda y los
## corazones abajo a la derecha.

## Imagen del corazón que el jugador todavía tiene.
@export var corazon_lleno: Texture2D
## Imagen del corazón que ya perdió.
@export var corazon_vacio: Texture2D

@onready var _contador: Label = $ContadorNivel
@onready var _corazones: HBoxContainer = $Corazones


func _ready() -> void:
	_contador.text = "Nivel %d / %d" % [GestorNiveles.numero_nivel(), GestorNiveles.TOTAL_NIVELES]
	_mostrar_corazones()


func _mostrar_corazones() -> void:
	# Basta con leerlos al cargar: al perder un corazón el nivel se recarga, y el HUD con él.
	# Los primeros se ven llenos y los que ya perdió, vacíos.
	for i in _corazones.get_child_count():
		var corazon := _corazones.get_child(i) as TextureRect
		corazon.texture = corazon_lleno if i < GestorNiveles.corazones else corazon_vacio
