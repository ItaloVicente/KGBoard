extends Node2D
# Variáveis para o tabuleiro e os peões
@export var pawn_scene: PackedScene  # Arraste a cena "peao.tscn" para esta propriedade no editor.
var pawn_positions = []  # Lista para armazenar posições iniciais para os peões.
var tabuleiro_positions = []  # Posições predefinidas no tabuleiro
var forma_geometrica_associada = []
var cores = ["Vermelho", "Azul", "Preto", "Branco"]
var posicoes_peoes = {}
var id_passados = {}
var indices_jogadores = []
var ultimo_indice = 0
var pergunta = ""
var alternativas = []
var resposta_correta = []
var cor = ""
var carta = null
const Position = preload("res://scripts/posicao.gd")
var posicoes = []
func _ready() -> void:
	# Defina as posições iniciais dos peões no tabuleiro.
	# Ajuste estas coordenadas com base no layout do tabuleiro.
	var file_path = "res://positions/positions.json"
	posicoes = carregar_positions(file_path)
	
	pawn_positions = [
		Vector2(40, 50),
		Vector2(50, 50),
		Vector2(60, 50),
		Vector2(70, 50)
	]
	#colocar as posicoes aqui
	tabuleiro_positions = [
		Vector2(145, 50),
		Vector2(220, 50),
		Vector2(290, 50),
		Vector2(360, 50)
	]
	forma_geometrica_associada = [
		"triângulo", "losango", "quadrado", "círculo"
	]  # Exemplo de percurso no tabuleiro
	
	# Chama a função para adicionar os peões (modifique conforme o número de jogadores).
	var jogadores = get_tree().root.get_meta("jogadores")
	add_pawns(jogadores)
	for position in posicoes:
		print(position.get_position())

# Função para adicionar os peões ao tabuleiro
func add_pawns(player_count: int) -> void:
	for i in range(player_count):
		posicoes_peoes[i] = pawn_positions[i]
		indices_jogadores.append(i)
		var pawn = pawn_scene.instantiate()  # Instancia a cena do peão
		pawn.position = pawn_positions[i]  # Define a posição inicial
		$Peoes.add_child(pawn)
		for j in range(4):  # A cena do peão tem 4 sprites
			var sprite = pawn.get_node(cores[j])  # Considerando que seus sprites são nomeados "Sprite1", "Sprite2", etc.
			if j == i:  # Se o índice do sprite for maior que o número de jogadores, esconda
				sprite.visible = true
			else:
				sprite.visible = false
func carregar_positions(file_path: String) -> Array:
	var positions = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		var parsed_data = JSON.parse_string(data)
		if typeof(parsed_data) == TYPE_ARRAY:
			for item in parsed_data:
				var vector_pos = Vector2(item["pos"][0], item["pos"][1])
				var forma = item["forma_geometrica"]
				var position = Position.new(vector_pos, forma)
				positions.append(position)
		else:
			print("Erro ao parsear JSON:", parsed_data.error_string)
		file.close()
	else:
		print("Erro ao abrir o arquivo:", file_path)
	return positions
func mover_peao_frente(jogador_id: int, forma_geométrica: String) -> void:
	var pawn = $Peoes.get_child(jogador_id)  # Obter o peão correspondente
	var indice_forma_geometrica = 0
	print(forma_geométrica)
	var start_position = pawn.position
	if forma_geometrica_associada.find(start_position) > -1:
		indice_forma_geometrica = forma_geometrica_associada.find(start_position)
	print(forma_geometrica_associada[indice_forma_geometrica])
	var next_position_index = tabuleiro_positions.find(start_position) + 1
	if next_position_index >= tabuleiro_positions.size():
		print("Jogador Ganhou!", jogador_id)
		var tween = create_tween()
		tween.tween_property(pawn, "position", pawn_positions[jogador_id], 1.0)
		return
	
	var target_position = tabuleiro_positions[next_position_index]
	posicoes_peoes[jogador_id] = target_position  # Atualiza a posição no dicionário
	# Cria e configura o Tween
	var tween = create_tween()
	tween.tween_property(pawn, "position", target_position, 1.0)
	
func mover_peao_atras(jogador_id: int) -> void:
	var pawn = $Peoes.get_child(jogador_id)  # Obter o peão correspondente
	print(pawn.position)
	var start_position = pawn.position
	var next_position_index = tabuleiro_positions.find(start_position) - 1
	if next_position_index < 0:
		var tween = create_tween()
		tween.tween_property(pawn, "position", pawn_positions[jogador_id], 1.0)
		return
	
	var target_position = tabuleiro_positions[next_position_index]
	posicoes_peoes[jogador_id] = target_position  # Atualiza a posição no dicionário
	# Cria e configura o Tween
	var tween = create_tween()
	tween.tween_property(pawn, "position", target_position, 1.0)


