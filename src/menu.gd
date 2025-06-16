class_name MenuHandler
extends Node2D

@onready var connection_menu: ConnectionMenu = $ConnectionMenu
@onready var controls_menu: Control = $ControlsMenu


func _on_connection_menu_controls_requested() -> void:
	connection_menu.visible = false
	controls_menu.visible = true

func _on_controls_menu_close_requested() -> void:
	connection_menu.visible = true
	controls_menu.visible = false
