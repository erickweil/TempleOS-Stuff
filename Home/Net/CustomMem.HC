// That way I can analyze problems with memory somehow.
// You should ADAM Include this, so no problem with Free after a exception also

U8 *CMEM_BLOCK = NULL;
I64 CMEM_SZ = 0;
I64 CMEM_I = 0;
I64 CMEM_PAD = 0;
I64 CMEM_N = 0; // Help keep track

// Stats
I64 CMEM_Allocs = 0;
I64 CMEM_Frees = 0;
I64 CMEM_SumUsed = 0;
I64 CMEM_Used = 0;
I64 CMEM_MaxUsed = 0;
//I64 CMEM_ = 0;


// Alloc the custom block
U0 CustomMemoryAlloc(I64 bytes,I64 padding,CTask *mem_task=NULL)
{
  CMEM_BLOCK = CAlloc(bytes*2,mem_task);// Alloc the double needed...
  MemSet(CMEM_BLOCK,'ÿ',bytes);// To help vizualize un-allocated memory  
  CMEM_PAD = padding;
  CMEM_SZ = bytes;

  CMEM_I = 0;
  CMEM_N = 0;

  CMEM_Allocs = 0;
  CMEM_Frees = 0;
  CMEM_SumUsed = 0;
  CMEM_Used = 0;
  CMEM_MaxUsed = 0;
}

// Free the custom block
U0 CustomMemoryReset(I64 clear=TRUE)
{
  CMEM_I = 0;
  CMEM_N = 0;

  CMEM_Allocs = 0;
  CMEM_Frees = 0;
  CMEM_SumUsed = 0;
  CMEM_Used = 0;
  CMEM_MaxUsed = 0;

  if(clear)
  MemSet(CMEM_BLOCK,'ÿ',CMEM_SZ);// To help vizualize un-allocated memory  
}

// Free the custom block
U0 CustomMemoryFree()
{
  Free(CMEM_BLOCK);
  CustomMemoryReset(FALSE);
  CMEM_BLOCK = NULL;
  CMEM_PAD = 0;
  CMEM_SZ = 0;
}

U0 CustomMemoryCheck()
{
  I64 j,k=0;
  Print("\nAllocs %d, Frees %d (left %d)\n",CMEM_Allocs,CMEM_Frees,(CMEM_Allocs-CMEM_Frees));
  Print("\nUsed %d bytes, Leaked %d (up to %d with FREE)\n",CMEM_SumUsed,CMEM_Used,CMEM_MaxUsed);
 
  Print("Checking Overwrites...\n");
  I64 errors = 0;
  for(k=0;k<CMEM_SZ;k++)
  {
    //ÿÿ0000Fÿ[....]PPPP
    if(CMEM_BLOCK[k] != 'ÿ'
    ||CMEM_BLOCK[k+1] != 'ÿ'
    ||!(CMEM_BLOCK[k+6] == 'ÿ' || CMEM_BLOCK[k+6] == 'F')
    ||CMEM_BLOCK[k+7] != 'ÿ')
    {
      Print("Underwrite on %d! '%c'\n",k,CMEM_BLOCK[k+1]);
      break;
    }

       
    if(
       CMEM_BLOCK[k+5] == 'ÿ'
    &&  CMEM_BLOCK[k+4] == 'ÿ'
    &&  CMEM_BLOCK[k+3] == 'ÿ'
    &&  CMEM_BLOCK[k+2] == 'ÿ'
    )
    {
      Print("End at %d (I at %d)\n\n",k,CMEM_I);
      break; // End of memory
    }
    
    if(
       CMEM_BLOCK[k+6] != 'F'
    )
    {
      if(errors<50)
      Print("Leak at %d\n",k);
      
      errors++;
      //break; // End of memory
    }
    

    I64 sz=0;
    sz = CMEM_BLOCK[k+5] | CMEM_BLOCK[k+4]<<8 | CMEM_BLOCK[k+3]<<16 | CMEM_BLOCK[k+2]<<24;
    k += 8;
    k += sz;

    if(k > CMEM_SZ)
    {
      Print("wrong size of %d on %d!\n",sz,k-sz);
      break;
    }

    I64 padchr = 'þ';
    for(j=0;j<CMEM_PAD;j++)
    {
      if(CMEM_BLOCK[k+j] != padchr)
      {
        if(errors<50)
        Print("Overwrite on %d '%c' != %c\n",k+j,CMEM_BLOCK[k+j],padchr);
        
        errors++;
        break;
      }
    }
    k+= CMEM_PAD-1; // because of the k++ of the loop
  }

}

