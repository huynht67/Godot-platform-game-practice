extends CharacterBody2D


const SPEED = 60
var direction = 1
var health: int = 3
var max_health: int = 3
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Called when the node enters the scene tree for the first time.
@export var damage_flash_color: Color = Color.RED
var original_modulate: Color

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_floor: RayCast2D = $RayCastFloor
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var killzone: Area2D = $Killzone
@onready var hit_sfx: AudioStreamPlayer2D = $HitSfx

@onready var death_sfx: AudioStreamPlayer2D = $DeathSfx



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var knockback_dir = (global_position - area.global_position).normalized()
		take_damage(1, knockback_dir)


func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
	
func _ready() -> void:
	original_modulate = animated_sprite.modulate
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	killzone.body_entered.connect(_on_killzone_body_entered)
	
func _on_killzone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Wall detection (your existing rays)
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
		if ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false
	
	ray_cast_floor.target_position.x = 25 * direction
	ray_cast_floor.force_raycast_update()
	
	if not ray_cast_floor.is_colliding():
		direction *= -1
		animated_sprite.flip_h = not animated_sprite.flip_h
	velocity.x = direction * SPEED
	#if is_on_floor():
		#animated_sprite.play("idle")
	#else:
		#animated_sprite.play("jump")
		
func take_damage(damage: int = 1, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	hit_sfx.stop()
	hit_sfx.play()
	health -= damage
	print("Enemy HP: ", health)
	animated_sprite.modulate = damage_flash_color
	velocity = knockback_dir * 120.0
	move_and_slide()
	await get_tree().create_timer(0.15).timeout
	animated_sprite.modulate = original_modulate
	if health <= 0:
		die()
		return
		
func die() -> void:
	death_sfx.play()
	animated_sprite.play("die")
	set_physics_process(false)
	hurtbox.monitoring = false
	killzone.monitoring = false
	$CollisionShape2D.disabled = true
	await animated_sprite.animation_finished
	queue_free()
	await death_sfx.finished
	queue_free()
	
