extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum State { IDLE, WANDER, CHASE }
var state = State.WANDER

@export var wander_points: Array[Marker3D]
var current_wander_point_idx: int = 0

@onready var ray_cast = $RayCast3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var idle_timer: Timer = $Timer


var target: Node3D = null
var wander_speed: float = 1.5
var chase_speed: float = wander_speed * 1.2

func _ready() -> void:
	nav_agent.path_max_distance = 0.1
	nav_agent.target_desired_distance = 3

func _check_for_player() -> bool:
	var player: CharacterBody3D = get_tree().current_scene.find_child("Player", true, false)
	var max_distance := 3.0
	var view_angle := 45.0 
	var half_angle := view_angle / 2.0
	var player_radius := 0.5  #hardcoded for now better to check dynamically
	
	var offsets : Array[Vector3]= [
		Vector3.ZERO,                                
		Vector3(player_radius, 0, 0),                
		Vector3(-player_radius, 0, 0),               
		Vector3(0, player_radius, 0),                
		Vector3(0, -player_radius, 0)                
	]

	for offset in offsets:
		var point : Vector3 = player.global_position + offset
		var to_point := point - global_position
		var distance := to_point.length()
		if distance > max_distance:
			continue


		var forward := -global_transform.basis.z.normalized()
		var dir := to_point.normalized()
		var angle := rad_to_deg(acos(forward.dot(dir)))
		if angle > half_angle:
			continue
		
		var local_direction: Vector3 = ray_cast.to_local(ray_cast.global_position + to_point)
		ray_cast.target_position = local_direction
		ray_cast.force_raycast_update()

		if ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if collider == player:
				target = player
				nav_agent.set_target_position(player.global_position)
				if nav_agent.is_target_reachable():
					audio_player.play()
				return true

	return false

func _physics_process(delta: float) -> void:
	velocity.y -= gravity * delta

	match state:
		State.IDLE:
			if _check_for_player():
				state = State.CHASE
				idle_timer.stop()

		State.WANDER:
			if _check_for_player():
				state = State.CHASE
			else:
				var target_pos = wander_points[current_wander_point_idx].position
				nav_agent.set_target_position(target_pos)

				if not nav_agent.is_navigation_finished():
					var next_pos = nav_agent.get_next_path_position()
					var dir = (next_pos - global_position).normalized()
					velocity.x = dir.x * wander_speed
					velocity.z = dir.z * wander_speed
					look_at(next_pos)
				else:
					velocity.x = 0
					velocity.z = 0
					if wander_points[current_wander_point_idx].name.ends_with("_IDLE"):
						state = State.IDLE
						idle_timer.start()
					current_wander_point_idx = (current_wander_point_idx + 1) % wander_points.size()

		State.CHASE:
			var target_pos = target.get_global_transform_interpolated().origin
			nav_agent.set_target_position(target_pos)
			if  (nav_agent.is_target_reachable() == false): 
				state = State.WANDER
				
			
			var next_path_position: Vector3 = nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_path_position) * 2.0
			
			look_at(next_path_position)
		
			if (target.position - position).length() > 10.0:
				target = null
				state = State.WANDER
				
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		SignalBus.player_dead.emit()

func _on_timer_timeout() -> void:
	state = State.WANDER
