extends Node
## Música de fondo de todo el juego.
##
## Es un autoload con el nombre Musica: no se destruye al cambiar de escena, así que la pista
## sigue sonando sin cortarse ni reiniciarse entre el menú, los niveles y Game Over. Como hay
## un solo reproductor, nunca pueden sonar dos copias a la vez.

const PISTA := preload("res://musica/tema_principal.wav")

var _reproductor := AudioStreamPlayer.new()


func _ready() -> void:
	_reproductor.stream = PISTA
	_reproductor.volume_db = -4.0
	# Sigue sonando aunque el juego se pause.
	_reproductor.process_mode = Node.PROCESS_MODE_ALWAYS
	# El WAV ya trae su punto de bucle. Esto es solo un respaldo por si se importara sin bucle.
	_reproductor.finished.connect(_reproductor.play)
	add_child(_reproductor)


## Empieza la música. Si ya está sonando no hace nada, así no se reinicia al volver al menú.
func reproducir() -> void:
	if not _reproductor.playing:
		_reproductor.play()
