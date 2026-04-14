extends Node
## The [SignalBus] can be used to provide global signals.
## Use normal signals for child to parent communication, use global signals otherwise.
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

# Configuration
signal language_changed(locale: String)
signal number_format_changed(number_format: NumberUtils.NumberFormat)

# Game

## When pressing the counter buttons
signal take_order_button_pressed()
signal reject_button_pressed()
signal meal_served(meal: MealData)

## Camera signal when it changed its subject
## [param target] is either Vector2.UP or Vector2.DOWN
signal camera_target_changed(target: Vector2)

signal customer_added(customer: CustomerData)
signal customer_ticked(customer: CustomerData)
signal customer_state_changed(customer: CustomerData)
signal customer_left_angry(customer: CustomerData)
signal customer_served(customer: CustomerData, points_earned: int)
signal customer_bonus_malus_applied(customer: CustomerData, bonus_malus: float)
signal queue_changed()
