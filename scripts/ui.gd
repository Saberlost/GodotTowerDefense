extends CanvasLayer

signal start_wave_pressed
signal tower_selected(tower_type)
signal blocker_selected

@onready var gold_label = $MarginContainer/VBoxContainer/StatsContainer/GoldLabel
@onready var lives_label = $MarginContainer/VBoxContainer/StatsContainer/LivesLabel
@onready var wave_label = $MarginContainer/VBoxContainer/StatsContainer/WaveLabel
@onready var start_wave_button = $MarginContainer/VBoxContainer/StartWaveButton

var message_label: Label
var message_timer: Timer

func _ready():
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	
	# Connect tower buttons
	$MarginContainer/VBoxContainer/TowerButtons/ArcherButton.pressed.connect(func(): tower_selected.emit("archer_tower"))
	$MarginContainer/VBoxContainer/TowerButtons/MageButton.pressed.connect(func(): tower_selected.emit("mage_tower"))
	$MarginContainer/VBoxContainer/TowerButtons/CannonButton.pressed.connect(func(): tower_selected.emit("cannon_tower"))
	$MarginContainer/VBoxContainer/TowerButtons/BlockerButton.pressed.connect(func(): blocker_selected.emit())
	
	message_label = Label.new()
	message_label.visible = false
	message_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
	$MarginContainer/VBoxContainer.add_child(message_label)
	
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 1.5
	message_timer.timeout.connect(func(): message_label.visible = false)
	add_child(message_timer)

func update_stats(gold: int, lives: int, wave: int):
	gold_label.text = "Gold: " + str(gold)
	lives_label.text = "Lives: " + str(lives)
	wave_label.text = "Wave: " + str(wave)

func _on_start_wave_pressed():
	start_wave_pressed.emit()

func show_message(text: String, color: Color = Color(1.0, 0.4, 0.4, 1.0), duration: float = 1.5):
	if not message_label or not message_timer:
		return
	
	message_label.text = text
	message_label.modulate = color
	message_label.visible = true
	message_timer.wait_time = duration
	message_timer.start()
