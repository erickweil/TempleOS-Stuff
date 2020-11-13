import time
import sys
import socket
import ssl

CHAR_END = "~"
#chunks of 80 bytes
CZ = 80
CHUNK_DELAY = 0.010


# Will ignore some data after te char_end
def recv_timeout(the_socket,timeout=2,char_end=None):
	the_socket.setblocking(0)
	total_data=[];data='';begin=time.time()
	while 1:
		if timeout > 0:
			#if you got some data, then break after wait sec
			if total_data and time.time()-begin>timeout:
				break
			#if you got no data at all, wait a little longer
			elif time.time()-begin>timeout*2:
				break
		try:
			data=the_socket.recv(4096)
			if data:
				data = data.decode(encoding='UTF-8',errors='ignore')
				if char_end and char_end in data:
					data = data[:data.find(char_end)]
					total_data.append(data)
					break
				total_data.append(data)
				begin=time.time()
			else:
				time.sleep(0.01)
		except KeyboardInterrupt as e:
			raise
		except Exception as e:
			pass
			#print(e)
	return "".join(total_data)

def sendall(sock,message,char_end):
	#Pseudo URL Encode
	message.replace("%", "%25")
	message.replace(char_end, "%7E")

	#convert to bytes
	some_data = str.encode(message+char_end+"\n")
	print("writing message")
	n_chunks = int(len(some_data)/CZ)
	for k in range(n_chunks):
		chunk = some_data[k*CZ:(k+1)*CZ]
		sock.sendall(chunk)
		time.sleep(CHUNK_DELAY)
	
	n_remain = len(some_data) - n_chunks * CZ
	if n_remain > 0:
		chunk = some_data[n_chunks*CZ:]
		sock.sendall(chunk)
		time.sleep(CHUNK_DELAY)

def commandLoop(sock):
	print("commandLoop. waiting...")
	receivedString = recv_timeout(sock,timeout=-1,char_end=CHAR_END)
	print(f"(Command)>{receivedString}")
	try:
		if receivedString == "PING":
			sendall(sock,"OK",CHAR_END)
		elif receivedString == "INPUT":
			sendall(sock,input(">"),CHAR_END)
		elif receivedString == "CONNECT":
			sendall(sock,"OK",CHAR_END)
			
			host = recv_timeout(sock,timeout=1000,char_end=CHAR_END)
			sendall(sock,"OK",CHAR_END)
			
			port = int(recv_timeout(sock,timeout=1000,char_end=CHAR_END))
			sendall(sock,"OK",CHAR_END)
			
			print("Connecting on '"+host+"':"+str(port))
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.connect((host, port))
			if port == 443:
				context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
				s = context.wrap_socket(s, server_hostname=host)
			
			print("Reading data to send:")
			message = recv_timeout(sock,timeout=1000,char_end=CHAR_END)
			if message:
				print("sending:")
				s.sendall(str.encode(message))
			
			#data = s.recv(1024)
			print("Waiting server response:")
			response = recv_timeout(s)	
			
			print(response)
			
			print("Sending server response:")
			sendall(sock,response,CHAR_END)
			
			s.close()
			#print('Received', repr(data))
		else:
			print("Unknown command, ignored")
			sendall(sock,"ERR",CHAR_END)
	except Exception as e:
		print(e)
		sendall(sock,"ERR",CHAR_END)

def pipe_server(port):

	print("starting...")
	# Create a TCP/IP socket
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	# Bind the socket to the port
	server_address = ('localhost', port)
	print("starting up on:"+str(server_address))
	sock.bind(server_address)
	# Listen for incoming connections
	sock.listen(1)

	while True:
		# Wait for a connection
		print("waiting for a connection")
		try:
			connection, client_address = sock.accept()
			print("got client")
			print(client_address)
			while True:
				try:
					commandLoop(connection)
					time.sleep(0.001)
				except KeyboardInterrupt:
					return
				except Exception as e:
					print(e)
		finally:
			print("finished now")
			connection.close()

if __name__ == '__main__':
	if len(sys.argv) < 2:
		print("need port")
	else :
		pipe_server(int(sys.argv[1]))
