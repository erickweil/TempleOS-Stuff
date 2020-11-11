/*
From the Wikipedia
The COM ports are interfaced by 
an integrated circuit such as 16
550 UART. This IC has seven inte
rnal 8-bit registers which hold 
information and configuration da
ta about which data is to be sen
t or was received, the baud rate
, interrupt configuration and mo
re. In the case of COM1, these r
egisters can be accessed by writ
ing to or reading from the I/O a
ddresses 0x3F8 to 0x3FF.

If the CPU, for example, wants to
send information out on COM1, it
writes to I/O port 0x3F8, as this 
I/O port is "connected" to the UA
RT IC register which holds the i
nformation that is to be sent ou
t.

The COM ports in PC-compatible computers are typically defined as:

COM1: I/O port 0x3F8, IRQ 4
COM2: I/O port 0x2F8, IRQ 3
COM3: I/O port 0x3E8, IRQ 4
COM4: I/O port 0x2E8, IRQ 3

*/
#define COM1	0x3f8
#define COM2	0x2f8
#define COM3	0x3E8
#define COM4	0x2E8


#define BUFFERSZ	32

// String buffer
U8 *buffer = CAlloc(BUFFERSZ);
//buffer[BUFFERSZ-1] = "\0";

I64 ch = 0;
I64 printed = 0;

while (!(ch=ScanChar) || (ch!=CH_SHIFT_ESC && ch!=CH_ESC))
{
  RepInU8(buffer,BUFFERSZ,COM1);
  //buffer[0] = InU8(COM1);
  I64 k = 0;
  I64 received = 0;
  for(k=0;k<BUFFERSZ;k++)
  {
    U8 MyBuff = buffer[k];
 
    if(MyBuff > 0)
    {
      if(MyBuff == '\n')Print("$$GREEN$$\\n$$FG$$");
      else if(MyBuff == '\r')Print("$$GREEN$$\\r$$FG$$");
      else if(MyBuff == '\t')Print("$$GREEN$$\\t$$FG$$");
      else if(MyBuff == ' ')
      {
        //if(received > 0)
        //{
          Print("$$GREEN$$.$$FG$$");
        //}
        //else
        //{
        //  received--;
        //  printed--;
        //}
      }
      else
      Print("%c",MyBuff);
      
      received++;
      printed++;
    }
  }
  if(printed > 60)
  {
    Print("!\n");
    printed = 0;
  }
  
  Sleep(1);
}

Free(buffer);