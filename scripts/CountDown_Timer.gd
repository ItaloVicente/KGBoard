extends Node

var timer
var total_time: int = 60  # Tempo total em segundos (ajuste conforme necessário)
var time_left: int = total_time
var jogador_id: int
var forma_geometrica = ""
signal tempo_acabou
signal finalizar_carta
func _ready():
	timer = Timer.new()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.set_wait_time(1)  # Define o tempo de espera do timer para 1 segundo
	timer.set_one_shot(false)
	add_child(timer)
	timer.start()
	update_label()  # Atualiza o label inicialmente
	jogador_id = get_tree().root.get_meta("id_jogador")
	forma_geometrica = get_tree().root.get_meta("forma_geometrica")

func _on_timer_timeout():
	time_left -= 1
	if time_left <= 0:
		timer.stop()
		$Label.text = "Perdeu a vez, tempo acabou!"  # Exibe a mensagem quando o tempo acabar
		emit_signal("tempo_acabou", jogador_id, forma_geometrica)  # Emitir um sinal, por exemplo
		emit_signal("finalizar_carta")
	else:
		update_label()  # Atualiza o label com o tempo restante

func update_label():
	var minutes = floor(time_left / 60)
	var seconds = time_left % 60
	$Label.text = "%02d:%02d" % [minutes, seconds]
