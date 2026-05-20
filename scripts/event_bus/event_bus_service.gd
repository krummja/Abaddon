class_name EventBusService
extends Node

@onready var subscriptions: Dictionary[String, Array] = {}

func subscribe(event_id: String, subscriber: Object, function_name: String) -> void:
    var subscription = EventSubscription.new(event_id, subscriber, function_name)
    _add_subscription(subscription)

func _add_subscription(subscription: EventSubscription) -> void:
    var event_id = subscription.event_id

    if not event_id in subscriptions:
        subscriptions[event_id] = [subscription]
    else:
        var existing_subs = subscriptions[event_id]
        for existing_sub in existing_subs:
            var subscriber_subscribed = subscription.subscriber == existing_sub.subscriber
            var function_subscribed = subscription.function_name == existing_sub.function_name
            if subscriber_subscribed and function_subscribed:
                return

        existing_subs.append(subscription)
        subscriptions[event_id] = existing_subs

func broadcast(event: Event) -> void:
    var event_id = event.event_id
    if event_id in subscriptions:
        var existing_subs = subscriptions[event_id]
        for existing_sub in existing_subs:
            var subscriber = existing_sub.subscriber

            if not is_instance_valid(subscriber):
                _garbage_collect(event_id, existing_subs, existing_sub)
                continue

            var function = existing_sub.function_name
            if not subscriber.has_method(function):
                continue

            subscriber.call(function, event)

func _garbage_collect(event_id: String, sub_array: Array, sub_to_remove: EventSubscription) -> void:
    var index_to_remove = sub_array.find(sub_to_remove)
    if index_to_remove >= 0:
        sub_array.remove_at(index_to_remove)
    subscriptions[event_id] = sub_array
