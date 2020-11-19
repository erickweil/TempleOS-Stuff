import time
import sys
import socket
import ssl

CHAR_END = bytes(b'\x0B')#11
CHAR_ESC = bytes(b'\x7F')#127
#ENCODING = "windows-1252"
ENCODING = "utf-8"
#chunks of 128 bytes
CZ = 128

CHUNK_DELAY = 0.010


# Will ignore some data after te char_end
# return Bytearray
def recv_timeout(the_socket,timeout=2,char_end=None,printOut=True):
	the_socket.setblocking(0)
	total_data=bytearray();begin=time.time()
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
			#	data = data.decode(encoding=ENCODING,errors='replace')
			#	if char_end and char_end in data:
			#		data = data[:data.find(char_end)]
			#		if printOut:
			#			print(data, end='', flush=True)
			#		total_data.append(data)
			#		break
				if printOut:
					print(data.decode(encoding=ENCODING,errors='replace'), end='', flush=True)
				if char_end and char_end in data:
					data = data[:data.find(char_end)]
					total_data += data
					break
				total_data += data
				begin=time.time()
			else:
				time.sleep(0.01)
		except KeyboardInterrupt as e:
			raise
		except Exception as e:
			pass
			#print(e)
	return total_data

def sendchunk(sock,chunk,chunk_ack=False):
	sock.sendall(chunk)
	if chunk_ack:
		#print("Waiting ack... ", end='', flush=True)
		resp = recv_timeout(sock,timeout=5,char_end=CHAR_END,printOut=False)
		if not resp or len(resp) == 0:
			raise Exception(f"Unable to send chunk, ack:'{resp}'")
		#else:
		#print(" ack!")
	else:
		time.sleep(CHUNK_DELAY)
	
def sendall(sock,message,chunk_ack=False):
	#Pseudo
	
	#convert to bytes
	#some_data = bytearray(message.encode(encoding=ENCODING,errors='replace'))
	some_data = bytearray(message)
	
	some_data = some_data.replace(CHAR_ESC, CHAR_ESC+CHAR_ESC)
	some_data = some_data.replace(CHAR_END, CHAR_ESC+CHAR_END)
	
	some_data += CHAR_END
	
	n_chunks = int(len(some_data)/CZ)
	n_chunks_perc = int(n_chunks / 100)

	print(f"writing {str(n_chunks)} chunks. (Total {str(len(some_data))} bytes)")
	
	if n_chunks_perc == 0:
		print("["+("-"*n_chunks)+"]")
	else:
		print("["+("-"*100)+"]")
		
	print(" ",end='',flush=True)
	for k in range(n_chunks):
		chunk = some_data[k*CZ:(k+1)*CZ]
		sendchunk(sock,chunk,chunk_ack)
		if n_chunks_perc == 0:
			print(".",end='',flush=True)
		elif k > 0 and (k % n_chunks_perc) == 0:
			print(".",end='',flush=True)
	
	n_remain = len(some_data) - n_chunks * CZ
	if n_remain > 0:
		chunk = some_data[n_chunks*CZ:]
		print(f"writing last chunk [{str(n_chunks*CZ)}:] with a len of {str(len(chunk))}.")
		sendchunk(sock,chunk,chunk_ack)

	#Just in case...
	if n_remain == 1:
		chunk = CHAR_END
		print(f"writing a small char_end just in case.")
		sendchunk(sock,chunk,False)

def commandLoop(sock):
	print("commandLoop. waiting...")
	receivedString = recv_timeout(sock,timeout=-1,char_end=CHAR_END)
	print(f"(Command)>{receivedString}")
	try:
		if receivedString == b'PING':
			sendall(sock,b'OK')
		elif receivedString == b'INPUT':
			sendall(sock,input(">").encode(encoding=ENCODING,errors='replace'))
		elif receivedString == b'CONNECT':
			sendall(sock,b'OK')
			
			host = recv_timeout(sock,timeout=1,char_end=CHAR_END).decode(encoding=ENCODING,errors='replace')
			sendall(sock,b'OK')
			
			port = int(recv_timeout(sock,timeout=1,char_end=CHAR_END).decode(encoding=ENCODING,errors='replace'))
			sendall(sock,b'OK')
			
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
				s.sendall(message)
			
			#data = s.recv(1024)
			print("Waiting server response:")
			response = recv_timeout(s,timeout=1.5,char_end=None,printOut=False)	
			
			#print(response)
			
			print("Sending server response:")
			sendall(sock,response,chunk_ack=True)
			
			s.close()
			#print('Received', repr(data))
		else:
			print("Unknown command, ignored")
			sendall(sock,b'ERR')
	except Exception as e:
		print(e)
		sendall(sock,b'ERR')

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
