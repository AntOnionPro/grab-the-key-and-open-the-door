extends Area2D
## Piedra fija del nivel: si el jugador la toca, pierde un corazón y reaparece al inicio.
##
## El origen de la escena está en la base de la piedra, para colocarla justo sobre el suelo.
## La caja de colisión es un poco más chica que el dibujo, para que no cuente un roce.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(cuerpo: Node2D) -> void:
	var jugador := cuerpo as Jugador
	if jugador == null:
		return

	jugador.recibir_dano()
