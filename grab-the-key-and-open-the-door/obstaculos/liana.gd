@tool
class_name Liana
extends Node2D
## Liana colgante: el jugador se agarra al tocarla en el aire, se columpia como péndulo con ←/→,
## sube y baja por ella con ↑/↓ y se suelta con Espacio conservando el impulso. No hace daño.
##
## El origen de la escena es el punto del que cuelga (arriba), para colocarla justo debajo de una
## plataforma. Al columpiarse gira completa alrededor de ese punto, así que no se rota en el
## nivel. El largo se ajusta con tramos y se ve en el editor.

## Alto de cada tramo, en píxeles (un tile).
const ALTO_TRAMO := 16.0
## Ancho de la zona donde el jugador se agarra, en píxeles. Es un poco más que el tallo, para que
## no haga falta atinarle exacto.
const ANCHO_ZONA := 8.0
## Distancia mínima del anclaje a las manos del jugador, en píxeles.
const RADIO_MINIMO := 8.0

const TEXTURA_TRAMO := preload("res://obstaculos/liana.png")
const TEXTURA_PUNTA := preload("res://obstaculos/liana_punta.png")

## Largo de la liana, en tramos de 16 px. El último tramo es la punta.
@export_range(1, 10) var tramos := 3:
	set(valor):
		tramos = valor
		queue_redraw()
## Gravedad del columpio, en píxeles por segundo al cuadrado. Es parecida a la del salto del
## jugador, para que el vuelo al soltarse se sienta como un salto.
@export var gravedad: float = 650.0
## Aceleración que le dan ←/→ al columpio, en píxeles por segundo al cuadrado.
@export var impulso: float = 150.0
## Fracción de su velocidad que pierde el columpio cada segundo con el jugador colgado. Sin esto
## no se detendría nunca, y con ←/→ crecería hasta el ángulo máximo.
@export var amortiguacion: float = 1.0
## Lo mismo, pero sin nadie colgado. Es mayor porque la liana sola pesa poco: se calma pronto y
## no alcanza al jugador después de que se suelta.
@export var amortiguacion_sola: float = 3.0
## Ángulo máximo del columpio respecto a la vertical, en grados.
@export_range(0.0, 90.0) var angulo_maximo: float = 70.0
## Segundos que pasan después de soltarse antes de que el jugador pueda volver a agarrarla.
@export var espera_tras_soltar: float = 0.4

## Ángulo respecto a la vertical, en radianes; es positivo con la punta hacia la derecha.
var _angulo := 0.0
## Velocidad angular, en radianes por segundo.
var _velocidad_angular := 0.0
## Distancia del anclaje a las manos del jugador colgado, en píxeles.
var _radio := 0.0
## true mientras el jugador está colgado; entonces es él quien avanza el columpio.
var _ocupada := false
## Segundos que faltan para que se pueda volver a agarrar.
var _espera := 0.0
## Jugador que está tocando la zona de la liana, o null.
var _jugador_cerca: Jugador = null

@onready var _zona: Area2D = $Zona
@onready var _colision: CollisionShape2D = $Zona/Colision


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# La forma se crea aquí con el largo de esta liana. El rectángulo del .tscn lo comparten
	# todas las instancias, así que no se modifica.
	var forma := RectangleShape2D.new()
	forma.size = Vector2(ANCHO_ZONA, _largo())
	_colision.shape = forma
	_colision.position = Vector2(0.0, _largo() / 2.0)

	_zona.body_entered.connect(_on_body_entered)
	_zona.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or _ocupada:
		return

	# Sin nadie colgado, la liana sigue columpiándose sola hasta quedar en reposo.
	_espera = maxf(_espera - delta, 0.0)
	_avanzar(0.0, _largo(), delta)

	# Se revisa en cada fotograma, no solo al entrar a la zona: así también se agarra si la
	# tocó desde el suelo y después saltó, o si la espera terminó mientras la seguía tocando.
	if _jugador_cerca != null and _espera == 0.0 and _jugador_cerca.puede_agarrarse():
		_jugador_cerca.agarrar_liana(self)


