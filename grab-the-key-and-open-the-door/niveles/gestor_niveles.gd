extends Node
## Sabe qué niveles hay, en qué orden y cuál se está jugando, y hace los cambios de escena
## entre el menú, los niveles y Game Over. También lleva los corazones que le quedan al
## jugador en el nivel actual.
##
## Es un autoload (Proyecto → Configuración del proyecto → Globales) con el nombre
## GestorNiveles, así que existe en todas las escenas y no se reinicia al cambiar de nivel.

## Se emite cuando el jugador pierde un corazón, para que el HUD lo muestre en ese momento.
signal corazones_cambiaron(cantidad: int)

## Total de niveles del juego; es el número que muestra el contador "Nivel X / 10".
const TOTAL_NIVELES := 10

## Escenas de los niveles, en orden. Cada nivel nuevo se agrega al final de la lista.
## TEMPORAL (#1): la escena de prueba va dos veces para probar el paso de un nivel a otro.
## #5 la cambia por el nivel 1.
const NIVELES: Array[String] = [
	"res://pruebas/escena_prueba.tscn",
	"res://pruebas/escena_prueba.tscn",
]

const ESCENA_MENU := "res://menu/menu.tscn"
const ESCENA_GAME_OVER := "res://game_over/game_over.tscn"

## Corazones con los que el jugador empieza cada nivel.
const CORAZONES_INICIALES := 3

## Posición en NIVELES del nivel que se está jugando (0 es el nivel 1).
var indice_actual := 0
## Corazones que le quedan al jugador en el nivel actual. Vuelven a CORAZONES_INICIALES
## cada vez que se carga un nivel, pero no al reaparecer.
var corazones := CORAZONES_INICIALES


## Número del nivel actual contando desde 1, para mostrarlo en pantalla.
func numero_nivel() -> int:
	return indice_actual + 1


func iniciar_partida() -> void:
	indice_actual = 0
	_cargar_nivel_actual()


func siguiente_nivel() -> void:
	if indice_actual + 1 < NIVELES.size():
		indice_actual += 1
		_cargar_nivel_actual()
	else:
		# Fin del juego: se regresa al menú (GDD, Guión).
		ir_al_menu()


func ir_al_menu() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)


## La llama reaparecer() cuando el jugador se quedó sin corazones.
func mostrar_game_over() -> void:
	get_tree().change_scene_to_file(ESCENA_GAME_OVER)


## Resta un corazón. La llama el jugador en el momento del golpe, así el HUD vacía el
## corazón de inmediato (Storyboard, escena 07), antes de reaparecer.
func perder_corazon() -> void:
	corazones = maxi(corazones - 1, 0)
	corazones_cambiaron.emit(corazones)


## Después del efecto de daño: si le quedan corazones, el jugador reaparece al inicio del
## nivel actual; si no, se muestra Game Over.
func reaparecer() -> void:
	if corazones > 0:
		# Recargar la escena deja el nivel como al principio: el jugador en el punto de
		# inicio y la llave en su lugar. Los corazones no se pierden porque viven aquí.
		get_tree().reload_current_scene()
	else:
		mostrar_game_over()


func _cargar_nivel_actual() -> void:
	corazones = CORAZONES_INICIALES
	get_tree().change_scene_to_file(NIVELES[indice_actual])
