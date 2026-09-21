extends Control

var gameManager = null

# Holds all node references
@onready var total_tap_amount: Label = %TotalTapAmount
@onready var available_tap_amount: Label = %AvailableTapAmount
@onready var current_tap_amount: Label = %CurrentTapAmount
@onready var tree_stage_number: Label = %TreeStageNumber
@onready var progress_amount: Label = %ProgressAmount
@onready var total_tree_amount: Label = %TotalTreeAmount
@onready var total_p_tap_amount: Label = %TotalPTapAmount
@onready var squirrel_amount: Label = %SquirrelAmount
@onready var racoon_amount: Label = %RacoonAmount
@onready var fox_amount: Label = %FoxAmount
@onready var deer_amount: Label = %DeerAmount
@onready var bear_amount: Label = %BearAmount
@onready var available_store_taps: Label = %AvailableStoreTaps
@onready var buy_squirrel: Button = %BuySquirrel
@onready var buy_racoon: Button = %BuyRacoon
@onready var buy_fox: Button = %BuyFox
@onready var buy_deer: Button = %BuyDeer
@onready var buy_bear: Button = %BuyBear

func setup_ui(managerRef) -> void:
	gameManager = managerRef
	refreshUI()

func refreshUI() -> void:
	if gameManager == null:
		return
	
	# Populate Stats Tab
	%TotalTapAmount.text = str(gameManager.totalTaps)
	%AvailableTapAmount.text = str(gameManager.availableTaps)
	%CurrentTapAmount.text = str(gameManager.currentTreeTaps)
	%TreeStageNumber.text = str(gameManager.currentTreeStage + 1)
	%ProgressAmount.text = str(gameManager.currentTreeTaps) + " / " + str(gameManager.currentRequiredTaps)
	%TotalTreeAmount.text = str(gameManager.totalTrees)
	
	# Populate Passive Stats Tab
	%TotalPTapAmount.text = str(gameManager.passiveTapsPerSecond)
	%SquirrelAmount.text = str(gameManager.passiveTapAnimals.get("squirrel", 0) + gameManager.passiveStoreAnimals.get("squirrel", 0))
	%RacoonAmount.text = str(gameManager.passiveTapAnimals.get("racoon", 0) + gameManager.passiveStoreAnimals.get("racoon", 0))
	%FoxAmount.text = str(gameManager.passiveTapAnimals.get("fox", 0) + gameManager.passiveStoreAnimals.get("fox", 0))
	%DeerAmount.text = str(gameManager.passiveTapAnimals.get("deer", 0) + gameManager.passiveStoreAnimals.get("deer", 0))
	%BearAmount.text = str(gameManager.passiveTapAnimals.get("bear", 0) + gameManager.passiveStoreAnimals.get("bear", 0))

	# Populate Available Taps in Store
	%AvailableStoreTaps.text = str(gameManager.availableTaps)

# Store Button Callbacks (Delegated to GameManager logic)
func _on_buy_squirrel_pressed() -> void:
	if gameManager != null and gameManager.buyAnimal("squirrel"):
		refreshUI()

func _on_buy_racoon_pressed() -> void:
	if gameManager != null and gameManager.buyAnimal("racoon"):
		refreshUI()

func _on_buy_fox_pressed() -> void:
	if gameManager != null and gameManager.buyAnimal("fox"):
		refreshUI()

func _on_buy_deer_pressed() -> void:
	if gameManager != null and gameManager.buyAnimal("deer"):
		refreshUI()

func _on_buy_bear_pressed() -> void:
	if gameManager != null and gameManager.buyAnimal("bear"):
		refreshUI()
