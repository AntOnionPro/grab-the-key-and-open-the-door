extends AnimatedSprite2D
## Kip corriendo solo de un lado a otro en el fondo del menú, sin que el usuario lo controle.

## Velocidad, en píxeles por segundo.
@export var velocidad: float = 60.0
## Hasta dónde corre a cada lado antes de dar la vuelta (posición x del centro).
@export var limite_izquierdo: float = 24.0
@export var limite_derecho: float = 220.0

var _direccion := 1.0


func _ready() -> void:
	play("caminar")


func _process(delta: float) -> void:
	position.x += velocidad * _direccion * delta
	if position.x >= limite_derecho:
		_direccion = -1.0
	elif position.x <= limite_izquierdo:
		_direccion = 1.0
	flip_h = _direccion < 0.0