// View Memory Block
U0 CustomMemoryPrint()
{
  I64 k,kdis=0;
  I64 lcolor = BLACK;

  CustomMemoryCheck();

  if(!YorN)
    return;

  Print("Mem block:\n$$BLACK$$\n");
  for(k=0;k<CMEM_SZ;k++)
  {
    if(kdis == 0)
    Print("\n%d-%d\n",k,k+(78*40));
    kdis++;
        
    if(k >= 78 && k % 78 == 0) Print("\n");
    
    I64 b = CMEM_BLOCK[k];
    if(b == '$$') 
    {
      if(lcolor != BLACK) PutChars('$$BLACK$$');  lcolor = BLACK;
      PutChars('$$$$');
    }
    else if(b == '~'+1)
    {  
      if(lcolor != GREEN) PutChars('$$GREEN$$');  lcolor = GREEN;
      PutChars('~');
    }
    else if(b >= ' ')
    {
      if(lcolor != BLACK) PutChars('$$BLACK$$');  lcolor = BLACK;
      PutChars(b);
    }
    else
    {
      if(lcolor != RED) PutChars('$$RED$$');  lcolor = RED;
    
      PutChars('0'+b);
    }
    
    
    if(kdis/78 >= 40)
    {
      if(YorN)
      {
        kdis=0;
        //DocTermNew;
        Sleep(100);
      }
      else
        return;
    }
    
  }
  Print("\n$$FG$$\n\n");
}


U8 *CMCAlloc(I64 size)
{//Accepts a $LK,"CTask",A="MN:CTask"$ or $LK,"CHeapCtrl",A="MN:CHeapCtrl"$.NULL allocs off current task's heap.
//  U8 *res=MAlloc(size,mem_task);
//  MemSet(res,0,size);
//  return res;

  //I need to provide a Pointer to a location with free size bytes
  
  if(CMEM_I+size+CMEM_PAD+8 >= CMEM_SZ)
  {
    Print("Custom Alloc Out Of Memory! %d >= %d",CMEM_I+size+CMEM_PAD+8,CMEM_SZ);
    //CustomMemoryReset(False);
    throw('OOM');
  }

  CMEM_I += 2;

  U8 *_res=CMEM_BLOCK+CMEM_I;  
  _res[3] =  size&0x000000FF;
  _res[2] = (size&0x0000FF00)>>8;
  _res[1] = (size&0x00FF0000)>>16;
  _res[0] = (size&0xFF000000)>>24;
  CMEM_I += 4; 


  
  CMEM_I += 2; 


  
  U8 *res = CMEM_BLOCK+CMEM_I;
  MemSet(res,0,size);  


  MemSet(res+size,'þ',CMEM_PAD);  
  CMEM_N++;

  CMEM_I += size; 
  CMEM_I += CMEM_PAD;

  CMEM_SumUsed += size;
  CMEM_Used += size;

  if(CMEM_Used > CMEM_MaxUsed)
    CMEM_MaxUsed = CMEM_Used;

  CMEM_Allocs++;
  return res;  
}

U0 CMFree(U8 *buffer)
{
  // Nothing...
  if(!buffer)
  {
    Print("Custom Free on NULL\n");
    //CustomMemoryReset;
    throw('NFREE');
  }
  if((buffer-6) < CMEM_BLOCK || buffer > CMEM_BLOCK+CMEM_SZ)
  {
    Print("Free Wrong\n");
    //CustomMemoryReset;
    throw('WRFREE');
  }
  if(*(buffer-2) == 'F')
  {
    Print("Free Twice\n");
    //CustomMemoryReset;
    throw('TWFREE');
  }
  if(*(buffer-2) != 'ÿ' || *(buffer-1) != 'ÿ')
  {
    Print("Free But Was Overwrited\n");
    //CustomMemoryReset;
    throw('OVFREE');
  }
  
  U8 *_res=(buffer-6);  
  I64 sz=0;
  sz = _res[3] | _res[2]<<8 | _res[1]<<16 | _res[0]<<24;  

  if(sz < 0 || sz > CMEM_SZ)
  {
    Print("Custom Memory Header Corrupted\n");
    //CustomMemoryReset;
    throw('OVFREE');
  }

  *(buffer-2)='F';

  CMEM_Used -= sz;
  
  CMEM_Frees++;
}


U8 *_CMConcatStr(U8 *SEP,I64 argc,I64 *argv)
{
  I64 k;
  I64 outLen = 1;//+1
  I64 sepLen = StrLen(SEP);
  for(k=0;k<argc;k++)
  {
    if(argv[k])
    {
      if(SEP && outLen > 1)
      {
        outLen += sepLen;
      }
      outLen += StrLen(argv[k]);
    }
  }
  if(outLen <= 1)
  {
    return NULL; 
  }

  U8 *buf = CMCAlloc(outLen);  
  I64 i=0,len=0;
  for(k=0;k<argc;k++)
  {
    len = StrLen(argv[k]);
    if(argv[k] && len > 0)
    {
      if(SEP && i > 0)
      {
        StrCpy(buf+i,SEP);
        i += sepLen;
      }
      StrCpy(buf+i,argv[k]);
      i+= len;
    }
  }
  return buf;
}

U8 *CMStr(...)
{
  return _CMConcatStr(NULL,argc,argv);
}

U8 *CMConcatStr(U8 *SEP,...)
{
  return _CMConcatStr(SEP,argc,argv);
}


U0 MyTestMem()
{
CustomMemoryAlloc(860,4);


U8 *bufa = CMCAlloc(8);
StrCpy(bufa,"Testea");

U8 *bufb = CMCAlloc(8);
StrCpy(bufb,"ABCDEFGHJ");

CMFree(bufb);

U8 *bufc = CMCAlloc(331);
StrCpy(bufc,"Ok");

CMFree(bufc);



CustomMemoryPrint();

CustomMemoryFree;

}


CustomMemoryAlloc(16777215,4);
//MyTestMem();