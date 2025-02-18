extends Node2D

# Alterar pergunta, alternativas, id do jogador, respostas corretas
var pergunta = ""
var alternativas = []
var resposta_correta = []
var forma_geometrica = ""
var cor = "Vez do peão "
#1 se tiver acertado
var is_correct = 0
var jogador_id: int
signal carta_finalizada
signal jogador_acertou
signal jogador_errou
@onready var label_pergunta = $Label
@onready var label_vez = $Label2
@onready var alternativas_container = $GridContainer
@onready var botao_confirmar = $Button
@onready var card_sprite = $Sprite2D
@onready var acertou_audio: AudioStreamPlayer = $AcertouAudio
@onready var errou_audio: AudioStreamPlayer = $ErrouAudio

# Defina a largura máxima do texto para os checkboxes
var max_text_width = 330  # Altere esse valor conforme necessário para ajustar ao tamanho do seu card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pergunta = get_tree().root.get_meta("pergunta")
	alternativas = get_tree().root.get_meta("alternativas")
	resposta_correta = get_tree().root.get_meta("resposta_correta")
	cor += get_tree().root.get_meta("cor")
	jogador_id = get_tree().root.get_meta("id_jogador")
	forma_geometrica = get_tree().root.get_meta("forma_geometrica")
	# Configura os elementos da carta
	label_pergunta.text = pergunta  # Define o texto da pergunta
	label_vez.text = cor
	if cor == "Vez do peão Vermelho":
		print(cor)
		label_vez.modulate = Color(1, 0, 0)
	elif cor == "Vez do peão Preto":
		label_vez.modulate = Color(0, 0, 0)
	elif cor == "Vez do peão Azul":
		label_vez.modulate = Color(0, 0, 1)
	elif cor == "Vez do peão Branco":
		label_vez.modulate = Color(1, 1, 1)
	
	# Cria e ajusta os checkboxes
	for alternativa in alternativas:
		var checkbox = CheckBox.new()
		checkbox.text = alternativa
		ajustar_tamanho_checkbox(checkbox)  # Ajusta o tamanho do checkbox
		alternativas_container.add_child(checkbox)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)  # Impede maximização

# Ajustar o tamanho do texto para caber dentro do limite
func ajustar_tamanho_checkbox(checkbox: CheckBox) -> void:
	var font_size = 15
	var font = checkbox.get_theme_default_font()  # Obtenha a fonte padrão do tema
	var text = checkbox.text
	var wrapped_text = ""
	var line = ""
	for word in text.split(" "):
		var test_line = line + ("" if line == "" else " ") + word
		if font.get_string_size(test_line).x <= max_text_width:
			line = test_line
		else:
			wrapped_text += line + "\n"
			line = word
			checkbox.add_theme_font_size_override("font_size", font_size)
	wrapped_text += line  # Adiciona a última linha
	checkbox.text = wrapped_text.strip_edges()  # Define o texto ajustado

# Função chamada para verificar e desmarcar checkboxes
func check_and_uncheck() -> void:
	for i in range(alternativas_container.get_child_count()):
		var child = alternativas_container.get_child(i)
		if child is CheckBox:
			if child.is_pressed():  # Se o checkbox estiver marcado
				# Desmarque todos os outros checkboxes
				for j in range(alternativas_container.get_child_count()):
					var other_child = alternativas_container.get_child(j)
					if other_child is CheckBox and other_child != child:
						other_child.set_pressed(false)

# Função chamada quando o estado de um checkbox é alterado
func _process(delta: float) -> void:
	# Verifique todos os checkboxes a cada frame
	check_and_uncheck()
	
# Função chamada ao pressionar o botão
func _on_button_pressed() -> void:
	for i in range(alternativas_container.get_child_count()):
		var child = alternativas_container.get_child(i)
		if child is CheckBox and child.is_pressed():
			for alternativa_correta in resposta_correta:
				print(alternativa_correta)
				var list_resposta = child.text.split("\n")
				var resposta_final = ""
				for resposta in list_resposta:
					resposta_final = resposta_final + " " + resposta
				if resposta_final.strip_edges() == alternativa_correta:
					print("Jogador acertou!")
					print(jogador_id)
					acertou_audio.play()
					await acertou_audio.finished
					emit_signal("jogador_acertou", jogador_id, forma_geometrica)  # Emitir um sinal, por exemplo
					emit_signal("carta_finalizada")
					queue_free()
					is_correct = 1
					get_tree().root.set_meta("is_correct", is_correct)
					return 
	print("Jogador errou!")
	errou_audio.play()
	await errou_audio.finished
	emit_signal("jogador_errou", jogador_id, forma_geometrica)  # Emitir um sinal, por exemplo
	emit_signal("carta_finalizada")
	get_tree().root.set_meta("is_correct", is_correct)
	return
