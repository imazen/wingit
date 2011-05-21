import os
import os.path
import pyperclip

# os.getenv('USERPROFILE') or os.getenv('HOME')

def copy(data):
	if os.name == 'nt':
		import ctypes
		winSetClipboard(data)
	else:
		macSetClipboard(data)

def getKeygenPath():
	if not os.name == 'nt': return 'ssh-keygen'
	
	for s in ["ProgramFiles", "ProgramFiles(x86)","ProgramW6432"]:
		if s in os.environ: path = os.path.join(os.environ[s], "Git\\bin\\ssh-keygen.exe")
		print "Looking for " + path
		if (os.path.isfile(path)): return path;
	print ("Git was not found on your system. Google 'msysgit', download, and install Git for Windows, then re-run this program")
	return None

def createKey(pubkey):
	keygen = getKeygenPath()
	if (keygen == None ): return
	
	print ('No key file was found. To create one, enter your primary e-mail address and hit enter.')
	print ('To quit, leave it blank and hit enter.')
	result = raw_input('Email address: ');
	if (not result.strip()): return
	
	email = result.strip()
	print
	print ('Using ' +  keygen)
	print
	print ('When prompted, just hit enter to use the defaults (4 times) ')
	print
	raw_input ("Press enter to execute 'ssh-keygen -t rsa -C " + email)
	if (os.name == 'nt'): 
		command = '\"\"""' + keygen + '\" -t rsa -C "' + email + '\""'
	else:
		command = "ssh-keygen -t rsa -C " + email
	
	os.system(command)
	
	if (os.path.isfile(pubkey)): 
		showKey(pubkey)
	else:
		print ('Public key not found at ', pubkey)
		print ('Please restart the program and try again. ')



def showKey(fname):
	print ('Key file found.')
	with open(fname, 'r') as f:
		contents = f.read()
	print ('Key data (copied to your clipboard):')
	print
	print (contents)
	pyperclip.setcb(contents.strip())
	


pubkey = os.path.expanduser("~/.ssh/id_rsa.pub") 


if (os.path.isfile(pubkey)): 
	showKey(pubkey)
else:
	createKey(pubkey)
	
	
print
print ('Press enter to exit')
raw_input()
