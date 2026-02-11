extends Node3D

@onready var http_server: HttpServer = $HttpServer

func _ready() -> void:
	http_server.start_server("127.0.0.1", 8080)
	http_server.on_request_accepted.connect(test)
	#server.register_path("GET" ,"/test", test)
	#server.on_connect.connect(_on_connect)

func test(request: String):
	print(request)

#
#func _on_connect(connection: StreamPeerTCP) -> void:
	#print("ON CONNECT")
