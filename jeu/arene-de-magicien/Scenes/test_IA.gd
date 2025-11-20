extends Node3D

## Script pour connecter automatiquement le BehaviorTreeView à l'agent
## afin de visualiser son comportement en temps réel

@onready var behavior_tree_view: BehaviorTreeView = %BehaviorTreeView
@onready var bt_player: BTPlayer = $range_agent/BTPlayer


func _ready() -> void:
	if behavior_tree_view and bt_player:
		print("[DEBUG] ✓ BehaviorTreeView prêt à afficher l'arbre de l'agent!")
	else:
		push_error("Impossible de trouver le BehaviorTreeView ou BTPlayer - vérifiez les nœuds")


func _physics_process(_delta: float) -> void:
	# Met à jour l'affichage de l'arbre comportemental en temps réel
	if bt_player and behavior_tree_view:
		var inst: BTInstance = bt_player.get_bt_instance()
		var bt_data: BehaviorTreeData = BehaviorTreeData.create_from_bt_instance(inst)
		behavior_tree_view.update_tree(bt_data)
