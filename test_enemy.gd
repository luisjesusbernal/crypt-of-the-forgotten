extends CharacterBody2D

const MOVE_SPEED = 90.0
const DETECTION_RANGE = 280.0
const ATTACK_RANGE = 75.0
const ATTACK_COOLDOWN = 0.7
const TURN_DELAY = .85
const HURT_DURATION = 0.67

var health = 3
var is_attacking = false
var has_dealt_damage = false
var attack_cooldown_left = 0.0
var facing_direction = 1.0
var turn_target_direction = 1.0
var turn_time_left = 0.0
var is_hurt = false
var hurt_time_left = 0.0
var is_dead = false

@onready var damage_cooldown: Timer = $DamageCooldown
@onready var player = get_tree().get_first_node_in_group("player")
@onready var skeleton_visual: AnimatedSprite2D = $SkeletonVisual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var damage_area: Area2D = $DamageArea
@onready var damage_area_collision: CollisionShape2D = $DamageArea/CollisionShape2D

func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Skeleton HP: ", health)

	if health <= 0:
		die()
		return

	# Cancelar cualquier ataque que estuviera haciendo.
	is_attacking = false
	has_dealt_damage = false

	# Entrar en estado de daño.
	is_hurt = true
	hurt_time_left = HURT_DURATION
	velocity.x = 0

	skeleton_visual.play("hurt")


func die() -> void:
	is_dead = true
	is_attacking = false
	is_hurt = false
	has_dealt_damage = false
	velocity = Vector2.ZERO

	# Ya no puede interactuar.
	collision_shape.set_deferred("disabled", true)
	damage_area.monitoring = false
	damage_area_collision.set_deferred("disabled", true)

	skeleton_visual.play("death")


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and damage_cooldown.is_stopped():
		if body.has_method("take_damage"):
			body.take_damage(1, global_position)
			damage_cooldown.start()

func _physics_process(delta: float) -> void:
	
	if is_dead:
		velocity.x = 0
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if attack_cooldown_left > 0:
		attack_cooldown_left -= delta

	var distance_to_player = global_position.distance_to(player.global_position)
	var direction = sign(player.global_position.x - global_position.x)

	# Mientras está herido, no puede caminar, atacar ni girarse.
	if is_hurt:
		velocity.x = 0
		hurt_time_left -= delta

		if hurt_time_left <= 0:
			is_hurt = false

		move_and_slide()
		return

	# Si está atacando, no puede girarse ni caminar.
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# Si el jugador pasa detrás del Skeleton, tarda un momento en reaccionar.
	if direction != 0 and direction != facing_direction:
		if turn_target_direction != direction:
			turn_target_direction = direction
			turn_time_left = TURN_DELAY

		if turn_time_left > 0:
			turn_time_left -= delta
			velocity.x = 0
			skeleton_visual.play("idle")
			move_and_slide()
			return

		# Terminó de reaccionar: ahora sí se da la vuelta.
		facing_direction = direction
		skeleton_visual.flip_h = facing_direction < 0

	else:
		turn_target_direction = facing_direction
		turn_time_left = 0.0

	# Atacar si está cerca.
	if distance_to_player <= ATTACK_RANGE:
		velocity.x = 0

		if attack_cooldown_left <= 0:
			is_attacking = true
			has_dealt_damage = false
			skeleton_visual.play("attack")
		else:
			skeleton_visual.play("idle")

	# Perseguir si está dentro del rango de detección.
	elif distance_to_player <= DETECTION_RANGE:
		velocity.x = facing_direction * MOVE_SPEED
		skeleton_visual.play("walk")

	# Quedarse quieto si el jugador está lejos.
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)
		skeleton_visual.play("idle")

	move_and_slide()


func _on_skeleton_visual_animation_finished() -> void:
	if skeleton_visual.animation == "attack":
		is_attacking = false
		attack_cooldown_left = ATTACK_COOLDOWN

	elif skeleton_visual.animation == "death":
		skeleton_visual.stop()
		skeleton_visual.frame = skeleton_visual.sprite_frames.get_frame_count("death") - 1
		set_physics_process(false)


func _on_skeleton_visual_frame_changed() -> void:
	if skeleton_visual == null:
		return
		
	if skeleton_visual.animation == "attack" and skeleton_visual.frame == 1 and not has_dealt_damage:
		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player <= ATTACK_RANGE and player.has_method("take_damage"):
			player.take_damage(1, global_position)
			has_dealt_damage = true
