extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -470.0

const DASH_SPEED = 850.0
const DASH_DURATION = 0.18
const DASH_COOLDOWN = 0.45
const FIREBALL_SCENE = preload("res://fireball.tscn")
const FIREBALL_MANA_COST = 20.0
const MANA_REGEN_RATE = 15.0
const KNOCKBACK_FORCE = 450.0
const KNOCKBACK_UP_FORCE = 220.0
const HURT_DURATION = 0.5
const KNOCKBACK_DECELERATION = 900.0
const ENEMY_SLIDE_SPEED = 240.0
const ENEMY_SLIDE_DURATION = 0.18

const MAX_JUMPS = 2

var dash_time_left = 0.0
var facing_direction = 1.0
var dash_cooldown_left = 0.0
var is_attacking = false

var max_health = 3
var health = 3

var max_mana = 100.0
var mana = 100.0

var is_hurt = false
var hurt_time_left = 0.0

var is_dead = false

var enemy_slide_time_left = 0.0
var enemy_slide_direction = 0.0

var jumps_left = MAX_JUMPS

@onready var sword_collision: CollisionShape2D = $SwordHitbox/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var sword_hitbox: Area2D = $SwordHitbox
@onready var player_visual: AnimatedSprite2D = $PlayerVisual
@onready var fireball_spawn: Marker2D = $FireballSpawn

func _ready() -> void:
	player_visual.play("idle")
	
func _physics_process(delta: float) -> void:
	# Gravedad.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Regenerar maná.
	if mana < max_mana:
		mana = min(mana + MANA_REGEN_RATE * delta, max_mana)

	# Cooldown del dash.
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta

	# Duración del estado de daño.
	if is_hurt:
		hurt_time_left -= delta

		if hurt_time_left <= 0:
			is_hurt = false
			player_visual.modulate = Color.WHITE
			
	# Dirección horizontal.
	var direction := Input.get_axis("move_left", "move_right")

	# Recuperar los dos saltos al tocar el suelo.
	if is_on_floor():
		jumps_left = MAX_JUMPS

	# Salto y doble salto.
	if Input.is_action_just_pressed("jump") and jumps_left > 0 and not is_hurt:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	# Animaciones normales.
	if not is_attacking and not is_hurt:
		if dash_time_left > 0:
			player_visual.play("dash")
		elif not is_on_floor():
			player_visual.play("jump")
		elif direction != 0:
			player_visual.play("walk")
		else:
			player_visual.play("idle")

	# Actualizar dirección solamente si tenemos control.
	if direction != 0 and not is_hurt:
		facing_direction = direction
		player_visual.flip_h = direction < 0
		sword_hitbox.position.x = 55.0 * facing_direction
		fireball_spawn.position.x = 55.0 * facing_direction

	# Activar dash.
	if Input.is_action_just_pressed("dash") and dash_time_left <= 0 and dash_cooldown_left <= 0 and not is_hurt:
		dash_time_left = DASH_DURATION
		dash_cooldown_left = DASH_COOLDOWN

	# Movimiento horizontal.
	if is_hurt:
	# El golpe comienza fuerte, pero pierde velocidad gradualmente.
		velocity.x = move_toward(
			velocity.x,
			0,
			KNOCKBACK_DECELERATION * delta
		)

	elif dash_time_left > 0:
		dash_time_left -= delta
		velocity.x = facing_direction * DASH_SPEED

	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Ataque con espada.
	if Input.is_action_just_pressed("attack") and attack_timer.is_stopped() and not is_attacking and not is_hurt:
		is_attacking = true
		player_visual.play("attack")
		sword_collision.set_deferred("disabled", false)
		attack_timer.start()
	
	
	# Lanzar bola de fuego.
	if Input.is_action_just_pressed("magic") and mana >= FIREBALL_MANA_COST and not is_hurt:
		mana -= FIREBALL_MANA_COST

		var fireball = FIREBALL_SCENE.instantiate()
		get_tree().current_scene.add_child(fireball)
		fireball.global_position = fireball_spawn.global_position
		fireball.direction = facing_direction

	# Forzar el resbalón cuando estamos encima de un enemigo.
	if enemy_slide_time_left > 0:
		enemy_slide_time_left -= delta

		if not is_hurt and dash_time_left <= 0:
			velocity.x = enemy_slide_direction * ENEMY_SLIDE_SPEED
		
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider != null and collider.is_in_group("enemy"):
			if collision.get_normal().y < -0.5:
				enemy_slide_direction = sign(global_position.x - collider.global_position.x)

				if enemy_slide_direction == 0:
					enemy_slide_direction = facing_direction

				enemy_slide_time_left = ENEMY_SLIDE_DURATION

func _on_attack_timer_timeout() -> void:
	sword_collision.set_deferred("disabled", true)

func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body.has_method("take_damage"):
		body.take_damage(1)


func _on_player_visual_animation_finished() -> void:
	if player_visual.animation == "attack":
		is_attacking = false

	elif player_visual.animation == "death":
		var hud = get_node("../HUD")
		hud.show_death_screen()

func take_damage(amount: int, source_position: Vector2) -> void:
	if is_dead:
		return
	health -= amount
	health = max(health, 0)
	
	# Cancelar cualquier ataque que estuviera en curso.
	is_attacking = false
	sword_collision.set_deferred("disabled", true)
	attack_timer.stop()
	
	var knockback_direction = sign(global_position.x - source_position.x)

	if knockback_direction == 0:
		knockback_direction = -facing_direction

	velocity.x = knockback_direction * KNOCKBACK_FORCE
	velocity.y = -KNOCKBACK_UP_FORCE
	
	is_hurt = true
	dash_time_left = 0.0
	hurt_time_left = HURT_DURATION
	
	player_visual.play("hurt")
	player_visual.modulate = Color(1.0, 0.35, 0.35)
	
	print("Vida del jugador: ", health)
	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	player_visual.modulate = Color.WHITE
	player_visual.play("death")

	set_physics_process(false)
