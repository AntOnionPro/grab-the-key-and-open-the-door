extends Control
## Pantalla de Game Over. La muestra el gestor de niveles cuando el jugador pierde los
## 3 corazones (#3); su único botón regresa al menú principal.

@onready var _boton_volver: Button = $Botones/BotonVolver


func _ready() -> void:
	_boton_volver.pressed.connect(GestorNiveles.ir_al_menu)
