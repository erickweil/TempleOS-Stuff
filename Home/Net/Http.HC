// Adam include the following before this
//#include "::/Home/Net/SerialNetv2"

// Send HTTP requests
// use 80 for HTTP and 443 for HTTPS.
// The python tunnel uses a ssl wrapper when on port 443
//#define CHUNK_SIZE	128
#define ITER_SIZE	128

// Imagine someone actually using the internet with this

U8 *USER_AGENT = "TempleOS COM Port Tunneled Internet";



// Iterator
// This way each buffer sized processing can take up to 5 secs
// and no character will be lost, also no RX buffer overflow happens
U8 *iterBuffer = NULL;
I64 iter_i=0;
I64 iter_k=0;
I64 iter_len=0;
I64 iter_read=-1;

U0 HttpResetIter()
{
  if(iterBuffer) Free(iterBuffer);

  iterBuffer = CAlloc(ITER_SIZE+1);
  iter_i=0;
  iter_k=0;
  iter_len=0;
  iter_read=-1;
}

U8 *TestOffline = NULL;

I64 HttpNextChar()
{
  if(TestOffline)
  {
    if(iter_i >= StrLen(TestOffline))
      return -1;
    
    return TestOffline[iter_i++];  
  }


  if(iter_i >= iter_len)
  {
    if(iter_read > 0 && iter_read < ITER_SIZE)
    {
      return -1;
    }
    I64 tk = iter_k;
    iter_k = SerialReadString(iterBuffer,CHAR_END,iter_k,ITER_SIZE,CHUNK_SIZE);
    iter_read = iter_k-tk;
    iter_len = StrLen(iterBuffer);
    iter_i = 0;
  }
  
  return iterBuffer[iter_i++];
}

// Uses Fmt... should re-avalie
I64 HttpNextMatch(U8 *outBuffer,I64 max,U8 *match)
{
// $IV,1$StrLen(match) should be < max$IV,0$

//Fills the null-terminated buffer
// until find a multi-char case-insensitive match
// returns last chr, or -1 when end of input

// Also, may go beyond max. restarting the buffer then...

if(!match) throw('NULL');

//U8 *match=StrPrintJoin(NULL,matchfmt,argc,argv);

//Print("Matching '%s'... \n",match);
U8 *outBufferOrig = outBuffer;
I64 chr;
I64 k = 0, matchlen = StrLen(match);
while((chr = HttpNextChar())!=-1)
{
  if(k == max)
  { 
    Print("Next Match matching '%s' Reached Max!\n",match);
    // this should work...
//    StrCpy(outBuffer-k,outBuffer-matchlen);

    // It may lose the end if it happens to be split...
    outBuffer = outBufferOrig;
    k=0;
  }

  if(k < max)
  {
    *outBuffer=chr;
    outBuffer++;
    *outBuffer = '\0';  
  }  
   

  k++;

  if(k >= matchlen && StrICmp(outBuffer-matchlen,match)==0)
  {
    //Print("Matched! '%s' == '%s' \n",outBuffer-matchlen,match);
    outBuffer = outBuffer-matchlen;
    break;
  }
}

*outBuffer = '\0';

//Free(match);

//Print("Matched at %d/%d last '%c'\n",k,max,chr);
 

return chr;
}


I64 HttpNextWord(U8 *outBuffer,I64 max=4096,I64 ignoreBelow=' ')
{
//First skip any non-printable
//then Fills the null-terminated buffer with a word (a-zA-Z0-9!/-)
// returns last chr, or -1 when end of input
I64 chr;
I64 k = 0;
while((chr = HttpNextChar())!=-1 && k < max)
{
  if(k == 0 && (chr <= ignoreBelow))
  {
    //ignore
  }
  else if( (chr >= 'a' && chr <= 'z')
  ||  (chr >= 'A' && chr <= 'Z')
  ||  (chr >= '0' && chr <= '9')
  ||  chr == '!' || chr == '/' || chr == '-' // For !Doctype, !--, and /tag
  )
  {
    *outBuffer=chr;
    outBuffer++;
    k++;
  }
  else break;
}

*outBuffer = '\0';

return chr;
}


