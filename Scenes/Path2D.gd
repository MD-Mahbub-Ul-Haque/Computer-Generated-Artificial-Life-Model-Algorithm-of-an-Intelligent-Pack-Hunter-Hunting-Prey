extends Path2D
 
var timer = 0
export var spawnTime = 5
 
var follower = preload("res://Scenes/Boid.tscn")
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer = timer + delta
 
	if (timer > spawnTime):
		var newFollower = follower.instance()
		add_child(newFollower)
		timer = 0
