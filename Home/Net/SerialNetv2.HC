// YOU NEEDTOTHISINCLUDEASADAM
//#include "::/Home/Net/Comm"

// See $LK,"Comm",A="FI:Comm.HC"$
// static what that means??
static CComm *serial = NULL;
I64 serial_port = -1;

/*
 $LK,"General Com Port Serial communication. Works for any COM connection"$

 unable to read faster than 80 chars per millisecond (at 9600)

 - First call SerialBegin.
 - Then use the functions below
*/

// functions below need SerialBegin to work or throw error
U0 SerialThrow(){ 
  Print("Need to call SerialBegin First\n"); throw('NOSERIAL'); 
}

U0 SerialFlush()
{// Clear incoming data buffer
  U8 chr;
  while(FifoU8Rem(serial->RX_fifo,&chr)){}

  FifoI64Flush(serial->RX_fifo);

  // Is this really needed?
  //U8 null_buffer[4096];
  //RepInU8(null_buffer,4096,serial->base);
}

U8 SerialRead()
{// Returns the first byte of incoming data (blocking)
  U8 chr;
  while(TRUE) 
  {
    if(FifoU8Rem(serial->RX_fifo,&chr))
      return chr;
    else
      Yield;
  }
}

I64 SerialReadStringUntil(U8 *buffer,I64 buffersz,I64 terminator)
{// Reads the String into the buffer until terminator or buffersz
 // Returns the number of chars read
  if(!serial)SerialThrow;
 
  I64 k=0;
  while(k<buffersz)
  {
    if(FifoU8Rem(serial->RX_fifo,buffer))
    {
      if(*buffer == terminator)
      {
        buffer++;
        k++; 
        *buffer = '\0';
        return k;
      }
      buffer++;
      k++;
    }
    else
    {
      Yield;
    }
  }
  return k;
}

U0 SerialReadStringOut(I64 terminator,I64 max=10000)
{// Print Serial data directly (may be slow on lots of data)
// handlea the $$ thing
  if(!serial)SerialThrow;

  U8 chr;
  I64 k=0;
  while(k<max)
  {
    //Print("Fifo Count: %d\n",FifoU8Cnt(serial->RX_fifo));
      
    if(FifoU8Rem(serial->RX_fifo,&chr))
    {
      if(chr == terminator)
      {
        return;
      }
      if(chr < ' ' && chr != '\n' && chr != '\t' && chr != '\r')
      {
        Print("\\%d",chr);
      }
      else if(chr == '$$')
      {
        Print("$$$$");
      }
      else
        Print("%c",chr);
      
      k++;
    }
    else
    {
      Yield;
    }
  }
}

U0 SerialBegin(I64 port,I64 baudrate)
{// Starts the Serial port with a baudrate
  if(serial){
    Print("Serial Already Created \n");
    return;
  }
  serial_port = port;
  serial = CommInit8n1(serial_port,baudrate);
  SerialFlush();  
}

U0 SerialWrite(U8 chr)
{// Send byte values
  CommPutChar(serial_port,chr);  
}


U0 SerialWriteString(U8 *chr)
{// Send buffer
  CommPutS(serial_port,chr);  
}

U0 SerialPrint(U8 *fmt,...)
{// Print formated strings, just like Print, but on serial
  U8 *buf=StrPrintJoin(NULL,fmt,argc,argv);
  CommPutS(serial_port,buf);
  Free(buf);
}

/*
 $LK,"Tunnel protocol Only, need server waiting"$

 
*/
U8 CHAR_END = '~';

U0 TunnelPing()
{
  SerialPrint("PING%c",CHAR_END);
  SerialReadStringOut(CHAR_END);  
}

// Useful for Ctrl+c
U0 TunnelReadInput()
{
  SerialPrint("INPUT%c",CHAR_END);
  SerialReadStringOut(CHAR_END);    
}

// Internet!
// Only works with a single request-response style of connection
// Like HTTP
U0 TunnelConnect(U8 *host, I64 port, U8 *messagefmt,...)
{


  SerialPrint("CONNECT%c",CHAR_END);
  SerialReadStringOut(CHAR_END);
  

  SerialPrint("%s%c",host,CHAR_END);
  SerialReadStringOut(CHAR_END);


  SerialPrint("%d%c",port,CHAR_END);
  SerialReadStringOut(CHAR_END);


  U8 *buf=StrPrintJoin(NULL,messagefmt,argc,argv);

  SerialPrint("%s%c",buf,CHAR_END);
  
  Free(buf);

  Print("Start Response:\n");  
  SerialReadStringOut(CHAR_END);
  Print("\nEnd Response\n\n");  
}



//SerialBegin(1,9600);

//SerialPrint("PING~");
//SerialReadStringOut('~');
//Print("\n");

//TunnelConnect("neverssl.com",80,
//"GET /online HTTP/1.1\r\nHost: neverssl.com\r\nConnection: close\r\nCache-Control: max-age=0\r\nUser-Agent: TempleOS COM Port Wget like Internet\r\nAccept: */*\r\nAccept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7\r\n\r\n"
//);
