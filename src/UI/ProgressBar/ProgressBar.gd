extends ProgressBar
var timer:Timer
signal bar_filled

var text:Label
var stp = 1
export (Color,RGBA) var red
export (Color,RGBA) var yellow

func _ready():
	timer = $Timer
	text = $Text
	text.visible = false



func start(var time = 0.06,var _stp = 1):
	stp = _stp
	visible = true
	value = 0
	timer.start(time)

func stop():
	value = 0
	timer.stop()
func pause()->float:
	timer.stop()
	return value
func to_step(var _stp:float = 1):
	visible = true
	if value == 100:
		value = 0
	value = value+(_stp)


func _on_ProgressBar_value_changed(value):
	if value >= 100:
		#visible = false
		stop()
		
		visible = true
		value = 0
		emit_signal("bar_filled")



func _on_Timer_timeout():
	value = value+stp
	pass # Replace with function body.

