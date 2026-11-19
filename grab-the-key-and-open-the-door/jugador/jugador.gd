class_name Jugador
extends CharacterBody2D
## Personaje que controla el usuario: camina, salta y cambia de animación según lo que hace.
## Si cae al vacío o toca una piedra, pierde un corazón y reaparece al inicio del nivel.
## Se agarra de las lianas al tocarlas en el aire, se columpia con ←/→, trepa con ↑/↓ y se
## suelta con Espacio. Desde lo alto de una liana, con ↑ se sube a la plataforma de la que cuelga.
##
## El origen de la escena está en los pies, para colocarlo en un nivel justo sobre el suelo.

## Dónde queda la mano que sujeta la liana en la animación "colgado", en píxeles desde los pies,
## mirando a la derecha. Si mira a la izquierda, x cambia de signo.
const MANOS_COLGADO := Vector2(4, -15)
## Hasta cuántos píxeles arriba del anclaje de una liana se busca una plataforma para subirse.
const ALCANCE_PLATAFORMA := 32.0
## Píxeles que el saltito para subirse a una plataforma pasa por encima de ella. Sin esto
## llegaría justo a la superficie y podría quedar a medias en la plataforma atravesable.
const HOLGURA_SUBIDA := 6.0

## Velocidad horizontal, en píxeles por segundo.
@export var velocidad: float = 80.0
## Altura máxima del salto, en píxeles (un tile mide 16).
@export var altura_salto: float = 40.0
## Segundos que tarda en llegar a la altura máxima del salto.
@export var tiempo_hasta_cima: float = 0.35
## Coordenada Y del nivel, en píxeles, a partir de la cual el jugador cuenta como caído al
## vacío. 196 es el borde inferior de la pantalla (180) más un tile, para que desaparezca
## por completo antes de reaparecer. En un nivel más alto se cambia en la instancia.
@export var limite_caida: float = 196.0
## Altura del saltito al soltarse de una liana, en píxeles. Se suma al impulso del columpio.
@export var altura_salto_liana: float = 12.0
## Qué tan rápido cambian ←/→ la velocidad horizontal en el aire después de soltarse de una
## liana, en píxeles por segundo al cuadrado. Es bajo para no perder el impulso del columpio.
@export var control_aire: float = 240.0
## Velocidad al subir o bajar por una liana, en píxeles por segundo.
@export var velocidad_trepar: float = 40.0

## true cuando ya tomó la llave del nivel. Lo pone la llave y lo revisa la puerta.
var tiene_llave := false

var _gravedad: float
var _velocidad_salto: float
var _velocidad_salto_liana: float
## true desde que recibe daño hasta que reaparece; evita restar más de un corazón por golpe.
var _herido := false
## Liana de la que está colgado, o null.
var _liana: Liana = null
## true desde que se suelta de una liana hasta que toca el suelo; mientras, conserva el impulso.
var _con_impulso_liana := false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _sonido_salto: AudioStreamPlayer = $SonidoSalto
@onready var _sonido_dano: AudioStreamPlayer = $SonidoDano


func _ready() -> void:
	# Con la altura y el tiempo del salto se calculan la gravedad y la velocidad inicial
	# (tiro vertical). Así el salto se ajusta en píxeles y segundos, no probando números.
	_gravedad = 2.0 * altura_salto / pow(tiempo_hasta_cima, 2)
	_velocidad_salto = -2.0 * altura_salto / tiempo_hasta_cima
	_velocidad_salto_liana = -sqrt(2.0 * _gravedad * altura_salto_liana)


func _physics_process(delta: float) -> void:
	if global_position.y > limite_caida:
		recibir_dano()
		return

	if _liana != null:
		_columpiarse(delta)
		return

	if not is_on_floor():
		velocity.y += _gravedad * delta

	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = _velocidad_salto
		_sonido_salto.play()

	var direccion := Input.get_axis("izquierda", "derecha")
	if _con_impulso_liana:
		_mover_con_impulso(direccion, delta)
	else:
		velocity.x = direccion * velocidad

	move_and_slide()
	if is_on_floor():
		_con_impulso_liana = false
	_actualizar_animacion(direccion)


