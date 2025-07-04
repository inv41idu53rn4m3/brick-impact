class_name ConnectionMenu
extends Control

@onready var nick_field: LineEdit = $MarginContainer/VBoxContainer/Nickname
@onready var ip_address: LineEdit = $MarginContainer/VBoxContainer/IPAddress
@onready var host_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/HostButton
@onready var join_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/JoinButton

signal host_requested(nickname: String)
signal join_requested(ip: String, nickname: String)
signal controls_requested()

var ip: String = ""
var nickname: String = ""


func enable_input(enable: bool) -> void:
	nick_field.editable = enable
	ip_address.editable = enable
	host_button.disabled = !enable
	join_button.disabled = !enable


func _on_host_button_down() -> void:
	host_requested.emit(nickname)

func _on_join_button_down() -> void:
	join_requested.emit(ip, nickname)

func _on_controls_button_down() -> void:
	controls_requested.emit()


func _on_ip_address_text_changed(new_text: String) -> void:
	ip = new_text

func _on_nickname_text_changed(new_text: String) -> void:
	nickname = new_text
