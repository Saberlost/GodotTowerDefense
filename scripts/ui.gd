extends CanvasLayer

signal start_wave_pressed
signal tower_selected(tower_type)
signal blocker_selected

@onready var gold_label = $MarginContainer/VBoxContainer/StatsContainer/GoldLabel
@onready var lives_label = $MarginContainer/VBoxContainer/StatsContainer/LivesLabel
@onready var wave_label = $MarginContainer/VBoxContainer/StatsContainer/WaveLabel
@onready var start_wave_button = $MarginContainer/VBoxContainer/StartWaveButton

func _ready():
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	
	# Connect tower buttons
	$MarginContainer/VBoxContainer/TowerButtons/ArcherButton.pressed.connect(func(): tower_selected.emit("archer_tower"))
	$MarginContainer/VBoxContainer/TowerButtons/MageButton.pressed.connect(func(): tower_selected.emit("mage_tower"))
	$MarginContainer/VBoxContainer/TowerButtons/CannonButton.pressed.connect(func(): tower_selected.emit("cannon_tower"))
	$MarginContainer/VBoxContainer/TowerButtons/BlockerButton.pressed.connect(func(): blocker_selected.emit())

func update_stats(gold: int, lives: int, wave: int):
	gold_label.text = "Gold: " + str(gold)
	lives_label.text = "Lives: " + str(lives)
	wave_label.text = "Wave: " + str(wave)

func _on_start_wave_pressed():
	start_wave_pressed.emit()
