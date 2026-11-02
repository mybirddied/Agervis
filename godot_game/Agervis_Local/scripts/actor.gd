class_name AgervisActor
extends RefCounted

var actor_id: String
var display_name: String
var role: String
var area: String
var room_id: = ""
var position: = Vector2.ZERO
var home_position: = Vector2.ZERO
var color: = Color.WHITE
var skin_color: = Color("#a96f50")
var hair_style: = "short"
var body_style: = "standard"
var hair_color: = Color("#17191b")
var face_style: = "angular"
var eye_style: = "steady"
var stature: = "average"
var outfit_style: = "jacket"
var surreal_trait: = "none"
var accessory: = "none"
var facial_hair_style: = "none"
var facial_hair_color: = Color("#3b2a23")
var render_scale: = 1.16
var health: = 100.0
var max_health: = 100.0
var hostile: = false
var downed: = false
var downed_time: = 0.0
var removed: = false
var restrained: = false
var restrained_time: = 0.0
var cash: = 0
var attack_cooldown: = 0.0
var ai_state: = "idle"
var target_x: = 0.0
var roam_points: Array[Vector2] = []
var roam_index: = 0
var roam_wait_timer: = 0.0
var move_speed: = 85.0
var directly_attacked_by_player: = false
var customer_cycle_elapsed: = 0.0
var customer_cycle_offset: = 0.0
var customer_cycle_moving: = false
var trusted: = false
var mark_time: = 0.0
var maimed: = false
var stress: = 0.0
var witnessed_violence: = false
var stress_snap_threshold: = 100.0
var was_shot: = false
var witnessed_gun_execution: = false
var dangerous_reputation: = 0.0


var knockback_active: = false
var knockback_velocity: = Vector2.ZERO
var knockdown: = false
var knockdown_timer: = 0.0
var knockdown_max_duration: = 0.0
var last_knockback_distance: = 0.0
var posture: = 0.0
var max_posture: = 100.0
var fighting_level: = 0

func _init(
	new_id: String, 
	new_name: String, 
	new_role: String, 
	new_area: String, 
	new_position: Vector2, 
	new_color: Color
) -> void :
	actor_id = new_id
	display_name = new_name
	role = new_role
	area = new_area
	position = new_position
	home_position = new_position
	color = new_color
	target_x = new_position.x

func distance_to(point: Vector2) -> float:
	return position.distance_to(point)

func take_damage(amount: float) -> bool:
	if downed or removed:
		return false
	health = maxf(0.0, health - amount)
	if health <= 0.0:
		downed = true
		downed_time = 0.0
		hostile = false
		return true
	return false

func revive(health_amount: float = 35.0) -> void :
	downed = false
	downed_time = 0.0
	restrained = false
	restrained_time = 0.0
	health = clampf(health_amount, 1.0, max_health)
