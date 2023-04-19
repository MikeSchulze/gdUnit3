# singleton with lots of game/player data stored
# also handles initial player/host creation

extends Node

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 6

# Consts for domino phase
const num_domino_rounds = 6

# Consts for footprint tiles
const num_outer_tiles = 36
const num_inner_tiles = 24
const tiles_per_round = (num_outer_tiles + num_inner_tiles) / num_domino_rounds

var peer = null

# Name for my player.
var player_name = "Player"

# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Character Data in id:data format
export var total_points = {}
export var lydia_lion = {}
export var alloys = {}
export var footprint_tiles = {}
export var bully_particles = {}
export var elcitraps = {}
export var hair = {}
export var clothes = {}
export var body = {}

var first_level = "Agency"

var random_seed = 0

# Traits for elcitraps
export var traits = [
	["red", "Painting"], ["blue", "Law"], ["green", "Biology"],
	["red", "Singing"], ["blue", "Planting"], ["green", "Math"],
	["red", "Music"], ["blue", "Cooking"], ["green", "Physics"],
	["red", "Acting"], ["blue", "Building"], ["green", "Geology"],
	["red", "Sports"], ["blue", "Speaking"], ["green", "Astronomy"]
]

# choices for koi pond venn diagram level
export var choices = [
	["y", "This is a yellow choice."], 
	["r", "Now a red choice!"],
	["y", "Yet another yellow choice!"],
	["b", "Ooh a blue choice."],
	["b", "And another blue choice!"],
	["yb", "Ooh a yellow and blue choice!"],
	["br", "And a red and blue choice."],
	["ybr", "A yellow, blue, and red choice!"],
	["y", "Drinking lots of clean water."],
	["ybr", "Growing a garden with others."],
	["yr", "Exercising."],
	["yr", "Learning to swim."],
	["y", "Learning to add numbers."],
	["br", "Playing games with friends."],
	["b", "Wishing someone a happy birthday."],
	["yb", "Learning about an archeology site."],
	["y", "Eating your vegetables."],
	["r", "Painting a picture."],
	["br", "Playing piano for others."],
	["ybr", "Playing in a soccer game."]
]

# list of [top number, bottom number] lists
export var dominos = []

# dictionary mapping numbers to elements for dominos
# key: "top_number+bottomnumber", item: [top element, bottom element]
export var domino_dict = {
	"00": ["", ""],
	"01": ["", "Copper"],
	"02": ["", "Lead"],
	"03": ["", "Carbon"],
	"04": ["", "Nickel"],
	"05": ["", "Cobalt"],
	"06": ["", "Aluminum"],
	"07": ["", "Cadmium"],
	"08": ["", "Iridium"],
	"09": ["", "Gold"],
	"11": ["Tin", "Copper"],
	"12": ["Tin", "Antimony"],
	"13": ["Copper", "Iron"],
	"14": ["Tin", "Titanium"],
	"15": ["Copper", "Chromium"],
	"16": ["Tin", "Magnesium"],
	"17": ["Copper", "Tellurium"],
	"18": ["Tin", "Platinum"],
	"19": ["Copper", "Silver"],
	"22": ["Lead", "Antimony"],
	"23": ["Lead", "Carbon"],
	"24": ["Antimony", "Nickel"],
	"25": ["Lead", "Cobalt"],
	"26": ["Antimony", "Aluminum"],
	"27": ["Lead", "Cadmium"],
	"28": ["Antimony", "Iridium"],
	"29": ["Lead", "Gold"],
	"33": ["Iron", "Carbon"],
	"34": ["Iron", "Titanium"],
	"35": ["Carbon", "Chromium"],
	"36": ["Iron", "Magnesium"],
	"37": ["Carbon", "Tellurium"],
	"38": ["Iron", "Platinum"],
	"39": ["Carbon", "Silver"],
	"44": ["Nickel", "Titanium"],
	"45": ["Nickel", "Cobalt"],
	"46": ["Titanium", "Aluminum"],
	"47": ["Nickel", "Cadmium"],
	"48": ["Titanium", "Iridium"],
	"49": ["Nickel", "Gold"],
	"55": ["Chromium", "Cobalt"],
	"56": ["Chromium", "Magnesium"],
	"57": ["Cobalt", "Tellurium"],
	"58": ["Chromium", "Platinum"],
	"59": ["Cobalt", "Silver"],
	"66": ["Aluminum", "Magnesium"],
	"67": ["Aluminum", "Cadmium"],
	"68": ["Magnesium", "Iridium"],
	"69": ["Aluminum", "Gold"],
	"77": ["Tellurium", "Cadmium"],
	"78": ["Tellurium", "Platinum"],
	"79": ["Cadmium", "Silver"],
	"88": ["Iridium", "Platinum"],
	"89": ["Iridium", "Gold"],
	"99": ["Silver", "Gold"]
}

