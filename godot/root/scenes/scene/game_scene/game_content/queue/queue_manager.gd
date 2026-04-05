class_name QueueManager
extends Node

# TODO: enlever les ids utilisés pour rien dans les signatures
# des méthodes (mais garder la propriété). Utiliser le client directement
# à la place

# Responsabilités :
#   - Spawner les clients à intervalle aléatoire
#   - Gérer le timer de chaque client (tick des points)
#   - Gérer les transitions d'état : IN_QUEUE → AT_COUNTER → WAITING → SERVED / LEFT_ANGRY

signal customer_added(customer: CustomerData)
signal customer_ticked(customer: CustomerData)
signal customer_state_changed(customer: CustomerData)
signal customer_left_angry(customer: CustomerData)
signal customer_served(customer: CustomerData, points_earned: int)
signal queue_changed()

const MEAL_PRESETS: Registry = preload("uid://b6iabg6hpbv1e")

@export var spawn_interval_min: float = 5.0
@export var spawn_interval_max: float = 9.0
@export var max_queue_size: int = 5
@export var points_drain_per_second: float = 8.0
@export var reject_penalty: int = 5

var queue: Array[CustomerData] = []
var _spawn_timer: float = 0.0
var _next_spawn_in: float = 0.0
var _id_counter: int = 0
var _active: bool = false


func _ready() -> void:
	# Le manager démarre en pause ; c'est GameContent qui appelle start()
	set_process(false)
	_connect_signals()


func _process(delta: float) -> void:
	_tick_spawn_timer(delta)
	_tick_customers(delta)


func start() -> void:
	queue.clear()
	_id_counter = 0
	_spawn_timer = 0.0
	_active = true
	_schedule_next_spawn()
	set_process(true)

	_spawn_customer()
	call_next_customer()


func stop() -> void:
	_active = false
	set_process(false)


## Retourne le client actuellement AT_COUNTER, ou null
func get_counter_customer() -> CustomerData:
	for c in queue:
		if c.state == CustomerData.State.AT_COUNTER:
			return c
	return null


## Appelle le premier client de la file au comptoir.
## Retourne le CustomerData appelé, ou null si la file est vide
## ou si un client est déjà AT_COUNTER.
func call_next_customer() -> CustomerData:
	if queue.is_empty():
		return null

	# Un seul client au comptoir à la fois
	for c in queue:
		if c.state == CustomerData.State.AT_COUNTER:
			return null

	var c := queue[0]
	c.state = CustomerData.State.AT_COUNTER
	customer_state_changed.emit(c)
	return c


## Le joueur accepte la commande : le client passe en WAITING
## (commande cachée, le joueur doit s'en souvenir).
func accept_customer(customer_id: int) -> void:
	var c := _find(customer_id)
	if c == null or c.state != CustomerData.State.AT_COUNTER:
		return

	c.state = CustomerData.State.IN_QUEUE
	c.has_ordered = true
	customer_state_changed.emit(c)

	# Renvoi en fin de file
	queue.erase(c)
	queue.append(c)

	call_next_customer()


## Le joueur rejette la commande : malus et renvoi en fin de file.
func reject_customer(customer_id: int) -> void:
	var c := _find(customer_id)
	if c == null or c.state != CustomerData.State.AT_COUNTER:
		return

	c.points  = maxf(c.points - reject_penalty, 0.0)
	c.state   = CustomerData.State.IN_QUEUE

	# Renvoi en fin de file
	queue.erase(c)
	queue.append(c)

	customer_state_changed.emit(c)
	queue_changed.emit()

	if c.points <= 0.0:
		_handle_angry_leave(c)

	call_next_customer()


