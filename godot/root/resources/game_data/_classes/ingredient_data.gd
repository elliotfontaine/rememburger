class_name IngredientData
extends Resource

enum WorkStation {NONE, PLANCHE_A_DECOUPER, GRILL}

@export var name: String = ""
@export var texture: CompressedTexture2D
@export var workstation: WorkStation = WorkStation.NONE
@export var work_result_success: IngredientData
@export var n_produced_success: int = 1
@export var work_result_fail: IngredientData
@export var n_produced_fail: int = 1
