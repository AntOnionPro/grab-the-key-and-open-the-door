class_name Llave
extends Area2D
## Llave del nivel: al tocarla, el jugador se queda con ella, suena un efecto y desaparece.

@onready var _sprite: Sprite2D = $Sprite
@onready var _sonido: AudioStreamPlayer = $Sonido


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(cuerpo: Node2D) -> void:
	var jugador := cuerpo as Jugador
	if jugador == null:
		return

	jugador.tiene_llave = true
	# Se oculta y deja de detectar en este momento, pero el nodo se libera hasta que termina
	# el sonido: si se liberara antes, el sonido se cortaría.
	set_deferred("monitoring", false)
	_sprite.hide()
	_sonido.play()
	await _sonido.finished
	queue_free()
