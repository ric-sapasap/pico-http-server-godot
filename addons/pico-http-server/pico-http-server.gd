class_name HttpServer
extends Node

var _tcp_server: TCPServer

func start_server(bind_address: String, port: int) -> void:
	self._tcp_server = TCPServer.new()
	var err = self._tcp_server.listen(port, bind_address)
	if err:
		printerr("Still failing!")
	print("LISTENING ", bind_address, ":", port)

func stop_server():
	if self._tcp_server.is_listening():
		self._tcp_server.stop()

func _process(delta: float) -> void:
	if not self._tcp_server.is_listening():
		return

	if self._tcp_server.is_connection_available():
		var conn := self._tcp_server.take_connection()
		if conn:
			_handle_connection(conn)

func _handle_connection(conn: StreamPeerTCP) -> void:
	var buffer := PackedByteArray()
	var start_ms := Time.get_ticks_msec()
	var max_wait_ms := 1000

	while Time.get_ticks_msec() - start_ms < max_wait_ms:
		var available := conn.get_available_bytes()
		if available > 0:
			var res := conn.get_data(available)
			if res[0] == OK:
				buffer.append_array(res[1])
				var text := buffer.get_string_from_utf8()
				if "\r\n\r\n" in text:
					break
		else:
			OS.delay_msec(10)
			
	var request_text := buffer.get_string_from_utf8()
	
	#var body = "<h1>Hello world</h1>"
	#var body_bytes := body.to_utf8_buffer()
	
	var location = "https://google.com"
	
	var response := ""
	response += "HTTP/1.1 302 FOUND\r\n"
	response += "Location: %s\r\n" % location
	response += "Content-Length: 0\r\n"
	#response += "Content-Type: text/html\r\n"
	#response += "Content-Length: %d\r\n" % body_bytes.size()
	response += "Connection: close\r\n\r\n"

	conn.put_data(response.to_utf8_buffer())
	#conn.put_data(body_bytes)
	conn.disconnect_from_host()
