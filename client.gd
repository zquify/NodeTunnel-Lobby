extends Control

const RELAY := "us-east.nodetunnel.io:8080"
const APP_ID := "pvaffvacbfy6i8t"

var peer: NodeTunnelPeer

@onready var room_code_input: LineEdit = $VBoxContainer/RoomCode
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var status_label: Label = $VBoxContainer/Status


func _ready() -> void:
	join_button.pressed.connect(_on_join_pressed)

	peer = NodeTunnelPeer.new()

	peer.error.connect(_on_error)
	peer.forced_disconnect.connect(_on_forced_disconnect)
	peer.authenticated.connect(_on_authenticated)
	peer.room_connected.connect(_on_room_connected)

	status_label.text = "Connecting to NodeTunnel..."

	print("Connecting to NodeTunnel relay...")

	var err := peer.connect_to_relay(RELAY, APP_ID)

	print("connect_to_relay() returned: ", err)

	if err != OK:
		status_label.text = "Failed to connect to relay."
		return

	multiplayer.multiplayer_peer = peer

	print("Peer assigned to multiplayer.")
	status_label.text = "Connecting..."


func _on_authenticated() -> void:
	print("AUTHENTICATED!")

	status_label.text = "Connected! Enter the room code."

	room_code_input.editable = true
	join_button.disabled = false

	room_code_input.grab_focus()


func _on_join_pressed() -> void:
	var room_code := room_code_input.text.strip_edges()

	if room_code.is_empty():
		status_label.text = "Enter a room code."
		return

	print("================================")
	print("JOINING ROOM: ", room_code)
	print("================================")

	status_label.text = "Joining room..."

	join_button.disabled = true
	room_code_input.editable = false

	peer.join_room(room_code)


func _on_room_connected() -> void:
	print("================================")
	print("ROOM JOINED!")
	print("ROOM CODE: ", peer.room_id)
	print("================================")

	status_label.text = "JOINED! Room: " + str(peer.room_id)


func _on_error(message: String) -> void:
	print("================================")
	print("NODETUNNEL ERROR:")
	print(message)
	print("================================")

	status_label.text = "Error: " + message

	join_button.disabled = false
	room_code_input.editable = true


func _on_forced_disconnect() -> void:
	print("NODETUNNEL FORCED DISCONNECT")

	status_label.text = "Disconnected."
