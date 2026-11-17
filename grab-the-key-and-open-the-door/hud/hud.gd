extends CanvasLayer
## Interfaz que se dibuja encima del nivel. Por ahora solo muestra el contador de nivel.

@onready var _contador: Label = $ContadorNivel


func _ready() -> void:
	_contador.text = "Nivel %d / %d" % [GestorNiveles.numero_nivel(), GestorNiveles.TOTAL_NIVELES]