I64 HttpNextString(U8 *outBuffer,I64 max=4096,I64 quoteA='"',I64 quoteB='\'')
{
//first find the quote type, then match, escaping
//then Fills the null-terminated buffer with a word (a-zA-Z0-9!/-)
// returns last chr, or -1 when end of input
I64 chr,lchr=-1;
I64 k = 0;
I64 quote = -1;
while((chr = HttpNextChar())!=-1 && k < max)
{
  if(quote == -1)
  {
    if(chr != quoteA && chr != quoteB)
    {
      if(chr <= ' ')
      {// ignore
      }
      else break; 
    }
    else
    {
      quote = chr;
    }
  }
  else
  {
    if(lchr == '\\')
    {
      if(chr == 'n')chr = '\n';
      if(chr == 'r')chr = '\r';
      if(chr == 't')chr = '\t';

      *outBuffer=chr;
      outBuffer++;
      k++;
      lchr = chr;    
    }
    else if(chr == '\\'){lchr = chr;}
    else if(chr == quote)
    {
      break;
    }
    else
    {
      *outBuffer=chr;
      outBuffer++;
      k++;
      lchr = chr;
    }
  }
}

*outBuffer = '\0';

return chr;
}



I64 HttpNext(U8 *outBuffer,I64 max=4096,I64 ignore='\r',I64 terminator0='\n',I64 terminator1='\n')
{//Fills the null-terminated buffer
// ignores \r, stop on \n
// returns last chr, or -1 when end of input
I64 chr;
I64 k = 0;
while((chr = HttpNextChar())!=-1 && k < max)
{
  if(chr == ignore){}
  else if(chr == terminator0 || chr == terminator1){break;}
  else
  {
    *outBuffer=chr;
    outBuffer++;
  }
  k++;
}

*outBuffer = '\0';

return chr;
}


I64 HttpFill(U8 *outBuffer,I64 max=4096)
{//Fills the binary buffer till max or EOF
// returns size
// also null-terminates just in case.
I64 chr;
I64 k = 0;
while((chr = HttpNextChar())!=-1 && k < max)
{
  *outBuffer=chr;
  outBuffer++;

  k++;
}

*outBuffer = '\0';

return k;
}






U0 HttpGet(U8 *host,U8 *port,U8 *path,U8 *cookies=NULL,I64 printOut=1)
{

if(!cookies) cookies = "_nullcookie=null";

TunnelConnect(host,port,
"GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\nCache-Control: max-age=0\r\nUser-Agent: %s\r\nAccept: */*\r\nUpgrade-Insecure-Requests: 0\r\nAccept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7\r\nAccept-Charset:utf-8\r\nCookie: %s\r\n\r\n",
path,
host,
USER_AGENT,
cookies
);

if(printOut  == 1)
{
  SerialReadStringOut(CHAR_END,-1,CHUNK_SIZE);
}

}


DocNodeAttr *HttpParseHeaders(U8 *_buffer=NULL,I64 max=1024)
{
  U8 *buffer;
  if(!_buffer)
    buffer = CAlloc(1025);
  else
    buffer = _buffer;
  I64 last;
  
  Print("\nSTATUS: ");
  // Status
  last = HttpNext(buffer,max,'\r','\n','\n');  
  Print("%70ts\n\n",buffer);
  DocNodeAttr *firstHeader=DocNodeAttrNew("STATUS",buffer);
  DocNodeAttr *lastHeader=firstHeader;
  while(TRUE)
  {
    // One Header
    last = HttpNext(buffer,max,'\r',':','\n');
    if(last == -1 || StrLen(buffer) == 0)
    {
      break;
    }
  
    Print("%20ts:",buffer);
    DocNodeAttr *newHeader = DocNodeAttrNew(buffer);
  
    last = HttpNext(buffer,max,'\r','\n','\n');  
    Print("%49ts\n",buffer);
 
    if(buffer[0] == ' ')
    newHeader->value = StrNew(buffer+1);
    else
    newHeader->value = StrNew(buffer);
    
    lastHeader->next = newHeader;
    lastHeader = newHeader;
  }

  Print("\nEnd Headers\n\n");

  if(!_buffer)
    Free(buffer);    

  return firstHeader;
}