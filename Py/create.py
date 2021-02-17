from __future__ import print_function
#badchars 00 23 3c 83 ba
bad = "00 07 2e a0".split()
for x in range(1, 256):
	if "{:02x}".format(x) not in bad:
		print("\\x" + "{:02x}".format(x), end='')
print()
for byte in bad:
	print("\\x{}".format(byte), end='')
print()

