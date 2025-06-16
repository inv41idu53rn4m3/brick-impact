class_name GameManager
extends Node

@onready var camera: CameraSnappable = $Camera2D

# Haha funny
const PORT = 42069

var menu: MenuHandler
var is_dedicated_server: bool = false

class PlayerRecord:
	var nickname: String
	var node: Player
	func _init(nickname_in: String, node_in: Player) -> void:
		nickname = nickname_in
		node = node_in

var players := {} # Dictionary[int, PlayerRecord]


func _init() -> void:
	if OS.has_feature("dedicated_server") \
			or DisplayServer.get_name() == "headless" \
			or "--server" in OS.get_cmdline_user_args():
		is_dedicated_server = true
	else:
		Storage.load_controls()

func _ready() -> void:
	if not is_dedicated_server:
		get_viewport().get_window().close_requested.connect(quit)
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.server_disconnected.connect(server_disconnected)
	
	if not is_dedicated_server:
		menu = preload("res://scenes/menu.tscn").instantiate()
		self.add_child(menu)
		camera.remote_transform.remote_path = menu.get_path()
		menu.connection_menu.host_requested.connect(host_game)
		menu.connection_menu.join_requested.connect(join_game)
	
	# Default peer makes multiplayer.has_multiplayer_peer() useless
	multiplayer.multiplayer_peer = null # Death it is.
	
	if is_dedicated_server:
		host_game("")

func _exit_tree() -> void:
	quit()


@rpc("any_peer", "reliable") func spawn_player(id: int, nickname: String, skin: String) -> void:
	# Spawn the player node
	var player: Player = preload("res://scenes/player.tscn").instantiate()
	player.position = ($SpawnPoint as Node2D).position
	player.control_id = id
	player.nickname = nickname
	player.skin = skin
	player.name = nickname + "_" + str(id)
	$Players.add_child(player)
	
	# Keep track of connected players
	players[id] = PlayerRecord.new(nickname, player)
	
	# Focus camera on the controlled character
	if multiplayer.get_unique_id() == id:
		camera.reparent(player, false)
		camera.position = Vector2.ZERO
		camera.snap()
	
	# Broadcast player spawn to clients
	if multiplayer.is_server():
		spawn_player.rpc(id, nickname, skin)

func destroy_player(player_record: PlayerRecord) -> void:
	# Tranquilize the player to appease the engine
	player_record.node.set_physics_process(false)
	player_record.node.set_process(false)
	# Actually remove player
	player_record.node.queue_free()

func reset_scene() -> void:
	# Reset camera
	var temp_pos := camera.get_screen_center_position()
	camera.reparent(self)
	camera.position = temp_pos
	camera.snap()
	# Remove all player nodes
	for player: int in players:
		var player_record: PlayerRecord = players[player]
		destroy_player(player_record)
	players.clear()
	# Reset connection/menu
	multiplayer.multiplayer_peer = null
	menu.connection_menu.visible = true
	menu.connection_menu.enable_input(true)

func quit() -> void:
	if not is_dedicated_server:
		Storage.save_controls()
	get_tree().quit()

func host_game(nickname: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, 128, 0, 1000000, 1000000)
	if error != OK:
		return
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	
	if not is_dedicated_server:
		spawn_player(1, nickname, Storage.load_player_skin())
		menu.connection_menu.visible = false

func join_game(ip: String, _nickname: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip, PORT)
	if error != OK:
		return
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	
	menu.connection_menu.enable_input(false)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		if multiplayer.has_multiplayer_peer():
			# Disconnect
			multiplayer.multiplayer_peer.close()
			reset_scene()
		else:
			# or simply quit game
			quit()


### Networking related callbacks ###
func peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	
	for player: int in players:
		spawn_player.rpc_id(id, player, players[player].nickname, players[player].node.skin)

func peer_disconnected(id: int) -> void:
	var record: PlayerRecord = players[id]
	destroy_player(record)
	players.erase(id)

func connected_to_server() -> void:
	spawn_player.rpc(multiplayer.get_unique_id(), menu.connection_menu.nickname, Storage.load_player_skin())
	menu.connection_menu.visible = false

func connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	menu.connection_menu.enable_input(true)

func server_disconnected() -> void:
	reset_scene()
