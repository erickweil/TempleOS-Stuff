// Ways to work with strings
// that don't over alloc
// the size in WStrBuilderNew should be not less than 1/10th of the
// expected size of the result, or this may become too inefficient
#define BUILDER_SZ	64

// Class to build a string char by char
public class WStrBuilder {
  // Piece of the String
  I32 i;
  WStrBuilder *next;

  U8 piece[BUILDER_SZ];
};

WStrBuilder *WStrBuilderNew()
{// Create a new DocNodeAttr DocNodeAttrDel
  WStrBuilder *res;
  res=CAlloc(sizeof(WStrBuilder));
  
  //res->piece = CMCAlloc(size+1);
  //res->piece[size] = '\0';

  res->i = 0;  
  res->next=NULL;
  return res;
}

U0 WStrBuilderDel(WStrBuilder *res,I64 doNext = TRUE)
{
  if (!res) return;

//  if(res->piece)
//    CMFree(res->piece);


  WStrBuilder *_res;
  if(!doNext)
  {
    Free(res);
  }
  else
  {
    _res = res;
    res = res->next;
    Free(_res); 

    while(res)
    {
      _res = res;
      res = res->next;
      WStrBuilderDel(_res,FALSE);
    }
  }
}

U0 WStrAddChr(WStrBuilder *sb,I64 chr)
{
  while(sb)
  {
    if(sb->i >= BUILDER_SZ)
    {
      if(!sb->next)
      {
        WStrBuilder *sb_new = WStrBuilderNew();
        sb->next = sb_new;
        sb = sb_new;
        break;
      }
      else
      {
        sb = sb->next;
      }
    }
    else break;
  }    

  if(sb)
  {
    sb->piece[sb->i] = chr;
    sb->i++;
  }
}

U0 WStrAddStr(WStrBuilder *sb,U8 *s,I64 len=-1)
{
  if(len == -1)len = StrLen(s);

  I64 k;

  for(k=0;k<len;k++)
  {
    WStrAddChr(sb,s[k]);
  }
}

I64 WStrSize(WStrBuilder *sb)
{
  I64 ret = 0;
  while(sb)
  {
    ret += sb->i;
    sb = sb->next;
  }

  return ret;
}

U8 *WStrBuild(WStrBuilder *sb,CTask *mem_task=NULL)
{
  U8 *ret = CAlloc(WStrSize(sb)+1,mem_task);//+1
  U8 *iter = ret;
  I64 size = 0;
  while(sb)
  {
    size = sb->i;

    MemCpy(iter,sb->piece,size);
    iter += size;

    sb = sb->next;
  }
  return ret;  
}

/*WStrBuilder *sb = WStrBuilderNew();
WStrAddStr(sb,"Testeeeee dsfsdfsf abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz");
WStrBuilderDel(sb);

U8 *result = WStrBuild(sb);
Print("%s\n",result);

CMFree(result);

CustomMemoryPrint;
CustomMemoryReset;
*/


// Percent encoding

//U8 *result = percentEncode("Teste d+e Encoding",TRUE);
//Print("%s\n",result);
//Free(result);


// Form Url Encoding
//U8 *result = FormUrlEncode("diga","ol ","para","aquele la");
//Print("%s\n",result);
//Free(result);

/*
U8 *WStrConcat(U8 *SEP,I64 argc,I64 *argv,CTask *mem_task=NULL)
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

  U8 *buf = CAlloc(outLen,mem_task);  

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

U8 *WStrNew(U8 *src,CTask *mem_task=NULL)
{
  return _CMConcatStr(NULL,argc,argv,FALSE,mem_task);
}
*/
