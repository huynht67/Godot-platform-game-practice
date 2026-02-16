extends Area2D

@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D

var shoot_direction: int = 1
func _ready() -> void:
	timer.timeout.connect(queue_free)  # Auto-delete after 2s
	area_entered.connect(_on_area_entered)
	sprite.flip_h = (shoot_direction < 0)
	#if shoot_direction < 0:
		#sprite.flip_h=true

func _physics_process(delta: float) -> void:
	# Constant forward speed
	position.x += 400 * delta * shoot_direction  # Uses direction from player

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		area.get_parent().take_damage(1)  # Same as melee
	queue_free()  # Destroy on hit
