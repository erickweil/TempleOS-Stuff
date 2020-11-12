# TempleOS-Stuff
TempleOS Stuff I Made

* Iconified Dir
For the Iconified Dir, copy those files (To this exact directories also) ::/Home/erick/hello.HC, ::/Home/erick/image.HC and ::/Home/erick/StringUtils.HC
then execute:

  #import "::/Home/erick/hello.HC"

  >Listdirs(1);

* PT-BR Keyboard

For Brazilian people, PT-BR keyboard mappings. (Need to click on the PT-BR Keboard button, after this, only reboot to restore to EN).
Also Home and End goes to the start and end of line as expected. (shift that to go to start and end of file)

Look at the beggining of "::/Home/Once.HC" and  "::/Home/HomeKeyPlugIns.HC"

* 3D Cubes

Execute "::/Home/erick/Draw3D_v2.HC" and have fun!

* COM port Communication

"::/Home/erick/COMPort.HC" and "/Python/namedPipes.py"

Initial tests with COM Ports, kinda works...
From inside TempleOS, it reads and writes the COM Ports I/O Addresses, 0x3f8 and so on,
Reading data worked very well, but writing is yet a Work in Progress( Gives a BSD, BLACK Screen of Death).

I only tested inside VirtualBox in my Windows machine, with the COM1 port mapped as the pipe "\\.\pipe\COM1"
and in my host machine I use a python script to read and write to this pipe.

---

Saving them here so anyone can use and if I crash my machine, I'll not lose all.

"TempleOS is like a motorcycle, you can easily crash it"
