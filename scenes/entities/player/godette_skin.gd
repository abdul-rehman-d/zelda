extends Node3D

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine = $AnimationTree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = $AnimationTree.get_tree_root().get_node("ExtraAnimation")
@onready var second_attack_timer: Timer = $SecondAttackTimer

@onready var sword: Node3D = %Sword
@onready var wand: Node3D = %Wand

var is_attacking := false
var squash_and_strech := 1.0:
	set(value):
		squash_and_strech = value
		var negative = 1.0 + (1.0 - squash_and_strech)
		scale = Vector3(negative, squash_and_strech, negative)

const HIT_ANIMATION = "Hit_A"
const SPELL_ANIMATION = "Spellcast_Shoot"

func set_move_state(state: String) -> void:
	move_state_machine.travel(state)


func play_attack_animation() -> void:
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	attack_state_machine.travel("Slice" if $SecondAttackTimer.time_left else "Chop")


func play_spell_animation() -> void:
	if not is_attacking:
		extra_animation.animation = SPELL_ANIMATION
		$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func do_defend(forward: bool) -> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)


func hit() -> void:
	extra_animation.animation = HIT_ANIMATION
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	is_attacking = false


func _defend_change(value: float) -> void:
	$AnimationTree.set("parameters/ShieldBlend/blend_amount", value)


func _attack_toggle(value: bool):
	is_attacking = value
