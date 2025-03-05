extends Button

var id = 0

func _on_pressed():
	var main = get_tree().get_nodes_in_group("main")
	main[0].selected_unite = id
	print("id > ", id)
