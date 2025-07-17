extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dead: bool = false

@onready
var treat_checker: CollisionObject3D = $TreatChecker



func _ready() -> void:
	SignalBus.player_dead.connect(_on_player_dead)
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	var direction = 3.5 * Vector3(input_dir.x, 0.0, input_dir.y)
	velocity.x = direction.x
	velocity.z = direction.z
	move_and_slide()


func _on_treat_checker_area_entered(area: Area3D) -> void:
	SignalBus.treat_collected.emit(area)
	
func _on_player_dead() -> void:
	is_dead = true
	
