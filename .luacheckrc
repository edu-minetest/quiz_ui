-- unused_args = false
-- allow_defined_top = true

globals = {
    "minetest",
    "fgettext",
    "DIR_DELIM",
    "quiz",
    "quiz_ui",
    "yaml",
    "flow",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",
}
