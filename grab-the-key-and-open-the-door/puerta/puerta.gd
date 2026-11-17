class_name Puerta
extends Area2D
## Puerta de salida. Si el jugador la toca con la llave, se abre, suena un efecto y se carga
## el siguiente nivel. Sin la llave no pasa nada.
##
## El origen de la escena está en la base de la puerta, para colocarla justo sobre el suelo.

const CUADRO_ABIERTA := 1

var _abierta := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _sonido: AudioStreamPlayer = $Sonido


func _physics_process(_delta: float) -> void:
	if _abierta:
		return
	# Se revisa en cada cuadro y no solo al entrar: así también se abre si el jugador
	# toma la llave mientras ya está tocando la puerta.
	for cuerpo in get_overlapping_bodies():
		var jugador := cuerpo as Jugador
		if jugador != null and jugador.tiene_llave:
			_abrir()
			return


func _abrir() -> void:
	_abierta = true
	_sprite.frame = CUADRO_ABIERTA
	_sonido.play()
	await _sonido.finished
	GestorNiveles.siguiente_nivel()
