class_name QueueManager
extends Node

# queue_manager.gd
# Autoload — à enregistrer dans Project > Project Settings > Autoload
# Nom suggéré : "QueueManager"
#
# Responsabilités :
#   - Spawner les clients à intervalle aléatoire
#   - Gérer le timer de chaque client (tick des points)
#   - Gérer les transitions d'état : IN_QUEUE → AT_COUNTER → WAITING → SERVED / LEFT_ANGRY
#   - Émettre des signaux pour que les Views réagissent (zéro couplage visuel ici)

signal customer_added(customer: CustomerData)
signal customer_ticked(customer: CustomerData)
signal customer_state_changed(customer: CustomerData)
signal customer_left_angry(customer: CustomerData)
signal customer_served(customer: CustomerData, points_earned: int)
signal queue_changed()

#TODO: use YARD registries instead
const BREAD_BOTTOM = preload("uid://d4lx5e0um04f6")
const BREAD_TOP = preload("uid://cpnp1ydnfbh0")


@export var spawn_interval_min: float = 5.0
@export var spawn_interval_max: float = 9.0
@export var max_queue_size: int = 5
@export var points_drain_per_second: float = 8.0
@export var reject_penalty: int = 5

@export var ingredient_pool: Array[IngredientData] = []
## Min/max number of ingredients beside burger bread (top and bottom)
@export var order_ingredients_min: int = 2
@export var order_ingredients_max: int = 4

var queue: Array[CustomerData] = []
var _spawn_timer: float = 0.0
var _next_spawn_in: float = 0.0
var _id_counter: int = 0
var _active: bool = false


func _ready() -> void:
	# Le manager démarre en pause ; c'est GameState qui appelle start()
	set_process(false)


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


func stop() -> void:
	_active = false
	set_process(false)


## Retourne le client actuellement AT_COUNTER, ou null
func get_counter_customer() -> CustomerData:
	for c in queue:
		if c.state == CustomerData.State.AT_COUNTER:
			return c
	return null


## Retourne tous les clients WAITING (commande cachée, en attente de service)
func get_waiting_customers() -> Array[CustomerData]:
	return queue.filter(func(c: CustomerData) -> bool: return c.state == CustomerData.State.WAITING)


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

	c.state = CustomerData.State.WAITING
	customer_state_changed.emit(c)


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


## Le joueur sert un burger : on vérifie la commande et on conclut.
## Retourne les points gagnés (0 si commande trop différente).
func serve_customer(customer_id: int, served_meal: MealData) -> int:
	var c := _find(customer_id)
	if c == null or c.state != CustomerData.State.WAITING:
		return 0

	var distance := c.order.distance_to(served_meal)

	var points_earned := maxi(0, int(c.points) - distance)
	c.state = CustomerData.State.SERVED
	queue.erase(c)

	customer_served.emit(c, points_earned)
	queue_changed.emit()
	return points_earned


func _tick_spawn_timer(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer < _next_spawn_in:
		return

	_spawn_timer = 0.0
	_schedule_next_spawn()

	if queue.size() >= max_queue_size:
		# File pleine : ce spawn est perdu, on attend le prochain
		return

	_spawn_customer()


func _schedule_next_spawn() -> void:
	_next_spawn_in = randf_range(spawn_interval_min, spawn_interval_max)


func _spawn_customer() -> void:
	var c := CustomerData.new()
	c.id = _id_counter
	c.name = CustomerData.NAMES.pick_random()
	c.order = _generate_order()
	c.state = CustomerData.State.IN_QUEUE
	c.points = 100.0
	_id_counter += 1

	queue.append(c)
	customer_added.emit(c)
	queue_changed.emit()


func _generate_order() -> MealData:
	var order := MealData.new()
	var ingredients: Array[IngredientData] = [BREAD_BOTTOM]

	var pool := ingredient_pool.duplicate()
	pool.shuffle()
	if not pool.is_empty():
		var count := randi_range(order_ingredients_min, order_ingredients_max)
		for i in count:
			ingredients.append(pool[i])

	ingredients.append(BREAD_TOP)
	order.ingredients = ingredients
	return order


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

	c.state = CustomerData.State.LEFT_ANGRY
	queue.erase(c)

	customer_left_angry.emit(c)
	queue_changed.emit()
	LogWrapper.debug(self, "Customer %s left angry." % c)


func _find(customer_id: int) -> CustomerData:
	for c in queue:
		if c.id == customer_id:
			return c
	return null
