extends Control
## Menú principal: título, botones para iniciar o salir y Kip corriendo de fondo.

@onready var _boton_iniciar: Button = $Botones/BotonIniciar
@onready var _boton_salir: Button = $Botones/BotonSalir


func _ready() -> void:
	# La música empieza aquí. Si ya sonaba (por ejemplo, al volver de un nivel), sigue igual.
	Musica.reproducir()
	_boton_iniciar.pressed.connect(GestorNiveles.iniciar_partida)
	_boton_salir.pressed.connect(get_tree().quit)
