
extends CharacterBody2D
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var health: int = 3
var is_blue_form: bool = false
var bullet_scene = preload("uid://dtclgpudk4ih3")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $AnimatedSprite2D/Hitbox
@onready var hitbox_shape: CollisionShape2D = $AnimatedSprite2D/Hitbox/CollisionShape2D

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	add_to_group("player")
	
	#if animated_sprite == null:
	#	push_error("AnimatedSprite2D NOT FOUND! Check scene tree.")
	#animated_sprite.animation_finished.connect(_on_animation_finished)
	#hitbox.monitoring = false
	#add_to_group("player")
func get_anim_name(base: String) -> String:
	return base + ("_2" if is_blue_form else "")
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("form_change"):
		toggle_blue_form()
		
	if event.is_action_pressed("attack") and not is_attacking:
		is_attacking = true
		
		if is_blue_form:
			spawn_bullet()
		else:
			hitbox.monitoring = true
			hitbox.monitorable = true
			hitbox_shape.disabled = false
		var attack_base = "attack" if is_on_floor() else "attack_air"
		animated_sprite.play(get_anim_name(attack_base))
	
func play_attack_anim(type: String) -> void:
	var prefix = "blue_" if is_blue_form else ""
	if is_on_floor():
		animated_sprite.play(prefix + "attack")
	else:
		animated_sprite.play(prefix + "attack_air" if is_blue_form else "attack")
func toggle_blue_form() -> void:
	is_blue_form = !is_blue_form
	print("Switched to ", "Blue" if is_blue_form else "Base", " Form!")
	is_attacking = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	update_animation()
func _physics_process(delta: float) -> void:
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_attacking:
		move_and_slide()
		return
	#if is_attacking and is_on_floor():
		#is_attacking=false
		#hitbox.monitoring=false
		#update_animation()
# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
# Get the input direction and handle the movement/deceleration.

	var direction := Input.get_axis("move_left", "move_right")
#Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation()
	move_and_slide()
func update_animation() -> void:
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite.play(get_anim_name("run"))
		else:
			animated_sprite.play(get_anim_name("idle"))
	else:
		animated_sprite.play(get_anim_name("jump"))
func spawn_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position + Vector2(25 * (-1 if animated_sprite.flip_h else 1), -10)
	bullet.shoot_direction = -1 if animated_sprite.flip_h else 1
func _on_animation_finished() -> void:
	is_attacking = false
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	update_animation()
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var knockback_dir = (area.global_position - global_position).normalized()
		area.get_parent().take_damage(1, knockback_dir)
func take_damage(amount: int = 1) -> void:
	health -=amount
	print("Player HP: ", health)
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	animated_sprite.modulate = Color.WHITE
	if health <= 0:
		die()
func die() -> void:
	animated_sprite.play("die")
	set_physics_process(false)
