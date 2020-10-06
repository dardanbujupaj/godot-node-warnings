tool
extends VBoxContainer

signal warning_rules_updated
signal warning_rules_reset

var warning_rules: Dictionary setget _set_warning_rules

onready var class_popup: PopupMenu = $ClassPopupMenu

onready var tree: Tree = $Tree

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_tree()
	pass # Replace with function body.


# TODO: setup correct tree
func setup_tree():
	tree.clear()
	var root = tree.create_item()
	root.set_text(0, "Warning rules")
	root.disable_folding = true
	
	var default_nodes = ["Node2D", "RayCast"]
	
	for node in warning_rules.keys():
		var item = tree.create_item(root)
		#item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
		#item.set_editable(0, true)
		item.set_text(0, node)
		item.set_icon(0, get_icon(node, "EditorIcons"))
		item.add_button(1, get_icon("Remove", "EditorIcons"), -1, false, "Remove this rule")
		
		
		var category_color = get_color("prop_category", "Editor")
		item.set_custom_bg_color(0, category_color)
		item.set_custom_bg_color(1, category_color)
		
		
		for rule in warning_rules[node]:
			
			var rule_item = tree.create_item(item)
			rule_item.set_text(0, rule['property'])
			rule_item.add_button(1, get_icon("Remove", "EditorIcons"), -1, false, "Remove this rule")
			
			var section_color = get_color("prop_section", "Editor")
			rule_item.set_custom_bg_color(0, section_color)
			rule_item.set_custom_bg_color(1, section_color)
			
			
			var value = tree.create_item(rule_item)
			value.set_text(0, "Critical value")
			value.set_tooltip(0, "When property equals this value, a warning will be shown")
			value.set_editable(1, true)
			value.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			value.set_checked(1, rule['critical_value'])
			
			var description = tree.create_item(rule_item)
			description.set_text(0, "Description")
			description.set_tooltip(0, "Description of the rule")
			description.set_editable(1, true)
			description.set_text(1, rule["description"])


# is called when a class is selected for a ruleset
func _on_Tree_custom_popup_edited(arrow_clicked):
	
	class_popup.clear()
	# TODO: remove classes where rules already exist
	var classes: Array = ClassDB.get_inheriters_from_class("Node")
	classes.append("Node")
	classes.sort()
	for c in classes:
		if ClassDB.can_instance(c):
			var icon = get_icon(c, "EditorIcons")
			class_popup.add_icon_item(icon, c)
		
	# show popup to choose new class
	class_popup.popup(tree.get_custom_popup_rect())


# change icon and text if a new class was selected
# TODO: change properties
func _on_ClassPopupMenu_index_pressed(index):
	
	var item = tree.create_item(tree.get_root())
	
	item.set_text(0, class_popup.get_item_text(index))
	item.set_icon(0, class_popup.get_item_icon(index))
	item.add_button(1, get_icon("Remove", "EditorIcons"), -1, false, "Remove this rule")
	
	
	var category_color = get_color("prop_category", "Editor")
	item.set_custom_bg_color(0, category_color)
	item.set_custom_bg_color(1, category_color)
	
	_on_rules_updated()



func _on_Tree_button_pressed(item, column, id):
	item.free()
	_on_rules_updated()


func _on_AddRule_pressed():
	class_popup.clear()
	# TODO: remove classes where rules already exist
	var classes: Array = ClassDB.get_inheriters_from_class("Node")
	classes.append("Node")
	classes.sort()
	for c in classes:
		if ClassDB.can_instance(c):
			var icon = get_icon(c, "EditorIcons")
			class_popup.add_icon_item(icon, c)
	class_popup.popup()
	class_popup.set_position(get_global_mouse_position())


func _set_warning_rules(new_rules):
	warning_rules = new_rules
	call_deferred("setup_tree")


func _on_rules_updated():
	var rules = get_rules_dictionary()
	print(rules)
	emit_signal("warning_rules_updated", rules)


func get_rules_dictionary():
	var dictionary = {}
	
	# iterate over rule node entries
	var current_item = tree.get_root().get_children()
	while current_item != null:
		var rules = []
		
		# iterate over rules for this node
		var current_rule = current_item.get_children()
		while current_rule != null:
			var property = current_rule.get_text(0)
			var critical_value = current_rule.get_children().is_checked(1)
			var description = current_rule.get_children().get_next().get_text(1)
			
			# add the rule to the list
			rules.append({
				"property": property,
				"critical_value": critical_value,
				"description": description
			})
			
			current_rule = current_rule.get_next()
		
		dictionary[current_item.get_text(0)] = rules
		
		
		
		# get next sibling
		current_item = current_item.get_next()
	
	return dictionary

func _on_Tree_item_edited():
	_on_rules_updated()


func _on_ResetRules_pressed():
	emit_signal("warning_rules_reset")
