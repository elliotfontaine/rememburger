class_name QueueManager
extends Node

# TODO: enlever les ids utilisés pour rien dans les signatures
# des méthodes (mais garder la propriété). Utiliser le client directement
# à la place

# Responsabilités :
#   - Spawner les clients à intervalle aléatoire
#   - Gérer le timer de chaque client (tick des points)
#   - Gérer les transitions d'état : IN_QUEUE → AT_COUNTER → WAITING → SERVED / LEFT_ANGRY
const START_TIP := 30.0

@warning_ignore("untyped_declaration")
var ORDER_DIFFICULTY_WEIGHTS: Dictionary[Callable, Dictionary] = {
	func(id): return id == 0: 				{ MenuEntry.Difficulty.EASY: 100 },
	func(id): return id in [1, 2]: 			{ MenuEntry.Difficulty.EASY: 50, MenuEntry.Difficulty.NORMAL: 40, MenuEntry.Difficulty.HARD: 10 },
	func(id): return id in range(3, 7): 	{ MenuEntry.Difficulty.EASY: 40, MenuEntry.Difficulty.NORMAL: 40, MenuEntry.Difficulty.HARD: 20 },
	func(id): return id >= 7: 				{ MenuEntry.Difficulty.EASY: 20, MenuEntry.Difficulty.NORMAL: 40, MenuEntry.Difficulty.HARD: 40 },
}

@export_group("Queue Settings")
@export var spawn_interval_min: float = 20.0
@export var spawn_interval_max: float = 40.0
@export var max_queue_size: int = 5
@export_group("Customer Settings")
@export_range(0, 100, 0.1, "prefer_slider", "suffix:%/s") var tip_decay_waiting: float = 4.0
@export_range(0, 100, 0.1, "prefer_slider", "suffix:%/s") var tip_decay_ordered: float = 2.0
@export_range(0, 100, 0.1, "prefer_slider", "suffix:%") var reject_penalty: float = 5.0
@export_range(0, 100, 0.1, "prefer_slider", "suffix:%") var accept_bonus: float = 25.0

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
	SignalBus.customer_state_changed.emit(c)
	return c


## Le joueur accepte la commande : le client passe en WAITING
## (commande cachée, le joueur doit s'en souvenir).
func accept_customer(customer_id: int) -> void:
	var c := _find(customer_id)
	if c == null or c.state != CustomerData.State.AT_COUNTER:
		return

	c.state = CustomerData.State.IN_QUEUE
	c.has_ordered = true
	var bonus := percent_to_tip(accept_bonus)
	SignalBus.customer_bonus_malus_applied.emit(c, bonus)
	c.points += bonus
	c.points = clampf(c.points, 0, START_TIP)
	SignalBus.customer_state_changed.emit(c)

	# Renvoi en fin de file
	queue.erase(c)
	queue.append(c)

	call_next_customer()


## Le joueur rejette la commande : malus et renvoi en fin de file.
func reject_customer(customer_id: int) -> void:
	var c := _find(customer_id)
	if c == null or c.state != CustomerData.State.AT_COUNTER:
		return
	
	var malus := percent_to_tip(reject_penalty)
	SignalBus.customer_bonus_malus_applied.emit(c, -malus)
	c.points -= malus
	c.points = clampf(c.points, 0, START_TIP)
	c.state = CustomerData.State.IN_QUEUE

	# Renvoi en fin de file
	queue.erase(c)
	queue.append(c)

	SignalBus.customer_state_changed.emit(c)
	SignalBus.queue_changed.emit()

	if c.points <= 0.0:
		_handle_angry_leave(c)

	call_next_customer()


## Le joueur sert un burger : on vérifie la commande et on conclut.
## Retourne les points gagnés (0 si commande trop différente).
func serve_customer(customer_id: int, served_meal: MealData) -> void:
	var c := _find(customer_id)
	if c == null or not c.has_ordered or c.state != CustomerData.State.AT_COUNTER:
		return

	var distance := c.order.meal.distance_to(served_meal)
	
	var meal_points_earned: int = 0
	var tip_points_earned: int = 0
	
	if distance <= 60 and served_meal.ingredients.size() > 2:
		meal_points_earned = ceili(c.order.base_price * (1 - (distance / 100.0)))
	
	if distance <= 30:
		tip_points_earned = ceili(c.points)

	c.state = CustomerData.State.SERVED
	queue.erase(c)

	SignalBus.customer_served.emit(c, meal_points_earned, tip_points_earned)
	SignalBus.queue_changed.emit()
	LogWrapper.debug(
		self,
		"Customer %s left with a meal. (%s+%s) point earned" % [c, meal_points_earned, tip_points_earned]
	)
	call_next_customer()



func percent_to_tip(percent: float) -> float:
	if percent <= 0.0:
		return 0
	if percent >= 100.0:
		return START_TIP
	return (percent / 100.0) * START_TIP


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
	
	var order_difficulty: MenuEntry.Difficulty
	for predicate: Callable in ORDER_DIFFICULTY_WEIGHTS.keys():
		if predicate.call(_id_counter):
			order_difficulty = weighted_pick(ORDER_DIFFICULTY_WEIGHTS.get(predicate))
			break
	
	var c := CustomerData.new(_id_counter)
	c.generate_order(order_difficulty)
	c.points = START_TIP
	c.state = CustomerData.State.AT_COUNTER if queue.is_empty() else CustomerData.State.IN_QUEUE
	_id_counter += 1

	queue.append(c)
	SignalBus.customer_added.emit(c)
	SignalBus.queue_changed.emit()
	LogWrapper.debug(self, "Customer %s just arrived." % c)


func _tick_customers(delta: float) -> void:
	# Copie pour itérer proprement si on supprime pendant la boucle
	for c in queue:
		if c.state in [CustomerData.State.SERVED, CustomerData.State.LEFT_ANGRY]:
			continue
		
		var drain := tip_decay_ordered if c.has_ordered else tip_decay_waiting
		c.points -= percent_to_tip(drain) * delta
		c.points  = maxf(c.points, 0.0)
		SignalBus.customer_ticked.emit(c)

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

	SignalBus.customer_left_angry.emit(c)
	SignalBus.queue_changed.emit()
	LogWrapper.debug(self, "Customer %s left angry." % c)


func _find(customer_id: int) -> CustomerData:
	for c in queue:
		if c.id == customer_id:
			return c
	return null


static func weighted_pick(weights: Dictionary) -> Variant:
	var total := 0
	for w: int in weights.values():
		total += w
	var roll := randi() % total
	var cumul := 0
	for key: Variant in weights:
		cumul += weights[key]
		if roll < cumul:
			return key
	return weights.keys().back()


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
