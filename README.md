# preload() Drop Custom
## Install
* Add `godot_preload_drop_custom/` to your `addons/` folder.
## Why?

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

* 1:1 `const` mapping to base file name (lets you move files inside folders).
* Full autocomplete because `const`. Using all lowercase for file name consistency, but you could use uppercase.
* Select, drag and drop from the filesystem tab, works recursively.
* `uid://` can move files anywhere without breakage.
* Access is as good as inline code aka `things.a.color`
