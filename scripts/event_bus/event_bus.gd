extends Node

@onready var bus_service = $EventBusService

func service() -> EventBusService:
    return bus_service