## Le joueur sert un burger : on vérifie la commande et on conclut.
## Retourne les points gagnés (0 si commande trop différente).
func serve_customer(customer_id: int, served_meal: MealData) -> int:
	var c := _find(customer_id)
	if c == null or not c.has_ordered or c.state != CustomerData.State.AT_COUNTER:
		return -1

	var distance := c.order.distance_to(served_meal)

	var points_earned := maxi(0, int(c.points) - distance)
	c.state = CustomerData.State.SERVED
	queue.erase(c)

	customer_served.emit(c, points_earned)
	queue_changed.emit()
	LogWrapper.debug(
		self,
		"Customer %s left with a meal. %s point earned" % [c, points_earned]
	)

	call_next_customer()

	return points_earned


func _tick_spawn_timer(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer < _next_spawn_in:
		return

	_spawn_timer = 0.0
	_schedule_next_spawn()
	_spawn_customer()


func _schedule_next_spawn() -> void:
	_next_spawn_in = randf_range(spawn_interval_min, spawn_interval_max)


func _spawn_customer() -> void:
	if queue.size() >= max_queue_size:
		# File pleine : ce spawn est perdu, on attend le prochain
		return

	var c := CustomerData.new()
	c.id = _id_counter
	c.name = CustomerData.NAMES.pick_random()
	c.shirt_color = CustomerData.SHIRT_COLORS.pick_random()
	c.skin_color = CustomerData.SKIN_COLORS.pick_random()
	c.face = CustomerData.FACE_TEXTURES.pick_random()
	var hair_id: int = randi() % 6
	c.hair_outline = CustomerData.HAIR_OUTLINES[hair_id]
	c.hair_color_texture = CustomerData.HAIR_COLORS_TEXTURES[hair_id]
	if hair_id == 5:
		c.hair_color = [Color.RED, Color.BLUE].pick_random()
	else:
		c.hair_color = CustomerData.HAIR_COLORS.pick_random()
	c.order = _generate_order()
	c.state = CustomerData.State.IN_QUEUE
	c.points = 100.0
	_id_counter += 1

	queue.append(c)
	customer_added.emit(c)
	queue_changed.emit()
	LogWrapper.debug(self, "Customer %s just arrived." % c)


func _generate_order() -> MealData:
	# Simply pick a meal at random in the registry
	var meal_pool := MEAL_PRESETS.get_all_string_ids()
	var meal_name: StringName = meal_pool.pick_random()
	var meal := MEAL_PRESETS.load_entry(meal_name).duplicate()
	return meal


func _tick_customers(delta: float) -> void:
	# Copie pour itérer proprement si on supprime pendant la boucle
	for c in queue:
		if c.state in [CustomerData.State.SERVED, CustomerData.State.LEFT_ANGRY]:
			continue

		c.points -= points_drain_per_second * delta
		c.points  = maxf(c.points, 0.0)
		customer_ticked.emit(c)

		if c.points <= 0.0:
			_handle_angry_leave(c)


func _handle_angry_leave(c: CustomerData) -> void:
	if c.state == CustomerData.State.LEFT_ANGRY:
		return  # déjà traité

	var at_counter := c.state == CustomerData.State.AT_COUNTER
	c.state = CustomerData.State.LEFT_ANGRY
	queue.erase(c)
	if at_counter:
		call_next_customer()

	customer_left_angry.emit(c)
	queue_changed.emit()
	LogWrapper.debug(self, "Customer %s left angry." % c)


func _find(customer_id: int) -> CustomerData:
	for c in queue:
		if c.id == customer_id:
			return c
	return null


func _connect_signals() -> void:
	SignalBus.take_order_button_pressed.connect(_on_take_order_button_pressed)
	SignalBus.reject_button_pressed.connect(_on_reject_button_pressed)
	SignalBus.meal_served.connect(_on_meal_served)


func _on_take_order_button_pressed() -> void:
	accept_customer(get_counter_customer().id)


func _on_reject_button_pressed() -> void:
	reject_customer(get_counter_customer().id)


func _on_meal_served(meal: MealData) -> void:
	serve_customer(get_counter_customer().id, meal)
