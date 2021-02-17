#!/usr/bin/python3
 
import socket 
import sys 
import ipaddress

if len(sys.argv) != 2: 
	print ("Usage: vrfy.py <username>") 
	sys.exit(0) 

IP = input ("Enter Target : ")
PORT = int(input ("Enter Port: "))
# Create a Socket 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

# Connect to the Server 
connect = s.connect((IP,PORT)) 

# Receive the banner 
banner = s.recv(1024) 
print (banner) 

# VRFY a user
command = 'VRFY ' + sys.argv[1] + '\r\n' 
s.sendall(command.encode('utf-8')) 
result = s.recv(1024) 

print (result) 

# Close the socket 
s.close()
