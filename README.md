# TempleOS-Stuff
TempleOS Stuff I Made

* Iconified Dir
For the Iconified Dir, copy those files (To this exact directories also) ::/Home/erick/hello.HC, ::/Home/erick/image.HC and ::/Home/erick/StringUtils.HC
then execute:

  #import "::/Home/erick/hello.HC"

  >Listdirs(1);
  
* PT-BR DolDoc Bible
  ::/Home/erick/biblia.DD

A long time ago I already downloaded and indexed the entire New World Translation of the PT-BR Bible, As a Scratch Project
You can see the Scratch project "The Entire Bible on Scratch!" from erickweil at https://scratch.mit.edu/projects/102991620/

So the entire bible is a giant blob of text and you have the index with numbers that give you offsets.

With a bit of math and reverse engeneering, i'm arrived at biblia.DD, a complete Brazilian Portuguese Bible in DolDoc format.

It uses the pseudo UTF-8 mapper.

* Pseudo UTF-8
  ::/Net/HtmlFunctions.HC
  
I'm not saying its full support, but it does work for most of the time.

It's mainly used by the Browser and in the PT-BR DolDoc Bible project.

* PT-BR Keyboard

For Brazilian people, PT-BR keyboard mappings. (Need to click on the PT-BR Keboard button, after this, only reboot to restore to EN).
Also Home and End goes to the start and end of line as expected. (shift that to go to start and end of file)

Look at the beggining of "::/Home/Once.HC" and  "::/Home/HomeKeyPlugIns.HC"

* 3D Cubes

Execute "::/Home/erick/Draw3D_v2.HC" and have fun!

* COM port Communication

"::/Home/Net/Comm.HC", "::/Home/Net/SerialNetv2.HC" and "/Python/namedPipes.py"

Initial tests with COM Ports, kinda works...
From inside TempleOS, it reads and writes the COM Ports I/O Addresses, 0x3f8 and so on,

I only tested inside VirtualBox in my Windows machine, with the COM1 port mapped as TCP client
and in my host machine I use a python script that acts as a server to read and write.

Data is chunked in slices and the python script waits a ACK to continue. that way
processing can delay a lot and yet no data will be lost.

* HTTP protocol, HTML Parsing and display, 'KC Browser'

(depends on a way to access the internet, so depends on COM)
"::/Home/Net/Http.HC", "::/Home/Net/HtmlParser.HC", "::/Home/Net/HtmlFunctions.HC", "::/Home/Net/KCBrowser.HC"

(Also because errors, it also depends on Custom Memory, unless you rename every CMCAlloc to CAlloc and CMFree to Free).

You can basically use the internet. Don't work very well.

All you need to do is to include the KC Browser file 
(After ADAM Including CustomMemory and setting up COM Communication). 

* Custom Memory

"::/Home/Net/CustomMem.HC"

In order to debug Memory related errors, such as BAD FREE, Kernel Panic and some others...
I made my own Alloc and Free methods with work in a pre-allocated block

Features:

- Every Alloc is padded by some bytes, Allowing a bit of overwrite
- Detect Leaks, Overwrites and Memory corruption in general
- Print Memory in a 'readable' way

To use this, first include as Adam and them replace every Alloc to CMCAlloc and every Free with CMFree

Please note that is only valid to CMFree buffers allocated with CMCAlloc
if call CMFree on CAlloc buffer throw a Exception.
and if call Free on a CMCAlloc buffer is undefined behaviour.

---

Saving them here so anyone can use and if I crash my machine, I'll not lose all.

"TempleOS is like a motorcycle, you can easily crash it"
