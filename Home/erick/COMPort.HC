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
#define COM1	0x3F8
#define COM2	0x2F8
#define COM3	0x3E8
#define COM4	0x2E8


#define BUFFERSZ	32
#define CHAR_END	'~'

// String buffer
U8 *buffer = CAlloc(BUFFERSZ);
I64 COM_PORT = COM1;
//buffer[BUFFERSZ-1] = "\0";
U0 SerialWrite(U8 *toWrite,I64 char_end)
{
  I64 k;
  for(k=0;k<StrLen(toWrite);k++)
  {
    OutU8(COM_PORT,toWrite[k]);
    Sleep(5);
    //Whitout the sleep(1)
    //The text sent in truncated or duplicated
  }
  OutU8(COM_PORT,char_end);
  Sleep(5);
}

U0 _serial_read()
{
  RepInU8(buffer,BUFFERSZ,COM_PORT);
}


U0 SerialReadUntil(U8 *out_buffer,I64 char_end,I64 max,I64 timeout=30000,I64 print=0)
{
  I64 out_i=0;
  for(;timeout>=0;timeout--)
  {
    _serial_read();
    I64 k;
    for(k=0;k<BUFFERSZ;k++)
    {
      if(buffer[k] > 0 && (out_i > 0 || buffer[k] != '\n'))
      {
        if(buffer[k] == char_end)
        {
          if(print==0)
          out_buffer[out_i] = '\0';
          
         
          return;
        }
        if(buffer[k] == '$$')
        {
          if(print==0)
          {
            out_buffer[out_i] = '$$';
            out_buffer[out_i+1] = '$$';
          }
          else Print("$$$$");
          
          out_i += 2;
        }
        else
        {
          if(print==0)
          out_buffer[out_i] = buffer[k];
          else
          Print("%c",buffer[k]);
          out_i++;
        }
        if(max > 0 && out_i >= max)
        {
          return;
        }   
      }    
    }
    Sleep(1);
  }
  if(print==0)
  out_buffer[out_i] = '\0';
}


U0 PrintReadSerialLine()
{
  U8 out[64];
  SerialReadUntil(out,CHAR_END,64,10000);
  Print("Size:%d,'%s'\n",StrLen(out),out);  
}


U0 SerialPing()
{
  U8 out[64];

  SerialWrite("PING",CHAR_END);

  SerialReadUntil(out,CHAR_END,64,1000);
  Print("Size:%d,'%s'\n",StrLen(out),out);
  
}

U0 SerialReadInput()
{
  U8 out[2000];

  SerialWrite("INPUT",CHAR_END);

  SerialReadUntil(out,CHAR_END,2000,15000);
  Print("Size:%d,'%s'\n",StrLen(out),out);
  
}

U0 SerialConnect(U8 *host, U8 *port, U8 *message)
{
  U8 out[2001];
  out[2000] = '\0';

  SerialWrite("CONNECT",CHAR_END);
  SerialReadUntil(NULL,CHAR_END,-1,65000,1);
  

  SerialWrite(host,CHAR_END);
  SerialReadUntil(NULL,CHAR_END,-1,65000,1);


  SerialWrite(port,CHAR_END);
  SerialReadUntil(NULL,CHAR_END,-1,65000,1);


  SerialWrite(message,CHAR_END);

  Print("Start Response:\n");  
  SerialReadUntil(NULL,CHAR_END,-1,65000,1);
  Print("\nEnd Response\n\n");  
}

SerialConnect("neverssl.com","80",
"GET /online HTTP/1.1\r\nHost: neverssl.com\r\nConnection: close\r\nCache-Control: max-age=0\r\nUser-Agent: TempleOS COM Port Wget like Internet\r\nAccept: */*\r\nAccept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7\r\n\r\n"
);

// `Flush`
SerialReadUntil(NULL,CHAR_END,-1,1000,1);

//SerialReadInput();
//SerialPing();
//I64 ch = 0;
//while (!(ch=ScanChar) || (ch!=CH_SHIFT_ESC && ch!=CH_ESC))
//{
//PrintReadSerialLine();
//}


U0 SerialInteractive()
{
I64 ch = 0;

I64 printed = 0;

while (!(ch=ScanChar) || (ch!=CH_SHIFT_ESC && ch!=CH_ESC))
{
  RepInU8(buffer,BUFFERSZ,COM1);
  //buffer[0] = InU8(COM1);
  I64 k = 0;
  I64 received = 0;
  
  //Print("MyBuffer:'");
  //Print(buffer);
  //Print("'\n");
  
  //Print("Parsed:'");
  //if(FALSE) 
  for(k=0;k<BUFFERSZ;k++)
  {
    // for some reason, this is invalid
    //U8 MyBuff = buffer[k];
 
    if(buffer[k] > 0)
    {
      if(buffer[k] == '\n')
      {//Don`t  //Print("$$GREEN$$\\n$$FG$$");
      }
      else
      {
      if(buffer[k] == '\r')Print("$$GREEN$$\\r$$FG$$");
      else if(buffer[k] == '\t')Print("$$GREEN$$\\t$$FG$$");
      else if(buffer[k] == ' ')
      {
        Print("$$GREEN$$.$$FG$$");
      }
      else
      Print("%c",buffer[k]);
      
      received++;
      printed++;
      }
    }
  }
  //Print("'\n");
   
  if(printed > 60)
  {
    Print("!\n");
    printed = 0;
  }
  
  Sleep(5);
}

Free(buffer);
}