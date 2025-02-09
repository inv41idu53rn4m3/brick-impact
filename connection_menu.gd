class_name ConnectionMenu
extends Control

@export var ip: String = ""
@export var nickname: String = ""

@onready var nick_field: LineEdit = $Nickname
@onready var ip_address: LineEdit = $IPAddress
@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton

signal host_requested(nickname: String)
signal join_requested(ip: String, nickname: String)

signal controls_requested()


func enable_input(enable: bool) -> void:
	nick_field.editable = enable
	ip_address.editable = enable
	host_button.disabled = !enable
	join_button.disabled = !enable


func _on_host_button_down() -> void:
	host_requested.emit(nick_field.text)


func _on_join_button_down() -> void:
	join_requested.emit(ip_address.text, nick_field.text)


func _on_controls_button_down() -> void:
	controls_requested.emit()


func _on_ip_address_text_changed(new_text: String) -> void:
	ip = new_text


func _on_nickname_text_changed(new_text: String) -> void:
	nickname = new_text