## Quita un corazón: el jugador se queda quieto con la pose de herido, suena el efecto y
## después reaparece al inicio del nivel (o se muestra Game Over si era el último). La
## llaman la piedra y la caída al vacío. Si ya estaba herido no hace nada, así un golpe resta
## un solo corazón aunque siga tocando la piedra varios fotogramas.
func recibir_dano() -> void:
	if _herido:
		return
	_herido = true
	set_physics_process(false)
	_sprite.play("herido")
	GestorNiveles.perder_corazon()
	# Se espera a que termine el sonido antes de recargar el nivel: si se recargara antes,
	# el sonido se cortaría.
	_sonido_dano.play()
	await _sonido_dano.finished
	GestorNiveles.reaparecer()


## Solo se puede agarrar de una liana en el aire, sin estar ya colgado ni herido.
func puede_agarrarse() -> bool:
	return _liana == null and not _herido and not is_on_floor()


## La llama la liana cuando el jugador la toca y puede agarrarse.
func agarrar_liana(liana: Liana) -> void:
	_liana = liana
	_con_impulso_liana = false
	_liana.sujetar(global_position + _manos(), velocity)
	velocity = Vector2.ZERO
	# Mientras está colgado no se voltea: la mano que sujeta la liana está de un solo lado, y
	# voltearlo movería al personaje de un lado al otro de la liana.
	_sprite.play("colgado")


func _columpiarse(delta: float) -> void:
	if Input.is_action_just_pressed("saltar"):
		_soltar_liana(true)
		return

	# get_axis da -1 con ↑ y 1 con ↓: es lo que cambia la distancia al anclaje.
	var eje_trepar := Input.get_axis("arriba", "abajo")
	if eje_trepar < 0.0 and _liana.en_lo_alto():
		var altura := _altura_plataforma()
		if altura > 0.0:
			_subir_a_plataforma(altura)
			return

	var trepando := _liana.trepar(eje_trepar * velocidad_trepar * delta)
	_sprite.play("trepar" if trepando else "colgado")

	var direccion := Input.get_axis("izquierda", "derecha")
	var punto := _liana.columpiar(direccion, delta)
	if move_and_collide(punto - _manos() - global_position) != null:
		# Chocó con el escenario porque la liana pasa muy cerca de una pared o del suelo. Se
		# suelta sin impulso, en vez de quedar metido en un tile.
		_soltar_liana(false)


## Al soltarse con Espacio sale con la velocidad del columpio más un saltito hacia arriba.
func _soltar_liana(con_impulso: bool) -> void:
	var velocidad_columpio := _liana.soltar()
	_liana = null
	if con_impulso:
		velocity = velocidad_columpio + Vector2(0.0, _velocidad_salto_liana)
		_con_impulso_liana = true
		_sonido_salto.play()
	else:
		velocity = Vector2.ZERO


## Si arriba de la liana hay una plataforma atravesable donde pararse, devuelve cuántos píxeles
## hay de los pies a su superficie; si no, devuelve 0.
func _altura_plataforma() -> float:
	var subida := Vector2(0.0, _liana.global_position.y - ALCANCE_PLATAFORMA - global_position.y)
	# El camino hacia arriba tiene que estar libre. Una plataforma atravesable no lo bloquea y un
	# bloque sólido sí: así no intenta subir si la liana cuelga de un techo.
	if test_move(global_transform, subida):
		return 0.0
	# Desde arriba se baja de vuelta: lo primero que toca, si es un suelo, es la plataforma.
	var colision := KinematicCollision2D.new()
	if not test_move(global_transform.translated(subida), -subida, colision):
		return 0.0
	if colision.get_angle(up_direction) > floor_max_angle:
		return 0.0
	return -subida.y - colision.get_travel().length()


## Salta derecho hacia arriba lo justo para pasar la plataforma atravesable y caer encima de
## ella. altura es la distancia de los pies a la superficie, en píxeles.
func _subir_a_plataforma(altura: float) -> void:
	_soltar_liana(false)
	velocity.y = -sqrt(2.0 * _gravedad * (altura + HOLGURA_SUBIDA))
	_sonido_salto.play()


## En el aire, después de soltarse de una liana: sin tecla, o con la tecla hacia donde ya va más
## rápido que caminando, conserva la velocidad horizontal. Si no, la cambia poco a poco.
func _mover_con_impulso(direccion: float, delta: float) -> void:
	if direccion == 0.0:
		return
	if signf(direccion) == signf(velocity.x) and absf(velocity.x) > velocidad:
		return
	velocity.x = move_toward(velocity.x, direccion * velocidad, control_aire * delta)


## Posición de la mano que sujeta la liana, relativa a los pies.
func _manos() -> Vector2:
	if _sprite.flip_h:
		return Vector2(-MANOS_COLGADO.x, MANOS_COLGADO.y)
	return MANOS_COLGADO


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
