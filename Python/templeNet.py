import time
import sys
import socket
import ssl

CHAR_END = chr(255)
CHAR_ESC = chr(254)
ENCODING = "windows-1252"
#chunks of 128 bytes
CZ = 128

CHUNK_DELAY = 0.010


# Will ignore some data after te char_end
def recv_timeout(the_socket,timeout=2,char_end=None,printOut=True):
	the_socket.setblocking(0)
	total_data=[];data='';begin=time.time()
	while 1:
		if timeout > 0:
			#if you got some data, then break after wait sec
			if total_data and time.time()-begin>timeout:
				break
			#if you got no data at all, wait a little longer
			elif time.time()-begin>timeout*8:
				break
		try:
			data=the_socket.recv(4096)
			if data:
				data = data.decode(encoding=ENCODING,errors='replace')
				if char_end and char_end in data:
					data = data[:data.find(char_end)]
					if printOut:
						print(data, end='', flush=True)
					total_data.append(data)
					break
				if printOut:
					print(data, end='', flush=True)
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

def sendchunk(sock,chunk,chunk_ack=False):
	sock.sendall(chunk)
	if chunk_ack:
		print("Waiting ack... ", end='', flush=True)
		resp = recv_timeout(sock,timeout=5,char_end=CHAR_END)
		if not resp or len(resp) == 0:
			raise Exception(f"Unable to send chunk, ack:'{resp}'")
		else:
			print(" ack!")
	else:
		time.sleep(CHUNK_DELAY)
	
def sendall(sock,message,char_end,chunk_ack=False):
	#Pseudo
	message = message.replace(CHAR_ESC, CHAR_ESC+CHAR_ESC)
	message = message.replace(char_end, CHAR_ESC+char_end)

	#convert to bytes
	some_data = (message+char_end).encode(encoding=ENCODING,errors='replace')
	n_chunks = int(len(some_data)/CZ)
	print(f"writing {str(n_chunks)} chunks. (Total {str(len(some_data))} bytes)")
	for k in range(n_chunks):
		chunk = some_data[k*CZ:(k+1)*CZ]
		sendchunk(sock,chunk,chunk_ack)
	
	n_remain = len(some_data) - n_chunks * CZ
	if n_remain > 0:
		chunk = some_data[n_chunks*CZ:]
		print(f"writing last chunk [{str(n_chunks*CZ)}:] with a len of {str(len(chunk))}.")
		sendchunk(sock,chunk,chunk_ack)

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
			
			host = recv_timeout(sock,timeout=1,char_end=CHAR_END)
			sendall(sock,"OK",CHAR_END)
			
			port = int(recv_timeout(sock,timeout=1,char_end=CHAR_END))
			sendall(sock,"OK",CHAR_END)
			
			print("Connecting on '"+host+"':"+str(port))
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.connect((host, port))
			if port == 443:
				#context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
				context = ssl.SSLContext()
				s = context.wrap_socket(s, server_hostname=host)
			
			print("Reading data to send:")
			message = recv_timeout(sock,timeout=1,char_end=CHAR_END)
			if message:
				print("sending:")
				s.sendall(message.encode(encoding=ENCODING,errors='replace'))
			
			#data = s.recv(1024)
			print("Waiting server response:")
			response = recv_timeout(s,timeout=1,char_end=None,printOut=False)	
			
			#print(response)
			
			print("Sending server response:")
			sendall(sock,response,CHAR_END,chunk_ack=True)
			
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
