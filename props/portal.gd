extends Area3D


func _on_body_entered(body: Node3D) -> void:
	SignalBus.portal_reached.emit() # Replace with function body.
