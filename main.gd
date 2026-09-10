extends Control

const RELAY := "us-east.nodetunnel.io:8080"
const APP_ID := "pvaffvacbfy6i8t"

var peer: NodeTunnelPeer

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var room_code: LineEdit = $VBoxContainer/RoomCode
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var status: Label = $VBoxContainer/Status


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

	# Start with the controls disabled until NodeTunnel authenticates.
	host_button.disabled = true
	join_button.disabled = true

	status.text = "Connecting to NodeTunnel..."

	peer = NodeTunnelPeer.new()

	peer.error.connect(_on_error)
	peer.forced_disconnect.connect(_on_forced_disconnect)
	peer.authenticated.connect(_on_authenticated)
	peer.room_connected.connect(_on_room_connected)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("Connecting to NodeTunnel relay...")

	var err := peer.connect_to_relay(RELAY, APP_ID)

	print("connect_to_relay() returned: ", err)

	if err != OK:
		status.text = "Failed to connect to NodeTunnel."
		return

	multiplayer.multiplayer_peer = peer

	print("Peer assigned to multiplayer.")


func _on_authenticated() -> void:
	print("================================")
	print("AUTHENTICATED!")
	print("================================")

	status.text = "Connected to NodeTunnel."

	host_button.disabled = false
	join_button.disabled = false
	room_code.editable = true


func _on_host_pressed() -> void:
	print("================================")
	print("HOSTING GAME")
	print("================================")

	status.text = "Creating room..."

	host_button.disabled = true
	join_button.disabled = true
	room_code.editable = false

	var err := peer.host_room(true, "UNL Pitch Test")

	print("host_room() returned: ", err)

	if err != OK:
		status.text = "Failed to create room."
		host_button.disabled = false
		join_button.disabled = false
		room_code.editable = true


func _on_join_pressed() -> void:
	var code := room_code.text.strip_edges()

	if code.is_empty():
		status.text = "Enter a room code first."
		return

	print("================================")
	print("JOINING ROOM: ", code)
	print("================================")

	status.text = "Joining room..."

	host_button.disabled = true
	join_button.disabled = true
	room_code.editable = false

	var err := peer.join_room(code)

	print("join_room() returned: ", err)

	if err != OK:
		status.text = "Failed to join room."
		host_button.disabled = false
		join_button.disabled = false
		room_code.editable = true


func _on_room_connected() -> void:
	print("================================")
	print("ROOM CONNECTED!")
	print("ROOM CODE: ", peer.room_id)
	print("================================")

	room_code.text = peer.room_id

	# We don't know whether this instance is the host or client
	# purely from this signal, so just report that the room connection worked.
	status.text = "Connected to room: " + str(peer.room_id)


func _on_peer_connected(id: int) -> void:
	print("================================")
	print("PLAYER JOINED!")
	print("Peer ID: ", id)
	print("================================")


func _on_peer_disconnected(id: int) -> void:
	print("================================")
	print("PLAYER DISCONNECTED!")
	print("Peer ID: ", id)
	print("================================")


func _on_error(message: String) -> void:
	print("================================")
	print("NODETUNNEL ERROR:")
	print(message)
	print("================================")

	status.text = "Error: " + message

	host_button.disabled = false
	join_button.disabled = false
	room_code.editable = true


func _on_forced_disconnect() -> void:
	print("================================")
	print("NODETUNNEL FORCED DISCONNECT")
	print("================================")

	status.text = "Disconnected from NodeTunnel."

	host_button.disabled = true
	join_button.disabled = true
