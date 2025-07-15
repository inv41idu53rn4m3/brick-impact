class_name MenuHandler
extends Node2D

@onready var connection_menu: ConnectionMenu = $ConnectionMenu
@onready var controls_menu: Control = $ControlsMenu
@onready var console: ConsoleMenu = $Console

var menu_active := true

func _on_connection_menu_controls_requested() -> void:
	connection_menu.visible = false
	controls_menu.visible = true

func _on_controls_menu_close_requested() -> void:
	connection_menu.visible = true
	controls_menu.visible = false

func _on_menu_visibility_changed() -> void:
	if not is_node_ready():
		return
	menu_active = connection_menu.visible or controls_menu.visible or console.visible
