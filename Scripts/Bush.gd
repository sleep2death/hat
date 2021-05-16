extends StaticBody2D

onready var hb = $HurtBox
onready var particles = $BushParticles

var destroying = false;

func _ready():
	hb.connect("area_entered", self, "on_area_entered")

func on_area_entered(_hb: HitBox):
	destroy_self()

func destroy_self():
	hb.disconnect("area_entered", self, "on_area_entered")
	$Sprite.queue_free()
	$DropShadowStatic.queue_free()
	
	particles.emitting = true
	destroying = true
	# queue_free()
func _physics_process(_delta):
	if destroying && particles.emitting == false:
		queue_free()
