@tool
extends EditorPlugin

var hooked := {}
var previous_text := {}
var shift_until_msec := 0
var suppress := false

func _enter_tree() -> void:
	set_process(true)

func _exit_tree() -> void:
	for edit in hooked.keys():
		if is_instance_valid(edit):
			var cb := _on_text_changed.bind(edit)
			if edit.text_changed.is_connected(cb):
				edit.text_changed.disconnect(cb)
	hooked.clear()
	previous_text.clear()

func _input(event: InputEvent) -> void:
	if event is InputEventKey \
	and event.keycode == KEY_SHIFT \
	and event.pressed \
	and not event.ctrl_pressed \
	and not event.meta_pressed:
		shift_until_msec = Time.get_ticks_msec() + 1500

func _process(_delta: float) -> void:
	_hook(get_editor_interface().get_base_control())

func _hook(node: Node) -> void:
	if node == null:
		return
	if node is CodeEdit and not hooked.has(node):
		hooked[node] = true
		previous_text[node] = node.text
		node.text_changed.connect(_on_text_changed.bind(node))
	for child in node.get_children():
		_hook(child)

func _on_text_changed(edit: CodeEdit) -> void:
	if suppress:
		return
	var before := String(previous_text.get(edit, ""))
	call_deferred("_check_deferred", edit, before)

func _check_deferred(edit: CodeEdit, before: String) -> void:
	if not is_instance_valid(edit):
		return
	var after := edit.text
	previous_text[edit] = after
	if Time.get_ticks_msec() > shift_until_msec:
		return
	if not _shift_only_active():
		return
	var inserted := _find_inserted_text(before, after)
	if inserted.is_empty() or not inserted.contains("res://"):
		return
	var paths := _extract_paths(inserted)
	if paths.is_empty():
		return
	var replacement := _make_preload_entries(paths)
	var start := _common_prefix_len(before, after)
	var end := start + inserted.length()
	var a := _index_to_line_col(after, start)
	var b := _index_to_line_col(after, end)
	suppress = true
	edit.select(a.x, a.y, b.x, b.y)
	edit.insert_text_at_caret(replacement)
	previous_text[edit] = edit.text
	suppress = false

func _shift_only_active() -> bool:
	return Input.is_key_pressed(KEY_SHIFT) \
		and not Input.is_key_pressed(KEY_CTRL) \
		and not Input.is_key_pressed(KEY_META)

func _find_inserted_text(before: String, after: String) -> String:
	var start := _common_prefix_len(before, after)
	var suffix := 0
	while suffix < before.length() - start \
	and suffix < after.length() - start \
	and before[before.length() - 1 - suffix] == after[after.length() - 1 - suffix]:
		suffix += 1

	return after.substr(start, after.length() - start - suffix)

func _common_prefix_len(a: String, b: String) -> int:
	var n := mini(a.length(), b.length())
	for i in n:
		if a[i] != b[i]:
			return i
	return n

func _index_to_line_col(text: String, index: int) -> Vector2i:
	var line := 0
	var col := 0
	for i in index:
		if text[i] == "\n":
			line += 1
			col = 0
		else:
			col += 1
	return Vector2i(line, col)

func _extract_paths(text: String) -> PackedStringArray:
	var out := PackedStringArray()
	var regex := RegEx.new()
	regex.compile("res://[^\\s\"',)\\]]+")

	for match in regex.search_all(text):
		out.append(match.get_string())
	return out

func _make_preload_entries(files: PackedStringArray) -> String:
	files.sort()
	var lines: Array[String] = []
	for path: String in files:
		var key := path.get_file().get_basename()
		key = key.replace("\\", "\\\\")
		key = key.replace("'", "\\'")
		var preload_path: String = ResourceUID.path_to_uid(path)
		lines.append("'%s' : preload(\"%s\")," % [key, preload_path])
	return "\n".join(lines)