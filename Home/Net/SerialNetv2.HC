// YOU NEED TO INCLUDE THIS AS ADAM OR BAD FREE IF RUN TWICE
#include "::/Home/Net/Comm"

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

I64 SerialReadString(U8 *buffer,I64 terminator,I64 k =0,I64 max=-1,I64 ack_chunk=-1)
{// Reads the String into the buffer until terminator or buffersz
 // Returns k (Not chars!)
  if(!serial)SerialThrow;

  I64 lchr;
  U8 chr=0;
  I64 tk = k;
  while(max < 0 || (k-tk)<max)
  {
    //Print("Fifo Count: %d\n",FifoU8Cnt(serial->RX_fifo));
    lchr = chr; 
    if(FifoU8Rem(serial->RX_fifo,&chr))
    {
      if(lchr == 254)
      {
        if(chr == 254)
        {
          *buffer = chr;buffer++; 
        }
        else if(chr == terminator)
        {
          *buffer = chr;buffer++;
        }
        // else nothing 
      }
      else if(chr == 254){}
      else if(chr == terminator)
      {
        if(ack_chunk > 0)
        {
          SerialPrint("OK%d%c",-1,terminator);   
        }
        *buffer = '\0';
        return k;
      }
      else
      {
        *buffer = chr;buffer++;
      }
      
      k++;
   
      if(ack_chunk > 0 && k >= ack_chunk && k % ack_chunk == 0)
      {
        SerialPrint("OK%d%c",k/ack_chunk,terminator);   
      }
      
    }
    else
    {
      Yield;
    }
  }
  *buffer = '\0';
  return k;
}

U0 SerialReadStringOut(I64 terminator,I64 max=-1,I64 ack_chunk=-1)
{// Print Serial data directly (may be slow on lots of data)
// handlea the $$ thing
  if(!serial)SerialThrow;

  I64 lchr;
  U8 chr=0;
  I64 k=0;
  while(max < 0 || k<max)
  {
    //Print("Fifo Count: %d\n",FifoU8Cnt(serial->RX_fifo));
    lchr = chr; 
    if(FifoU8Rem(serial->RX_fifo,&chr))
    {
      if(lchr == 254)
      {
        if(chr == 254)
        {
          Print("%c",chr); 
        }
        else if(chr == terminator)
        {
          Print("%c",chr);
        }
        // else nothing 
      }
      else if(chr == 254){}
      else if(chr == terminator)
      {
        if(ack_chunk > 0)
        {
          SerialPrint("OK%d%c",-1,terminator);   
        }
        return;
      }
      else if(chr < ' ' && chr != '\n' && chr != '\t' && chr != '\r')
      {
        Print("\\%d",chr);
      }
      else if(chr == '$$')
      {
        Print("$$$$");
      }
      else
        Print("%c",chr);
      
      k++;

      if(ack_chunk > 0 && k >= ack_chunk && k % ack_chunk == 0)
      {
        SerialPrint("OK%d%c",k/ack_chunk,terminator);   
      }
      
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
    // To prevent BAD_FREE
    // still happens if this file isn't included as adam
    Print("Serial Already Created \n");
    return;
  }
  serial_port = port;
  serial = CommInit8n1(serial_port,baudrate);
  SerialFlush();  
}

/*
 $LK,"Tunnel protocol Only, need server waiting"$

 
*/
U8 CHAR_END = 255;
I64 CHUNK_SIZE = 128;
I64 TunnelPing()
{
  SerialPrint("PING%c",CHAR_END);
  if(SerialRead() == 'O' && SerialRead() == 'K' && SerialRead() == CHAR_END)
  {
    return TRUE;
  }
  else
  {
    Print("Serial Comm Error, Ping Failed.\n");
    SerialReadStringOut(CHAR_END);
  }
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
U0 TunnelConnect(U8 *host, U8 *port, U8 *messagefmt,...)
{


  SerialPrint("CONNECT%c",CHAR_END);
  SerialReadStringOut(CHAR_END);
  

  SerialPrint("%s%c",host,CHAR_END);
  SerialReadStringOut(CHAR_END);


  SerialPrint("%s%c",port,CHAR_END);
  SerialReadStringOut(CHAR_END);


  U8 *buf=StrPrintJoin(NULL,messagefmt,argc,argv);

  SerialWriteString(buf);
  
  Free(buf);

  SerialPrint("%c",CHAR_END);

  //Print("Start Response:\n");  
  //SerialReadStringOut(CHAR_END,-1,CHUNK_SIZE);
  //Print("\nEnd Response\n\n");  
}


SerialBegin(1,9600);

//SerialPrint("PING%c",CHAR_END);
//SerialReadStringOut(CHAR_END);

//Print("\n");

//TunnelConnect("neverssl.com","80",
//"GET /online HTTP/1.1\r\nHost: neverssl.com\r\nConnection: close\r\nCache-Control: max-age=0\r\nUser-Agent: TempleOS COM Port Wget like Internet\r\nAccept: */*\r\nAccept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7\r\n\r\n"
//);
//SerialReadStringOut(CHAR_END,-1,CHUNK_SIZE);