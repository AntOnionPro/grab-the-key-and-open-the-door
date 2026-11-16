class_name Jugador
extends CharacterBody2D
## Personaje que controla el usuario: camina, salta y cambia de animación según lo que hace.
##
## El origen de la escena está en los pies, para colocarlo en un nivel justo sobre el suelo.

## Velocidad horizontal, en píxeles por segundo.
@export var velocidad: float = 80.0
## Altura máxima del salto, en píxeles (un tile mide 16).
@export var altura_salto: float = 40.0
## Segundos que tarda en llegar a la altura máxima del salto.
@export var tiempo_hasta_cima: float = 0.35

## true cuando ya tomó la llave del nivel. Lo pone la llave y lo revisa la puerta.
var tiene_llave := false

var _gravedad: float
var _velocidad_salto: float

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _sonido_salto: AudioStreamPlayer = $SonidoSalto


func _ready() -> void:
	# Con la altura y el tiempo del salto se calculan la gravedad y la velocidad inicial
	# (tiro vertical). Así el salto se ajusta en píxeles y segundos, no probando números.
	_gravedad = 2.0 * altura_salto / pow(tiempo_hasta_cima, 2)
	_velocidad_salto = -2.0 * altura_salto / tiempo_hasta_cima


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravedad * delta

	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = _velocidad_salto
		_sonido_salto.play()

	var direccion := Input.get_axis("izquierda", "derecha")
	velocity.x = direccion * velocidad

	move_and_slide()
	_actualizar_animacion(direccion)


func _actualizar_animacion(direccion: float) -> void:
	# Sin tecla pulsada se conserva hacia dónde miraba.
	if direccion != 0.0:
		_sprite.flip_h = direccion < 0.0

	if not is_on_floor():
		_sprite.play("saltar")
	elif direccion != 0.0:
		_sprite.play("caminar")
	else:
		_sprite.play("inactivo")
