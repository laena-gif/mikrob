extends Node3D

var num_treats_left : int = -1
var is_pobeda = false

@onready
var label_num_treats_left : Label = $UI/LabelCandiesLeft

@onready
var all_treats : Node3D = $Treats

@onready
var door : Node3D = $Level/Doors/Door

@onready
var pobeda_label : Label = $UI/Label2

@onready
var dead_label : Label = $UI/Label3



func _ready() -> void:
	num_treats_left = all_treats.get_child_count()
	_update_label()
	SignalBus.treat_collected.connect(_on_treat_collected)
	SignalBus.portal_reached.connect(_on_portal_reached)
	SignalBus.player_dead.connect(_on_player_dead)
	pass
	

func _update_label() -> void:
	label_num_treats_left.text = "%d" % num_treats_left

func _on_treat_collected() -> void:
	num_treats_left -= 1
	_update_label()
	if (num_treats_left == 0 and is_pobeda == false) : 
		door.queue_free()
		is_pobeda = true
		
func _on_portal_reached() -> void:
	pobeda_label.position =  (Vector2(get_viewport().size) - pobeda_label.size) / 2
	pobeda_label.visible = true
	
func _on_player_dead() -> void:
	dead_label.position =  (Vector2(get_viewport().size) - dead_label.size) / 2
	dead_label.visible = true
	