# Responder ao sinal "jogador_acertou"
func _on_jogador_acertou(jogador_id: int, forma_geometrica: String) -> void:
	print("Jogador acertou! Movendo peão:", jogador_id)
	mover_peao_frente(jogador_id, forma_geometrica)

func _on_jogador_errou(jogador_id: int) -> void:
	print("Jogador errou! Movendo peão:", jogador_id)
	mover_peao_atras(jogador_id)
#Função para sortear uma questão
func random_question(temas, indices_jogadores, ultimo_indice) -> void:
	var tamanho_vetor = temas.size() - 1
	var rng = RandomNumberGenerator.new()
	var number = rng.randi_range(0, tamanho_vetor)
	var tema = temas[number]
	var path = "questions/" + tema + ".json"
	var questoes = carregar_json(path)
	
	if questoes.size() > 0:  # Verifica se há questões carregadas
		var verificador = false
		while not verificador:
			var questao_sorteada = questoes[rng.randi_range(0, questoes.size() - 1)]
			if questao_sorteada["tema"] not in id_passados:
				var L = []
				L.append(questao_sorteada["id"])
				self.id_passados[questao_sorteada["tema"]] = L
				verificador = true
				_process_question(questao_sorteada, ultimo_indice)
				if ultimo_indice == indices_jogadores.size()-1:
					self.ultimo_indice = 0
				else:
					self.ultimo_indice += 1
			elif questao_sorteada["tema"] in id_passados:
				if questao_sorteada["id"] not in id_passados[questao_sorteada["tema"]]:
					var L = id_passados[questao_sorteada["tema"]]
					L.append(questao_sorteada["id"])
					self.id_passados[questao_sorteada["tema"]] = L
					verificador = true
					_process_question(questao_sorteada, ultimo_indice)
					if ultimo_indice == indices_jogadores.size()-1:
						self.ultimo_indice = 0
					else:
						self.ultimo_indice += 1
				else:
					if questoes.size() == id_passados[questao_sorteada["tema"]].size():
						self.id_passados[questao_sorteada["tema"]] = []
	else:
		print("Nenhuma questão encontrada para o tema:", tema)

func _process_question(questao_sorteada, ultimo_indice):
	# Processa a questão e define as propriedades no nó root
	pergunta = questao_sorteada["pergunta"]
	get_tree().root.set_meta("pergunta", pergunta)
	alternativas = questao_sorteada["alternativas"]
	get_tree().root.set_meta("alternativas", alternativas)
	resposta_correta = questao_sorteada["resposta_correta"]
	get_tree().root.set_meta("resposta_correta", resposta_correta)
	cor = cores[ultimo_indice]
	get_tree().root.set_meta("cor", cor)
	get_tree().root.set_meta("id_jogador", ultimo_indice)
	var forma_geometrica = questao_sorteada["forma_geometrica"]
	get_tree().root.set_meta("forma_geometrica", forma_geometrica)
	# Carrega e instancia a cena da carta
	var carta_scene = preload("res://scenes/carta.tscn")
	carta = carta_scene.instantiate()

	if carta != null:
		# Adiciona a carta como filho da cena atual
		var current_scene = get_tree().current_scene
		if current_scene != null:
			current_scene.add_child(carta)
			# Posicione a carta, se necessário
			carta.position = Vector2(50, 25)  # Ajuste conforme necessário
			carta.z_index = 1  # Garante que fique acima de outros elementos
			# **Desativa os botões do tabuleiro**
			set_buttons_active(false)
			# **Conecta o sinal emitido pela carta**
			carta.connect("jogador_acertou", Callable(self, "_on_jogador_acertou"))
			carta.connect("jogador_errou", Callable(self, "_on_jogador_errou"))
			carta.connect("carta_finalizada", Callable(self, "_on_carta_finalizada"))
		else:
			print("Erro: Cena atual não encontrada.")
	else:
		print("Erro: Não foi possível instanciar a carta.")
	
func carregar_json(caminho: String) -> Array:
	# Abre o arquivo JSON
	var file = FileAccess.open(caminho, FileAccess.READ)
	var conteudo = file.get_as_text()  # Lê o conteúdo do arquivo como texto
	file.close()  # Fecha o arquivo
	var resultado = JSON.parse_string(conteudo)
	return resultado
func _on_carta_finalizada() -> void:
	# Reativa os botões do tabuleiro após o jogador confirmar na carta
	set_buttons_active(true)
	
func set_buttons_active(active: bool) -> void:
	for child in get_tree().root.get_children():
		if child.name == "Tabuleiro":
			var no = child
			for filho_no in no.get_children():  # Supondo que os botões estão em um nó chamado "BotaoTabuleiro"
				if filho_no is Button:
					filho_no.disabled = not active
			
func _on_button_pressed() -> void:
	var temas_selecionados = get_tree().root.get_meta("temas")
	random_question(temas_selecionados,indices_jogadores, ultimo_indice)
	pass # Replace with function body.