# list of elements and corresponding alloy, where their index is their domino number
export var element_table = [
	["Copper", "Tin", "Bronze"],
	["Lead", "Antimony", "Antimonial Lead"],
	["Carbon", "Iron", "Steel"],
	["Nickel", "Titanium", "Nitinol"],
	["Cobalt", "Chromium", "Vitalium"],
	["Aluminum", "Magnesium", "Magnalium"],
	["Cadmium", "Tellurium", "Cadmium-Telluride"],
	["Iridium", "Platinum", "Platinum-Iridium"],
	["Gold", "Silver", "Electrum"]
]

# maps element to corresponding alloy
export var element_to_alloy = {
	"Copper": "Bronze",
	"Tin": "Bronze",
	"Lead": "Antimonial Lead",
	"Antimony": "Antimonial Lead",
	"Carbon": "Steel",
	"Iron": "Steel",
	"Nickel": "Nitinol",
	"Titanium": "Nitinol",
	"Cobalt": "Vitalium",
	"Chromium": "Vitalium",
	"Aluminum": "Magnalium",
	"Magnesium": "Magnalium",
	"Cadmium": "Cadmium-Telluride",
	"Tellurium": "Cadmium-Telluride",
	"Iridium": "Platinum-Iridium",
	"Platinum": "Platinum-Iridium",
	"Gold": "Electrum",
	"Silver": "Electrum"
}

# maps alloy to description of alloy
export var alloy_table = {
	"Bronze": "Combining Copper (Love) with Tin (Order) results in Bronze (A Loving Prepared Environment).",
	"Antimonial Lead": "Combining Antimony (Joy) with Lead (Focus) results in Antimonial Lead (Energy).",
	"Steel": "Combining Carbon (Care) with Iron (Safety) results in Steel (Stability).",
	"Nitinol": "Combining Titanium (Patience) with Nickel (Experiences) results in Nitinol (Perception).",
	"Vitalium": "Combining Cobalt (Goodness) with Chromium (Skills) results in Vitalium (Ability).",
	"Magnalium": "Combining Magnesium (Self-Control) with Aluminum (Purpose) results in Magnalium (Resilience).",
	"Cadmium-Telluride": "Combining Cadmium (Trust / Hope) with Tellurium (Knowledge) results in Cadmium-Telluride (Discernment).",
	"Platinum-Iridium": "Combining Platinum (Kindness) with Iridium (Understanding) results in Platinum-Iridium (Responsibility).",
	"Electrum": "Combining Gold (Gentleness) with Silver (Respect) results in Electrum (Relationship)."
}

