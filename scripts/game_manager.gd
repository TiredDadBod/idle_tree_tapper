extends Node2D

# Amount of taps entire game
var totalTaps: int = 0
# Variable for spendable taps
var availableTaps: int = 0
# Amount of taps for current tree cycle
var currentTreeTaps: int = 0
# Amount of time passed with game closed
var idleTimePassed: float = 0.0
# Initial tap requirements for first tree
const baseStageTaps: Array[int] = [
							100, 110, 121, 133,
							146, 161, 177, 195,
							214, 236, 259, 285,
							314, 345, 380, 418
							]
# Iterater to help cycle through Array
var currentTreeStage: int = 0
# Variable to track taps needed for next stage
var currentRequiredTaps = baseStageTaps[currentTreeStage]
# Amount of fully completed Trees
var totalTrees: int = 0
# Variable for progress bar to reset to 0 each stage
var previousRequiredTaps: int = 0
# How many passive animals owned, resets at prestige
var passiveTapAnimals: Dictionary = {
									"squirrel": 0, 	# 1 t/s
									"racoon": 0, 	# 5 t/s
									"fox": 0, 		# 10 t/s
									"deer": 0 , 	# 50 t/s
									"bear": 0 		# 100 t/s
									}
# How many store animals bought, does NOT reset at prestige
var passiveStoreAnimals: Dictionary = {
									"squirrel": 0, 	# 1 t/s
									"racoon": 0, 		# 5 t/s
									"fox": 0, 		# 10 t/s
									"deer": 0 , 		# 50 t/s
									"bear": 0 		# 100 t/s
									}
# Rates and costs for animals
var passiveAnimalRates: Dictionary = {
									"squirrel": {"rate": 1, "baseCost": 500},	# 1 t/s
									"racoon": {"rate": 5, "baseCost": 1000},	# 5 t/s
									"fox": {"rate": 10, "baseCost": 2000},		# 10 t/s
									"deer": {"rate": 50, "baseCost": 5000},		# 50 t/s
									"bear": {"rate": 100, "baseCost": 10000}, 	# 100 t/s
									}
# Increase in cost when new animals purchased
const costMultiplier: float = 1.15
# Variable to account for passiveTapAnimal sum
var passiveTapsPerSecond: int = 0

@onready var tap_count_label: Label = %TapCountLabel
@onready var tree_stage_label: Label = %TreeStageLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var total_tap_label: Label = %TotalTapLabel
@onready var total_tree_label: Label = %TotalTreeLabel
@onready var tree_visual: ColorRect = %TreeVisual
@onready var available_taps: Label = %AvailableTaps
@onready var menus: Control = $Menus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if menus != null and menus.has_method("setup_ui"):
		menus.setup_ui(self)
	_updateUI()
	_calculatePassiveTaps()
	
func _process(delta: float) -> void:
	# Test inputs for speedier testing
	if Input.is_action_pressed("ui_accept"):
		_processTap()
	if Input.is_action_just_pressed("ui_down"):
		buyAnimal("squirrel")

func _on_tap_button_pressed() -> void:
	_processTap()
	
func _on_touch_button_pressed() -> void:
	_processTap()
	
func _processTap() -> void:
	availableTaps += 1
	totalTaps += 1
	currentTreeTaps += 1
	_newStage()
	_updateUI()

func _newStage() -> void:
	while currentTreeTaps >= currentRequiredTaps:
		if currentTreeStage >= 15:
			_newTree()
		else:
			previousRequiredTaps = currentRequiredTaps
			currentTreeStage += 1
			currentRequiredTaps = int(baseStageTaps[currentTreeStage] * pow(1.1, totalTrees))

func _newTree() -> void:
	previousRequiredTaps = 0
	currentTreeTaps = 0
	currentTreeStage = 0
	totalTrees += 1
	currentRequiredTaps = int(baseStageTaps[currentTreeStage] * pow(1.1, totalTrees))

func _updateUI() -> void:
	# Update Labels
	%TotalTapLabel.text = "Total Taps:\n" + str(totalTaps)
	%AvailableTaps.text = "Available Taps:\n" + str(availableTaps)
	%TapCountLabel.text = "Current Tree Taps:\n" + str(currentTreeTaps)
	%TreeStageLabel.text = "Tree Stage:\n" + str(currentTreeStage + 1)
	%TotalTreeLabel.text = "Total Trees:\n" + str(totalTrees)
	# Update progress bar
	%ProgressBar.min_value = previousRequiredTaps
	%ProgressBar.value = currentTreeTaps
	%ProgressBar.max_value = currentRequiredTaps
	# Update tree visual color
	_updateTreeVisual()
	
	if menus != null and menus.has_method("refreshUI"):
		menus.refreshUI()

func _updateTreeVisual() -> void:
	# Sets progress from 0 - 15
	var progress_ratio: float = float(currentTreeStage) / 15.0
	
	# Set growth scaling
	var base_scale: float = 0.5
	var max_scale: float = 2.5
	var current_scale: float = lerp(base_scale, max_scale, progress_ratio)
	%TreeVisual.scale = Vector2(current_scale, current_scale)
	
	# Set color change with growth
	var sprout_color: Color = Color("8bc34a") # Light Green
	var mature_color: Color = Color("1b5e20") # Dark Forest Green
	%TreeVisual.color = sprout_color.lerp(mature_color, progress_ratio)

func _calculatePassiveTaps() -> void:
	var totalPassiveTaps: int = 0
	
	for animal in passiveAnimalRates:
		var rate: int = passiveAnimalRates[animal]["rate"]
		var baseCount: int = passiveTapAnimals.get(animal, 0)
		var storeCount: int = passiveStoreAnimals.get(animal, 0)
		totalPassiveTaps += (baseCount + storeCount) * rate

	
	passiveTapsPerSecond = totalPassiveTaps

func _on_passive_tap_timer_timeout() -> void:
	if passiveTapsPerSecond > 0:
		availableTaps += passiveTapsPerSecond
		totalTaps += passiveTapsPerSecond
		currentTreeTaps += passiveTapsPerSecond
		_newStage()
		_updateUI()

func _getAnimalCosts(animal: String) -> int:
	if not passiveAnimalRates.has(animal):
		return 0
	
	var baseCost: int = passiveAnimalRates[animal]["baseCost"]
	var ownedCount: int = passiveTapAnimals.get(animal, 0)
	
	return int(baseCost * pow(costMultiplier, ownedCount))
	
func buyAnimal(animal: String) -> bool:
	var cost: int = _getAnimalCosts(animal)
	
	# Currency availability check
	if availableTaps >= cost and totalTrees >= 1:
		availableTaps -= cost
		passiveTapAnimals[animal] += 1
		
		# Adjust animal costs after purchase
		_calculatePassiveTaps()
		_updateUI()
		return true # Purchase successful
		
	return false # Not enough taps, may need a message for player
