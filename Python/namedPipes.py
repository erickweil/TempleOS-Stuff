import time
import sys
import win32pipe, win32file, pywintypes
import socket

def recv_timeout(the_socket,timeout=2):
    the_socket.setblocking(0)
    total_data=[];data='';begin=time.time()
    while 1:
        #if you got some data, then break after wait sec
        if total_data and time.time()-begin>timeout:
            break
        #if you got no data at all, wait a little longer
        elif time.time()-begin>timeout*2:
            break
        try:
            data=the_socket.recv(8192)
            if data:
                total_data.append(data)
                begin=time.time()
            else:
                time.sleep(0.01)
        except:
            pass
    return b"".join(total_data)

def readPipeUntil(pipe,char_end,timeout):
	receivedString = ""
	while timeout !=0:
		buffer, bytesToRead, result = win32pipe.PeekNamedPipe(pipe, 1)
		
		if bytesToRead > 0:
			hr, data = win32file.ReadFile(pipe, bytesToRead)
			receivedString += data.decode(encoding='UTF-8',errors='ignore')			
			buffer, bytesToRead, result = win32pipe.PeekNamedPipe(pipe, 1)
		
		if char_end in receivedString:
			returnStr = receivedString[:receivedString.find(char_end)]
			print(f"(in)>'{returnStr}'")
			return returnStr
		
		time.sleep(0.0001)
		timeout -= 1
	print(f"(in Timeout!)>{receivedString}")
	return receivedString

def writePipe(pipe,message,char_end):
	#Pseudo URL Encode
	message.replace("%", "%25")
	message.replace(char_end, "%7E")

	#convert to bytes
	some_data = str.encode(message+char_end+"\n")
	print("writing message")
	win32file.WriteFile(pipe, some_data)
	time.sleep(0.001)

def commandLoop(pipe):
	# convert to bytes
	#some_data = str.encode(input(">")+"\n")
	#if len(some_data) == 0:
    #	break;
	#print(f"writing message {count}")
	#win32file.WriteFile(pipe, some_data)
	#time.sleep(0.01)
	#resp = win32file.ReadFile(pipe, 1024)
	CHAR_END = "~"
	
	receivedString = readPipeUntil(pipe,CHAR_END,-1)
	print(f"(Command)>{receivedString}")
	try:
		if receivedString == "PING":
			writePipe(pipe,"OK",CHAR_END)
		elif receivedString == "INPUT":
			writePipe(pipe,input(">"),CHAR_END)
		elif receivedString == "CONNECT":
			writePipe(pipe,"OK",CHAR_END)
			
			host = readPipeUntil(pipe,CHAR_END,1000)
			writePipe(pipe,"OK",CHAR_END)
			
			port = int(readPipeUntil(pipe,CHAR_END,1000))
			writePipe(pipe,"OK",CHAR_END)
			
			print("Connecting on '"+host+"':"+str(port))
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.connect((host, port))
			
			print("Reading data to send:")
			message = readPipeUntil(pipe,CHAR_END,1000)
			if message:
				print("sending:")
				s.sendall(str.encode(message))
			
			#data = s.recv(1024)
			print("Waiting server response:")
			response = recv_timeout(s).decode(encoding='UTF-8',errors='ignore')	
			
			print(response)
			
			print("Sending server response:")
			writePipe(pipe,response,CHAR_END)
			
			s.close()
			#print('Received', repr(data))
		else:
			print("Unknown command, ignored")
			writePipe(pipe,"ERR",CHAR_END)
	except Exception as e:
		print(e)
		writePipe(pipe,"ERR",CHAR_END)

def pipe_server(pipeName):
	print("pipe server")
	pipeName = "\\\\.\\pipe\\"+pipeName
	time.sleep(0.1)
	print(f"Creating: {pipeName}")
	pipe = win32pipe.CreateNamedPipe(
		pipeName,
		win32pipe.PIPE_ACCESS_DUPLEX,
		win32pipe.PIPE_TYPE_MESSAGE | win32pipe.PIPE_READMODE_MESSAGE | win32pipe.PIPE_WAIT,
		1, 65536, 65536,
		0,
		None)
	try:
		print("waiting for client")
		win32pipe.ConnectNamedPipe(pipe, None)
		print("got client")
		
		while True:
			try:
				commandLoop(pipe)
				time.sleep(0.001)
			except KeyboardInterrupt:
				return
			except Exception as e:
				print(e)
	finally:
		print("finished now")
		win32file.CloseHandle(pipe)


def pipe_client(pipeName):
	print("pipe client")
	quit = False
	pipeName = "\\\\.\\pipe\\"+pipeName
	
	while not quit:
		try:		
			time.sleep(0.1)
			print(f"Connecting to: {pipeName}")
			handle = win32file.CreateFile(
				pipeName,
				win32file.GENERIC_READ | win32file.GENERIC_WRITE,
				0,
				None,
				win32file.OPEN_EXISTING,
				0,
				None
			)
			res = win32pipe.SetNamedPipeHandleState(handle, win32pipe.PIPE_READMODE_MESSAGE, None, None)
			if res == 0:
				print(f"SetNamedPipeHandleState return code: {res}")
			while True:
				resp = win32file.ReadFile(handle, 64*1024)
				print(f"message: {resp}")
		except pywintypes.error as e:
			if e.args[0] == 2:
				print("no pipe, trying again in a sec")
				time.sleep(1)
			elif e.args[0] == 109:
				print("broken pipe, bye bye")
				quit = True


if __name__ == '__main__':
	if len(sys.argv) < 3:
		print("need s or c and pipeName as argument")
	elif sys.argv[1] == "s":
		pipe_server(sys.argv[2])
	elif sys.argv[1] == "c":
		pipe_client(sys.argv[2])
	else:
		print(f"no can do: {sys.argv[1]}")