# maps round number and domino number to title of footprint tile
# key: "round_number+domino_number", item: Title of footprint tile
export var footprint_title_table = {
	"00": "Our Earth",
	"01": "Dinosaurs, Mastodons, and Megafauna",
	"02": "Our Earliest Ancestors",
	"03": "Tools",
	"04": "Many Branches on our Human Tree",
	"05": "Fire and Language",
	"06": "How We Date Human Artifacts",
	"07": "Early Beads and Haplogroups",
	"08": "Migration and Volcanos",
	"09": "Human Trait Gumballs",
	"10": "Music and Sewing",
	"11": "Wolves and Cubs, Cats and Kittens",
	"12": "The First Fishing Trips",
	"13": "Melting Glaciers",
	"14": "Our First Battles",
	"15": "Growing Gardens / Return of Glaciers",
	"16": "Gobekli Tepe",
	"17": "Bye Glaciers (again), Hello Sheep Herding",
	"18": "Bread and Dominos",
	"19": "Clay and Catalhoyuk",
	"20": "Malachite to Copper",
	"21": "Human Skin",
	"22": "Young Earth Theory",
	"23": "Drums and Kilns",
	"24": "Our First Towns",
	"25": "Differing Human Opinions?",
	"26": "Duggarland and Indus River Valley",
	"27": "Cluck Cluck! Chickens and Wheels",
	"28": "Tulips and Horses",
	"29": "The First Written Words",
	"30": "Star Charts and Stonehenge",
	"31": "Sailboats",
	"32": "Timelines and Milk",
	"33": "Pearls and Pigeons",
	"34": "Chocolate and Bricks",
	"35": "First Laws and Governments",
	"36": "Pyramids, Games, Bees, and Medicine",
	"37": "Falcons and the First Minoan Palaces",
	"38": "Judaism and Horses",
	"39": "Hinduism and the New Kindgom of Egypt",
	"40": "Iron!",
	"41": "The First Olympics",
	"42": "Buddhism and Coins",
	"43": "Waterwheels and Blast Furnaces",
	"44": "Strong Concrete Called Pozzolana",
	"45": "Widespread Glassmaking",
	"46": "Steam Power",
	"47": "Our First Bound Books",
	"48": "Horseshoes and Attila",
	"49": "Islam and Tang",
	"50": "The Viking Clinker Built Ships",
	"51": "Eye Glasses, the Magnetic Compass, and the Song Dynasty",
	"52": "The Printing Press",
	"53": "Telescopes, Microscopes, and the First Piston Engine",
	"54": "Steel Mills and Darwin's Thoughts",
	"55": "Germs, Telegraphs, and Telephones",
	"56": "Phonographs, Zippers, Ballpoint Pens, and Cars!",
	"57": "Radio, TV, and Lift Off!",
	"58": "Haplogroups and Space Stations",
	"59": "Inventions and Cures of our Future",
}

# maps round number and domino number to description of footprint tile
# key: "round_number+domino_number", item: Description of footprint tile
export var footprint_text_table = {
	"00": "Our Earth",
	"01": "Dinosaurs, Mastodons, and Megafauna",
	"02": "Our Earliest Ancestors",
	"03": "Tools",
	"04": "Many Branches on our Human Tree",
	"05": "Fire and Language",
	"06": "How We Date Human Artifacts",
	"07": "Early Beads and Haplogroups",
	"08": "Migration and Volcanos",
	"09": "Human Trait Gumballs",
	"10": "Music and Sewing",
	"11": "Wolves and Cubs, Cats and Kittens",
	"12": "The First Fishing Trips",
	"13": "Melting Glaciers",
	"14": "Our First Battles",
	"15": "Growing Gardens / Return of Glaciers",
	"16": "Gobekli Tepe",
	"17": "Bye Glaciers (again), Hello Sheep Herding",
	"18": "Bread and Dominos",
	"19": "Clay and Catalhoyuk",
	"20": "Malachite to Copper",
	"21": "Human Skin",
	"22": "Young Earth Theory",
	"23": "Drums and Kilns",
	"24": "Our First Towns",
	"25": "Differing Human Opinions?",
	"26": "Duggarland and Indus River Valley",
	"27": "Cluck Cluck! Chickens and Wheels",
	"28": "Tulips and Horses",
	"29": "The First Written Words",
	"30": "Star Charts and Stonehenge",
	"31": "Sailboats",
	"32": "Timelines and Milk",
	"33": "Pearls and Pigeons",
	"34": "Chocolate and Bricks",
	"35": "First Laws and Governments",
	"36": "Pyramids, Games, Bees, and Medicine",
	"37": "Falcons and the First Minoan Palaces",
	"38": "Judaism and Horses",
	"39": "Hinduism and the New Kindgom of Egypt",
	"40": "Iron!",
	"41": "The First Olympics",
	"42": "Buddhism and Coins",
	"43": "Waterwheels and Blast Furnaces",
	"44": "Strong Concrete Called Pozzolana",
	"45": "Widespread Glassmaking",
	"46": "Steam Power",
	"47": "Our First Bound Books",
	"48": "Horseshoes and Attila",
	"49": "Islam and Tang",
	"50": "The Viking Clinker Built Ships",
	"51": "Eye Glasses, the Magnetic Compass, and the Song Dynasty",
	"52": "The Printing Press",
	"53": "Telescopes, Microscopes, and the First Piston Engine",
	"54": "Steel Mills and Darwin's Thoughts",
	"55": "Germs, Telegraphs, and Telephones",
	"56": "Phonographs, Zippers, Ballpoint Pens, and Cars!",
	"57": "Radio, TV, and Lift Off!",
	"58": "Haplogroups and Space Stations",
	"59": "Inventions and Cures of our Future",
}

