extends Node

var active_dfa          : int    = 1
var input_strings       : Array  = []   # all strings the user entered
var current_string_index: int    = 0    # which one is currently being simulated
var last_results        : Array  = []   # stores ACCEPTED/REJECTED per string
var in_menu: bool = false