func _draw() -> void:
	var izquierda := -TEXTURA_TRAMO.get_width() / 2.0
	for i in tramos - 1:
		draw_texture(TEXTURA_TRAMO, Vector2(izquierda, i * ALTO_TRAMO))
	draw_texture(TEXTURA_PUNTA, Vector2(izquierda, (tramos - 1) * ALTO_TRAMO))


## La llama el jugador al agarrarse. punto_manos es dónde quedan sus manos y velocidad la que
## traía, ambas en coordenadas globales. Si llega corriendo, la liana ya empieza columpiándose.
func sujetar(punto_manos: Vector2, velocidad: Vector2) -> void:
	_ocupada = true
	_radio = clampf((punto_manos - global_position).dot(_direccion()), RADIO_MINIMO, _largo())
	_velocidad_angular = velocidad.dot(_tangente()) / _radio


## Avanza el columpio un fotograma con el jugador colgado y devuelve dónde quedan sus manos, en
## coordenadas globales. direccion es -1 (←), 0 o 1 (→).
func columpiar(direccion: float, delta: float) -> Vector2:
	_avanzar(direccion, _radio, delta)
	return global_position + _direccion() * _radio


## Mueve las manos del jugador colgado a lo largo de la liana, en píxeles: negativo sube y
## positivo baja. No pasa del anclaje (RADIO_MINIMO) ni de la punta. Devuelve true si se movió.
##
## La velocidad angular no cambia: al subir, ese punto de la liana va más lento, y soltar() ya
## calcula la velocidad con la distancia nueva.
func trepar(distancia: float) -> bool:
	var radio_anterior := _radio
	_radio = clampf(_radio + distancia, RADIO_MINIMO, _largo())
	return _radio != radio_anterior


## true si las manos del jugador colgado están lo más arriba que se puede trepar.
func en_lo_alto() -> bool:
	return _radio <= RADIO_MINIMO


## Suelta al jugador y devuelve su velocidad, en píxeles por segundo: la del columpio en el punto
## donde estaba agarrado.
func soltar() -> Vector2:
	var velocidad := _tangente() * _velocidad_angular * _radio
	_ocupada = false
	_espera = espera_tras_soltar
	return velocidad


## Péndulo: la gravedad lo regresa al centro, ←/→ lo empujan hacia cada lado y la amortiguación
## lo va frenando.
func _avanzar(empuje: float, radio: float, delta: float) -> void:
	var aceleracion := (-gravedad * sin(_angulo) + empuje * impulso) / radio
	_velocidad_angular += aceleracion * delta
	var freno := amortiguacion if _ocupada else amortiguacion_sola
	_velocidad_angular *= maxf(1.0 - freno * delta, 0.0)
	_angulo += _velocidad_angular * delta

	var limite := deg_to_rad(angulo_maximo)
	if absf(_angulo) > limite:
		_angulo = clampf(_angulo, -limite, limite)
		_velocidad_angular = 0.0

	# En Godot la rotación positiva gira en sentido horario y mueve la punta a la izquierda.
	rotation = -_angulo


func _largo() -> float:
	return tramos * ALTO_TRAMO


## Hacia dónde apunta la liana, del anclaje a la punta.
func _direccion() -> Vector2:
	return Vector2(sin(_angulo), cos(_angulo))


## Hacia dónde se mueve un punto de la liana cuando el ángulo crece.
func _tangente() -> Vector2:
	return Vector2(cos(_angulo), -sin(_angulo))


func _on_body_entered(cuerpo: Node2D) -> void:
	var jugador := cuerpo as Jugador
	if jugador != null:
		_jugador_cerca = jugador


func _on_body_exited(cuerpo: Node2D) -> void:
	if cuerpo == _jugador_cerca:
		_jugador_cerca = null
