extends Line2D
# this section is for creating visual range circle around the predators
const CENTER = Vector2.ZERO
const COLOR = Color(0.69, 0.19, 0.38, 1 ) #colour of the circle
func _process(delta):
	update()

func _draw():
	draw_arc(CENTER, 100, deg2rad(0), deg2rad(360), 100, COLOR) #draw the circle
