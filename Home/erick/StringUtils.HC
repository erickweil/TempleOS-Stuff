//
//Helo, here lies all String-related functions
//
//SU_centralize truncates and centralizes a string
//
//
//

// Tem que dar Free quando usa MAlloc
U8 *chars = NULL;

U0 SU_initBuffer(I64 size)
{
  chars = MAlloc(size+1);
  chars[size] = '\0';
}

U0 SU_freeBuffer()
{
  if(chars) Free(chars);
}


// Truncates src to max chars, taking row offset,
// centralize when smaller than max
//
// Example: SU_centralize("abc",8,0)
// returns '  abc   '
// Example2: SU_centralize("abc",8,1)
// returns '        '

// Another yet Example
//C:/Home>Print(SU_centralize("abcdefghijkl",8,0));
$FG$$BG$//abcdefgh0.000005s
//C:/Home>Print(SU_centralize("abcdefghijkl",8,1));
$FG$$BG$//  ijkl  0.000005s
//C:/Home>
//
U8 *SU_centralize(U8 *src,I64 max,I64 row)
{
  if(!chars)
  {
    SU_initBuffer(max);
  }
  else if(StrLen(chars) != max)
  {
    //Print("Re-Creating");
    SU_freeBuffer();
    SU_initBuffer(max);  
  }
  
  I64 src_len = StrLen(src);
  if(src_len == max && row == 0) return src;
  
  I64 i;
  I64 rI;
  if(src_len >= (row+1)*max)
  {
    
    for(i =0;i<max;i++)
    {
      rI = i+row*max;
      if(rI >= row*max && rI<src_len)
      chars[i] = src[rI];
      else
      chars[i] = ' ';
    }
    //if(i<=max)
    //{
    //  chars[i] = '\0';
    //}
    return chars;
  }
  else
  {
    //               max - row_len
    I64 row_off = max - (src_len % max));
    for(i =0;i<max;i++)
    {
      //rI = (i-row_off/2)+(row*max);
      rI = (i-row_off/2)+(row*max);
     
      if(rI >= row*max && rI<src_len)
      chars[i] = src[rI];
      else
      chars[i] = ' ';
    }
    
    return chars;
  }
}



//Print("'");
//Print(SU_centralize("abcdefghijklmnop",12,0));
//Print("'\n'");
//Print(SU_centralize("abcdefghijklmnop",12,1));
//Print("'\n");

//SU_freeBuffer;