# Chunk Size/Dimensions
const DIMENSION = Vector3(16, 64, 16)

# Size of atlas
# Current texture atlas has size 3 x 2
const TEXTURE_ATLAS_SIZE = Vector2(3, 2)

# Enumerator for block faces
enum {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	BACK,
	SOLID
}

# Enumerator for all blocks within game
# Update when adding new blocks
enum {
	AIR,
	DIRT,
	GRASS,
	STONE
}

# Dictionary for mapping blocks to corresponding textures in atlas
# Update when adding new blocks or changing texture atlas
const types = {
	AIR:{
		SOLID: false,
	},
	DIRT:{
		SOLID: true,
		TOP: Vector2(2, 0),
		BOTTOM: Vector2(2, 0),
		LEFT: Vector2(2, 0),
		RIGHT: Vector2(2,0),
		FRONT: Vector2(2, 0),
		BACK: Vector2(2, 0),
	},
	GRASS:{
		SOLID: true,
		TOP: Vector2(0, 0),
		BOTTOM: Vector2(2, 0),
		LEFT: Vector2(1, 0),
		RIGHT: Vector2(1,0),
		FRONT: Vector2(1, 0),
		BACK: Vector2(1, 0),
	},
	STONE:{
		SOLID: true,
		TOP: Vector2(0, 1),
		BOTTOM: Vector2(0, 1),
		LEFT: Vector2(0, 1),
		RIGHT: Vector2(0, 1),
		FRONT: Vector2(0, 1),
		BACK: Vector2(0, 1),
	}
}

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beginss here, tell the connected player that we are here.
	
	# ask host for level and random seed
	rpc_id(1, "get_level")
	rpc_id(1, "get_random_seed")
	
	rpc("register_player", player_name)

# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)

# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.
remotesync func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	total_points[id] = 0
	elcitraps[id] = []
	hair[id] = 0
	clothes[id] = 0
	body[id] = 0
	
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game():
	# Change scene.
#	print(players)

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 1:
		post_start_game()


remote func post_start_game():
	gamestate.players_ready = []
	var world = load("res://levels/Manager.tscn")
	
			
	if get_tree().get_network_unique_id() != 1:
		for top in range(10):
			for bottom in range(top+1):
				dominos.append([bottom, top])
		seed(random_seed)
#		print(random_seed)
		dominos.shuffle()
#		print(dominos)
	
	get_tree().change_scene_to(world)

# tell host we're ready to start
remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size()-1:
		for p in players:
			if p != get_tree().get_network_unique_id():
				rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	
	var id = get_tree().get_network_unique_id()
	
	rpc("register_player", player_name)


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
# host sends level to player who asked
remote func get_level():
	var id = get_tree().get_rpc_sender_id()
	rpc_id(id, "set_level", first_level)
	
# player sets their level
remote func set_level(level):
	first_level = level
	
# host sends random seed to player who asked
remote func get_random_seed():
	var id = get_tree().get_rpc_sender_id()
	rpc_id(id, "set_random_seed", random_seed)
	
# player sets their random seed
remote func set_random_seed(rando_seed):
	random_seed = rando_seed
#	print("seed: ", random_seed)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

# host tells everyone to start the game
func begin_game():
	assert(get_tree().is_network_server())

	# Call to pre-start game with the spawn points.
	for p in players:
		if p != get_tree().get_network_unique_id():
			rpc_id(p, "pre_start_game")

	pre_start_game()


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
