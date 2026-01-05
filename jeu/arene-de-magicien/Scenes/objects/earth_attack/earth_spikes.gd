extends Node3D

@export var zone_length : float = 10.0
@onready var rocks_particles = %RocksParticles
@onready var small_rocks = %SmallRocks
@onready var dust_particles = %DustParticles
@onready var hit_zone = %HitZone
@onready var hit_zone_collision = %HitZoneCollision

signal finished

func _ready():
	hit_zone.position.z = 0
	var t = create_tween()
	t.tween_property(hit_zone, "position:z", zone_length, 2.0)
	t.tween_callback(hit_zone_collision.set_deferred.bind("disabled", true))
	
	rocks_particles.emitting = true
	dust_particles.emitting = true
	get_tree().create_timer(5).timeout.connect(func():
		finished.emit()
		queue_free())


func init(owner: Node, dir: Vector3) -> void:
	#owner_player = owner
	look_at(-dir)
