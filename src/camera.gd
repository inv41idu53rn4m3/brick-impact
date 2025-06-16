class_name CameraSnappable
extends Camera2D

@onready var root: GameManager = $".."
@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D

func snap() -> void:
	if root.is_dedicated_server:
		return
	
	force_update_transform()
	remote_transform.force_update_transform()
	align()
	reset_smoothing()
	reset_physics_interpolation()
	root.menu.reset_physics_interpolation()
