
extends Node2D

var jogadores : int
var temas_selecionados = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var temas = ["Lógica", "Português", "Ciências", "Teste de Software", "História"]
	var container = $PopupTemas/GridContainer
	for tema in temas:
		var checkbox = CheckBox.new()
		checkbox.text = tema
		container.add_child(checkbox)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)  # Impede maximização
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jogadores_pressed() -> void:
	$PopupJogadores.popup_centered()
	pass # Replace with function body.


func _on_regras_pressed() -> void:
	$PopupRegras.popup_centered()
	pass # Replace with function body.


func _on_voltar_pressed() -> void:
	$PopupRegras.hide()
	pass # Replace with function body.


func _on_iniciar_jogo_pressed() -> void:
	if len(temas_selecionados) > 0:
		jogadores = $PopupJogadores/HBoxContainer/OptionButton.get_selected_id() + 2
		get_tree().root.set_meta("jogadores", jogadores)
		get_tree().root.set_meta("temas", temas_selecionados)
		get_tree().change_scene_to_file("res://scenes/tabuleiro.tscn")
	else:
		$PopupErro.popup_centered()
	pass # Replace with function body.


func _on_voltar_jogador_pressed() -> void:
	$PopupJogadores.hide()
	pass # Replace with function body.


func _on_temas_pressed() -> void:
	$PopupTemas.popup_centered()
	pass # Replace with function body.


func _on_button_pressed() -> void:
	var container = $PopupTemas/GridContainer
	temas_selecionados = []

	for child in container.get_children():
		if child is CheckBox and child.is_pressed():
			temas_selecionados.append(child.text)
	$PopupTemas.hide()
	pass # Replace with function body.


func _on_voltar_erro_pressed() -> void:
	$PopupErro.hide()
	pass # Replace with function body.
