extends Node

@onready var main = $CanvasLayer/Main
@onready var address_line = $CanvasLayer/Main/MarginContainer/VBoxContainer/LineEdit

const PORT = 6969
var enet_peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_pressed() -> void:
	main.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer


func _on_join_pressed() -> void:
	main.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
