# preload() Drop Custom
## Install
* Add `godot_preload_drop_custom/` to your `addons/` folder.
## Why?
Use Resources on disk directly from a dictionary without manually setting up each entry.

Example File System

* `things/a.tres`
* `things/b.tres`
* `things/c.tres`

File System Tab ➡️ Select Resources ➡️ LMB+SHIFT drag into Script Editor

```gdscript
const things={
	'a' : preload("uid://cn0q8uin0m4ma"),
	'b' : preload("uid://drggpemtlmht7"),
	'c' : preload("uid://c5m0miw46en5k"),
}
```

Advantages

* Full autocomplete from `const`. Example: `things.a.color`
* 1:1 mapping to base file name (organize Resources in folders without code changes).
* Select, drag and drop from the filesystem tab, works recursively.
* `uid://` can move files anywhere without breakage.
