extends Node

const PORT = 6969
const MAX_PLAYERS = 1

# Scene to load for the game
@export var game_scene: PackedScene = preload("res://scenes/online.tscn")

@onready var main = $CanvasLayer/Main
@onready var container = $CanvasLayer/Main/MarginContainer/VBoxContainer
@onready var title = $CanvasLayer/Main/MarginContainer/VBoxContainer/Title
@onready var address_line = $CanvasLayer/Main/MarginContainer/VBoxContainer/LineEdit
@onready var host_button = $CanvasLayer/Main/MarginContainer/VBoxContainer/Host
@onready var join_button = $CanvasLayer/Main/MarginContainer/VBoxContainer/Join
@onready var spawner = $MultiplayerSpawner

var enet_peer = ENetMultiplayerPeer.new()
var players_ready = 0

func _ready() -> void:
	if not game_scene:
		push_error("game_scene is not set!")
		return
		
	# Set up the UI
	title.text = "Online Battle Game"
	address_line.placeholder_text = "Enter IP Address"
	host_button.text = "Host Game"
	join_button.text = "Join Game"
	
	# Center the container
	container.custom_minimum_size = Vector2(400, 200)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Add some spacing
	container.add_theme_constant_override("separation", 20)
	
	# Set up spawner
	spawner.spawn_path = NodePath("/")
	spawner.add_spawnable_scene(game_scene.resource_path)
	
	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_host_pressed() -> void:
	enet_peer.create_server(PORT, MAX_PLAYERS)  # Only 1 client can connect
	multiplayer.multiplayer_peer = enet_peer
	
	# Get a valid IP address
	var ip = ""
	for address in IP.get_local_addresses():
		# Skip IPv6 addresses and localhost
		if ":" not in address and address != "127.0.0.1":
			ip = address
			break
	
	title.text = "Your IP Address: " + ip + "\nWaiting for player to join..."
	host_button.disabled = true
	join_button.disabled = true

func _on_join_pressed() -> void:
	var address = address_line.text if address_line.text.length() > 0 else "localhost"
	enet_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	title.text = "Connecting to host..."
	host_button.disabled = true
	join_button.disabled = true

func _on_peer_connected(id: int) -> void:
	players_ready += 1
	print("Player Connected: ", id, " (", players_ready, "/2)")
	
	if multiplayer.is_server():
		if players_ready == 1:  # Changed from MAX_PLAYERS to 1
			title.text = "Player connected! Starting game..."
			start_game.rpc()
		else:
			title.text = "Waiting for player... (" + str(players_ready) + "/2)"

func _on_peer_disconnected(id: int) -> void:
	players_ready = max(0, players_ready - 1)
	print("Player Disconnected: ", id)
	# Return to main menu
	main.show()
	reset_game()

func reset_game() -> void:
	title.text = "Online Battle Game"
	host_button.disabled = false
	join_button.disabled = false
	multiplayer.multiplayer_peer = null
	players_ready = 0

func _on_connected_to_server() -> void:
	print("Successfully connected to server!")
	title.text = "Connected! Waiting for game to start..."

func _on_connection_failed() -> void:
	print("Failed to connect to server!")
	reset_game()
	title.text = "Connection failed! Try again."

@rpc("authority", "call_local")
func start_game() -> void:
	if players_ready == 1:  # Changed from MAX_PLAYERS to 1
		var game = game_scene.instantiate()
		main.hide()
		add_child(game)
