extends CanvasLayer

## Composant réutilisable pour afficher le BehaviorTree d'un agent en temps réel
## Utilisation : Ajoute ce nœud à ta scène et assigne le BTPlayer dans l'inspecteur
## Raccourcis : 
##   - F10 : Afficher/Masquer le panneau
##   - F11 : Détacher/Rattacher dans une fenêtre popup

#le BTPlayer de l'agent à surveiller (à assigner dans l'inspecteur)
@export var bt_player: BTPlayer

#si vrai, le panneau est visible au démarrage
@export var visible_at_start: bool = false

@onready var behavior_tree_view: BehaviorTreeView = %BehaviorTreeView
@onready var behavior_inspector: PanelContainer = %BehaviorInspector
@onready var control: Control = %Control

var popup_window: Window = null


func _ready() -> void:
	#cache le panneau au démarrage si visible_at_start est false
	behavior_inspector.visible = visible_at_start
	
	if not bt_player:
		push_warning("[BehaviorTreeDebugger] Aucun BTPlayer assigné. Assigne-le dans l'inspecteur.")
	else:
		print("[DEBUG] ✓ BehaviorTreeDebugger prêt (F10: Toggle | F11: Popup)")


func _physics_process(_delta: float) -> void:
	if bt_player and behavior_tree_view and bt_player.get_bt_instance():
		var inst: BTInstance = bt_player.get_bt_instance()
		var bt_data: BehaviorTreeData = BehaviorTreeData.create_from_bt_instance(inst)
		behavior_tree_view.update_tree(bt_data)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# F10 pour afficher/masquer le panneau
		if event.keycode == KEY_F10:
			_toggle_visibility()
		# F11 pour détacher/rattacher dans une fenêtre (seulement si le panneau est visible)
		elif event.keycode == KEY_F11 and behavior_inspector.visible:
			if popup_window == null or not is_instance_valid(popup_window):
				_create_popup_window()
			else:
				_close_popup_window()


func _toggle_visibility() -> void:
	# affiche ou masque le panneau (seulement si pas en popup)
	if popup_window == null or not is_instance_valid(popup_window):
		behavior_inspector.visible = not behavior_inspector.visible
		var status = "visible" if behavior_inspector.visible else "masqué"
		print("[DEBUG] ✓ BehaviorTreeView %s (F10 pour toggle)" % status)


func _create_popup_window() -> void:
	#création de la nouvelle fenêtre popup
	popup_window = Window.new()
	popup_window.title = "BehaviorTree Inspector"
	popup_window.size = Vector2i(650, 800)
	popup_window.position = Vector2i(100, 100)
	popup_window.unresizable = false
	popup_window.close_requested.connect(_close_popup_window)
	
	# place le BehaviorInspector dans la fenêtre popup
	control.remove_child(behavior_inspector)
	popup_window.add_child(behavior_inspector)
	
	# Ajoute la fenêtre à la scène
	add_child(popup_window)
	popup_window.show()
	
	print("[DEBUG] ✓ BehaviorTreeView détaché dans une fenêtre séparée (F11 pour fermer)")


func _close_popup_window() -> void:
	if popup_window and is_instance_valid(popup_window):
		# remet le BehaviorInspector à sa place d'origine
		popup_window.remove_child(behavior_inspector)
		control.add_child(behavior_inspector)
		
		popup_window.queue_free()
		popup_window = null
		
		print("[DEBUG] ✓ BehaviorTreeView rattaché à la fenêtre principale (F11 pour détacher)")


# fonction pour assigner le BTPlayer par code
func set_bt_player(player: BTPlayer) -> void:
	bt_player = player
	if bt_player:
		print("[DEBUG] ✓ BTPlayer assigné à BehaviorTreeDebugger")
