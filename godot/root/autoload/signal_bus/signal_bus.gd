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
