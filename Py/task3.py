import socket
import sys
import hashlib
import binascii
import cryptography.hazmat.backends 
import cryptography.hazmat.primitives.ciphers 

host = sys.argv[1]
port = 4000

def AES_GCM_decrypt(key, iv, ciphertext, tag):
	associated_data = ''
	decryptor = Cipher(algorithms.AES(key), modes.GCM(iv,tag), backend=default_backend()).decryptor()
	decryptor.authenticate_additional_data(associated_data)
	return decryptor.update(ciphertext) + decryptor.finalize()

def SHA256_hash(hash_string):
        sha_signature = hashlib.sha256(hash_string.encode()).hexdigest()
        return sha_signature

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect((host,port))

s.send(b'hello\n')
data = s.recv(2048)
print(data)

s.send(b'ready\n')
ready = s.recv(2048)
print(ready)
checksum = ready[104:136]
hex_checksum = checksum.hex()
print("checksum in hex: "+hex_checksum)

while 1:
	s.send(b'final\n')
	flag = s.recv(2048)

	s.send(b'final\n')
	tag = s.recv(2048)

	key = b'thisisaverysecretkeyl337'
	iv = b'secureivl337'
	ciphertext = bytes(flag)
	tag = bytes(tag)
	plaintext = AES_GCM_decrypt(key, iv, ciphertext, tag)

	hash_string = SHA256_hash(plaintext)
	if(hash_string == hex_checksum):
		print('flag is: '+plaintext)
		break

s.close()