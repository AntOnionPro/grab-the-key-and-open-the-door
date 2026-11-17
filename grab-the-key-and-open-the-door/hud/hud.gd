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
	_mostrar_corazones(GestorNiveles.corazones)
	# Al recibir un golpe el corazón se vacía en ese momento, antes de que el nivel se recargue.
	GestorNiveles.corazones_cambiaron.connect(_mostrar_corazones)


func _mostrar_corazones(cantidad: int) -> void:
	# Los primeros se ven llenos y los que ya perdió, vacíos: se vacían de derecha a izquierda.
	for i in _corazones.get_child_count():
		var corazon := _corazones.get_child(i) as TextureRect
		corazon.texture = corazon_lleno if i < cantidad else corazon_vacio
