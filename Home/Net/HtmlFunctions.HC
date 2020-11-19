// Giant crappy looking code that just check things
I64 convertUnicode(I64 code)
{
/*
// Reddit

üëáüèªüëáüèªüëáüèª if you‚Äôre'!

 ($MA-X+PU,"Mateus 24:‚Å†14",LM="KCTest(\"/pt/biblioteca/biblia/biblia-de-estudo/livros/mateus/24/#v40024014\",\"https://www.jw.org:443/pt/biblioteca/revistas/sentinela-no2-2020-maio-jun/quando-reino-vai-governar-terra/\");View;\n"$) Enquanto o 
*/
if(code == 0xFFFD) return '?'; // Unicode replacement character


if(code < 0x7F) return code;

// C1 and Latin-1 80-FF
if(code >= 0xA0 && code<= 0xFF)
{
  switch(code)
  {
    // C1 Controls skipped.
    // Only first case need num
    case 0xA0: return ' ';
    case     : return '≠';
    case     : return 'õ';
    case     : return 'ú';
    case     : return 'Ë';
    case     : return 'ù';
    case     : return '¥';
    case     : return 'S';
    case     : return '"';
    case     : return '(C)';
    case     : return 'a';
    case     : return 'Æ';
    case     : return '™';
    case     : return '-';
    case     : return '(R)';
    case     : return 'ƒ';
    case     : return '¯';
    case     : return 'Ò';
    case     : return '2';
    case     : return '3';
    case     : return '\'';
    case     : return 'u';
    case     : return 'P';
    case     : return '˙';
    case     : return 'á';
    case     : return '1';
    case     : return '¯';
    case     : return 'Ø';
    case     : return '¨';
    case     : return '´';
    case     : return '3/4';
    case     : return '®';
    case     : return 'A';
    case     : return 'A';
    case     : return 'A';
    case     : return 'A';
    case     : return 'A';
    case     : return 'A';
    case     : return 'AE';
    case     : return 'C';
    case     : return 'E';
    case     : return 'E';
    case     : return 'E';
    case     : return 'E';
    case     : return 'I';
    case     : return 'I';
    case     : return 'I';
    case     : return 'I';
    case     : return 'D';
    case     : return 'N';
    case     : return 'O';
    case     : return 'O';
    case     : return 'O';
    case     : return 'O';
    case     : return 'O';
    case     : return 'X';
    case     : return '0';
    case     : return 'U';
    case     : return 'U';
    case     : return 'U';
    case     : return 'U';
    case     : return 'Y';
    case     : return 'D';
    case     : return 'B';
    case     : return 'Ö';
    case     : return '†';
    case     : return 'Ñ';
    case     : return 'É';
    case     : return 'Ñ';
    case     : return 'Ü';
    case     : return 'ae';
    case     : return 'Ä';
    case     : return 'ä';
    case     : return 'Ç';
    case     : return 'â';
    case     : return 'â';
    case     : return 'ç';
    case     : return '°';
    case     : return 'ã';
    case     : return 'ã';
    case     : return 'Î';
    case     : return '§';
    case     : return 'ï';
    case     : return '¢';
    case     : return 'î';
    case     : return 'ì';
    case     : return 'î';
    case     : return 'ˆ';
    case     : return '0';
    case     : return 'ó';
    case     : return '£';
    case     : return 'Å';
    case     : return 'Å';
    case     : return 'ò';
    case     : return 'b';
    case     : return 'ò';//0xFF
  }
}

// Dashes and quotes
if(code >= 0x2000 && code <= 0x202F)
{
  switch(code)
  {
    case 0x2000: 
    case       : 
    case       : 
    case       : return '  ';
    case 0x2004: 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
                 return ' ';
    case 0x200B: 
    case       : 
    case       : 
    case       : 
    case       : 
                 return '~'+1; // 0-width

    case 0x2010: return '-';
    case       : return '-';
    case       : return '-';
    case       : return '-';
    case       : return 'ƒ';
    case       : return 'ƒ';
    case       : return '∫';
    case       : return 'Õ';
    case       : return '`';
    case       : return '\'';
    case       : return ',';
    case       : return '\'';
    case       : return '"';
    case       : return '"';
    case       : return '"';
    case       : return '"';
    case       : return '≈';
    case       : return 'Œ';
    case       : return '˛';
    case       : return '˘';
    case       : return '';
    case       : return '';
    case       : return '';
    case       : return '˙';
    case       : return '\n';
    case       : return '\n';// 0x2029

    case 0x202A: 
    case       : 
    case       : 
    case       : 
    case       : 
                 return '~'+1; // 0-width
    case 0x202F: return ' ';
  }
}


if(code == 0x2039) return '<';
else if(code == 0x203A) return '>';


if(code == 0x205F) return ' ';
if(code >= 0x2060 && code <= 0x206F) return '~'+1; // Empty


// superscripts and subscripts
if(code >= 0x2070 && code <= 0x208E)
{
  switch(code)
  {
    case 0x2070: return '0';
    case 0x2071: return 'i';
    case 0x2074: return '4';
    case 0x2075: return '5';
    case 0x2076: return '6';
    case 0x2077: return '7';
    case 0x2078: return '8';
    case 0x2079: return '9';
    case 0x207A: return '+';
    case 0x207B: return '-';
    case 0x207C: return '=';
    case 0x207D: return '(';
    case 0x207E: return ')';
    case 0x207F: return 'n';
 
    case 0x2080: return '0';
    case       : return '1';
    case       : return '2';
    case       : return '3';
    case       : return '4';
    case       : return '5';
    case       : return '6';
    case       : return '7';
    case       : return '8';
    case       : return '9';
    case       : return '+';
    case       : return '-';
    case       : return '=';
    case       : return '(';
    case       : return ')';// 0x208E


  }
}

// Box
if(code >= 0x2500 && code <= 0x257F)
{
  switch(code)
  {
    case 0x2500: return 'ƒ';
    case       : return 'ƒ';
    case       : return '≥';
    case       : return '≥';
    case       : return 'ƒ';
    case       : return 'ƒ';
    case       : return '≥';
    case       : return '≥';
    case       : return 'ƒ';
    case       : return 'ƒ';
    case       : return '≥';
    case       : return '≥';
    case       : 
    case       : 
    case       : 
    case       : return '⁄';
 
    case 0x2510: 
    case       : 
    case       : 
    case       : return 'ø';
    case       : 
    case       : 
    case       : 
    case       : return '¿';
    case       :
    case       :
    case       :
    case       : return 'Ÿ';
    case       : 
    case       : 
    case       : 
    case       : 

    case 0x2520: 
    case       : 
    case       : 
    case       : return '√';
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : return '¥';
    case       : 
    case       : 
    case       : 
    case       : 

    case 0x2530: 
    case       : 
    case       : 
    case       : return '¬';
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : return '¡';
    case       : 
    case       : 
    case       : 
    case       : 

    case 0x2540: 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : 
    case       : return '≈';
    case       : return 'ƒ';
    case       : return 'ƒ';
    case       : return '≥';
    case       : return '≥';

    case 0x2550: return 'Õ';
    case       : return '∫';
    case       : return '’';
    case       : return '÷';
    case       : return '…';
    case       : return '∏';
    case       : return '∑';
    case       : return 'ª';
    case       : return '‘';
    case       : return '”';
    case       : return '»';
    case       : return 'æ';
    case       : return 'Ω';
    case       : return 'º';
    case       : return '∆';
    case       : return '«';

    case 0x2560: return 'Ã';
    case       : return 'µ';
    case       : return '∂';
    case       : return 'π';
    case       : return '—';
    case       : return '“';
    case       : return 'À';
    case       : return 'œ';
    case       : return '–';
    case       : return ' ';
    case       : return 'ÿ';
    case       : return '◊';
    case       : return 'Œ';
    case       : return '⁄';
    case       : return 'ø';
    case       : return 'Ÿ';

    case 0x2570: return '¿';
    case       : return '/';
    case       : return '\\';
    case       : return 'X';
    case       : return '-';
    case       : return '|';
    case       : return '-';
    case       : return '|';
    case       : return '-';
    case       : return '|';
    case       : return 'ƒ';
    case       : return '≥';
    case       : return 'ƒ';
    case       : return '≥';
    case       : return 'ƒ';
    case       : return '≥';// 0x257F

 }
}

if(code == 0x2580 || code == 0x2594) return 'ﬂ';
if(code >= 0x2581 && code <= 0x2587) return '‹';
if(code == 0x2588)                   return 'ˇ';
if(code >= 0x2589 && code <= 0x258F) return '›';
if(code == 0x2590 || code == 0x2595) return 'ﬁ';
if(code == 0x2591) return '∞';
if(code == 0x2592) return '±';
if(code == 0x2593) return '≤';



return -1;

}


I64 CheckN(U8 *buffer,...)
{
//  Print("CheckN(%s,...%d...)\n",buffer,argc);
  I64 i;
  for(i=0;i<argc;i++)
  {
    if(StrICmp(buffer,argv[i])==0)
      return TRUE;
  }
  return FALSE;
}

I64 CheckBlock(U8 *buffer)
{
  return CheckN(buffer,"address","article","aside","blockquote",
  "canvas","dd","div","dl","dt","fieldset","figcaption","figure",
  "footer","form","h1","h2","h3","h4","h5","h6","header","hr",
  "li","main","nav","noscript","ol","p","pre","section",
  "table","tfoot","ul","video",
  
  // Aren't block but whatever
  "tr"
  );
}


I64 CheckAutoClose(U8 *buffer)
{
  if(StrICmp(buffer,"br")==0
  || StrICmp(buffer,"img")==0
  || StrICmp(buffer,"meta")==0
  || StrICmp(buffer,"hr")==0
  || StrICmp(buffer,"input")==0
  || StrICmp(buffer,"area")==0
  || StrICmp(buffer,"base")==0
  || StrICmp(buffer,"col")==0
  || StrICmp(buffer,"embed")==0
  || StrICmp(buffer,"link")==0
  || StrICmp(buffer,"param")==0
  || StrICmp(buffer,"source")==0
  || StrICmp(buffer,"track")==0
  || StrICmp(buffer,"wbr")==0
  || StrICmp(buffer,"command")==0
  || StrICmp(buffer,"keygen")==0
  || StrICmp(buffer,"menuitem")==0
  )
  return TRUE;
  else
  return FALSE;
}

I64 CheckIsHidden(U8 *buffer)
{
//  return CheckN(buffer,"head","script","style");
  if(StrICmp(buffer,"meta")==0
  || StrICmp(buffer,"script")==0
  || StrICmp(buffer,"style")==0
  || StrICmp(buffer,"iframe")==0
  )
  return TRUE;
  else
  return FALSE;
}

I64 CheckEscapedContent(U8 *buffer)
{
  if(StrICmp(buffer,"script")==0
  || StrICmp(buffer,"style")==0
  )
  return TRUE;
  else
  return FALSE;
}


// Html Entities
I64 parseEntity(U8 *e,U8 *ematch)
{// returns the char
//the argument may be modified in place

  I64 eLen=0;
  if(!e || (eLen=StrLen(e))<=2 || e[0] != '&') return -1;

  // &??????
  //  0
  e = e+1;

  if(e[0] == '#')
  {
    //&#???????;
    //  i      0
    e = e+1;
    
    //U8 *ematch = StrMatch(";",e);
    if(ematch)
    {
      ematch[0] = '\0';
      I64 char_code;
      if(e[0] == 'x' || e[0] == 'X')// hex code
      {
        char_code = Str2I64(e+1,16);
      }
      else
      {
        char_code = Str2I64(e);
      }
      char_code = convertUnicode(char_code);

      ematch[0] = ';';
  
      return char_code;
    }
    else return -1;
  }
  else
  {
    //&???????;
    // i      

    switch(e[0])
    {
      case 'a':
        if(StrNCmp(e,"amp;",4)==0) return '&';
        if(StrNCmp(e,"apos;",5)==0) return '\'';
        if(StrNCmp(e,"acute;",6)==0) return '\'';
        if(StrNCmp(e,"AElig;",6)==0) return 'AE';
        if(StrNCmp(e,"alpha;",6)==0) return '‡';
        if(StrNCmp(e,"aelig;",6)==0) return 'ae';

      break;
      case 'b':
        if(StrNCmp(e,"bull;",5)==0) return '˛';
        if(StrNCmp(e,"brvbar;",7)==0) return '≥';
        if(StrNCmp(e,"beta;",5)==0) return '·';

      break;
      case 'c':
        if(StrNCmp(e,"cent;",5)==0) return 'õ';
        if(StrNCmp(e,"copy;",5)==0) return '(C)';
        if(StrNCmp(e,"curren;",7)==0) return 'Ë';
        if(StrNCmp(e,"cedil;",6)==0) return 'á';
        if(StrNCmp(e,"ccedil;",7)==0) return 'Ä';

      break;
      case 'd':
        if(StrNCmp(e,"deg;",4)==0) return '¯';
        if(StrNCmp(e,"divide;",7)==0) return 'ˆ';
        if(StrNCmp(e,"delta;",6)==0) return 'Î';

      break;
      case 'e':
        if(StrNCmp(e,"euro;",6)==0) return 'Ó';
        if(StrNCmp(e,"emsp;",6)==0) return '\t';
        if(StrNCmp(e,"ensp;",6)==0) return '  ';
        if(StrNCmp(e,"epsilon;",8)==0) return '‰';

      break;
      case 'f':
        if(StrNCmp(e,"frac14;",7)==0) return '¨';
        if(StrNCmp(e,"frac12;",7)==0) return '´';
        if(StrNCmp(e,"frac34;",7)==0) return '3/4';

      break;
      case 'g':
        if(StrNCmp(e,"gt;",3)==0) return '>';
        if(StrNCmp(e,"ge;",3)==0) return 'Ú';
        if(StrNCmp(e,"gamma;",6)==0) return 'Á';

      break;
      case 'h':
        if(StrNCmp(e,"hellip;",7)==0) return '...';

      break;
      case 'i':
        if(StrNCmp(e,"iexcl;",6)==0) return '≠';
        if(StrNCmp(e,"iquest;",7)==0) return '®';

      break;
      case 'j':break;
      case 'k':break;
      case 'l':
        if(StrNCmp(e,"lt;",3)==0) return '<';
        if(StrNCmp(e,"le;",3)==0) return 'Û';
        if(StrNCmp(e,"ldquo;",6)==0) return '"';
        if(StrNCmp(e,"lsquo;",6)==0) return '\'';
        if(StrNCmp(e,"larr;",5)==0) return 'Æ';
        if(StrNCmp(e,"laquo;",6)==0) return 'Æ';
        if(StrNCmp(e,"lsaquo;",7)==0) return '<';

      break;
      case 'm': 
        if(StrNCmp(e,"mdash;",6)==0) return 'ƒ';
        if(StrNCmp(e,"macr;",5)==0) return 'ƒ';
        if(StrNCmp(e,"micro;",6)==0) return 'Ê';
        if(StrNCmp(e,"middot;",7)==0) return '˘';
        if(StrNCmp(e,"minus;",6)==0) return '-';

      break;
      case 'n':
        if(StrNCmp(e,"nbsp;",5)==0) return ' ';
        if(StrNCmp(e,"ndash;",6)==0) return '-';
        if(StrNCmp(e,"not;",4)==0) return '™';

      break;
      case 'o':
        if(StrNCmp(e,"ordf;",5)==0) return 'a';
        if(StrNCmp(e,"ordm;",5)==0) return 'o';
        if(StrNCmp(e,"Omega;",6)==0) return 'Í';

      break;
      case 'p':
        if(StrNCmp(e,"pound;",6)==0) return 'ú';
        if(StrNCmp(e,"plusmn;",7)==0) return 'Ò';
        if(StrNCmp(e,"para;",5)==0) return 'P';
        if(StrNCmp(e,"pi;",3)==0) return '„';

      break;
      case 'q':
        if(StrNCmp(e,"quot;",5)==0) return '"';

      break;
      case 'r':
        if(StrNCmp(e,"reg;",4)==0) return '(R)';
        if(StrNCmp(e,"rdquo;",6)==0) return '"';
        if(StrNCmp(e,"rsquo;",6)==0) return '\'';
        if(StrNCmp(e,"rarr;",5)==0) return 'Ø';
        if(StrNCmp(e,"raquo;",6)==0) return 'Ø';
        if(StrNCmp(e,"rsaquo;",7)==0) return '>';

      break;
      case 's':
        if(StrNCmp(e,"sup1;",5)==0) return '1';
        if(StrNCmp(e,"sup2;",5)==0) return '2';
        if(StrNCmp(e,"sup3;",5)==0) return '3';
        if(StrNCmp(e,"sect;",5)==0) return 'S';
        if(StrNCmp(e,"shy;",4)==0) return '';
        if(StrNCmp(e,"sigma;",6)==0) return 'Â';
        if(StrNCmp(e,"sum;",4)==0) return '‰';
        if(StrNCmp(e,"sdot;",5)==0) return '˘';

      break;
      case 't':
        if(StrNCmp(e,"times;",6)==0) return 'X';
        if(StrNCmp(e,"theta;",6)==0) return 'È';
        if(StrNCmp(e,"trade;",6)==0) return 'TM';

      break;
      case 'u':
        if(StrNCmp(e,"uml;",4)==0) return '"';

      break;
      case 'v':break;
      case 'w':break;
      case 'x':break;
      case 'y':
        if(StrNCmp(e,"yen;",4)==0) return 'ù';

      break;
      case 'z':break;
    }
  } 

  return -1; 
}


I64 _testUTF = 0;
I64 remapUTF8(I64 c1, I64 c2=0,I64 c3=0,I64 c4=0)
{
// UTF-8 Encoding
// Bytes  f.code  last    B1        B2        B3        B4

// 1	U+0000	U+007F	0xxx.xxxx
// 2	U+0080  U+07FF	110x.xxxx  10xx.xxxx
// 3    U+0800  U+FFFF  1110.xxxx  10xx.xxxx  10xx.xxxx
// 4   U+10000 U+10FFFF 1111.0xxx  10xx.xxxx  10xx.xxxx  10xx.xxxx

// 0 -> 0000 
// 1 -> 0001
// 3 -> 0011
// 7 -> 0111
// F -> 1111

I64 code = c1;
     if((c1&0xE0)==0xC0) 
  code = ((c1&0x1F)<<6) | (c2&0x3F);
else if((c1&0xF0)==0xE0) 
  code = ((c1&0x0F)<<12) | ((c2&0x3F)<<6) | (c3&0x3F);
else if((c1&0xF8)==0xF0)
  code = ((c1&0x07)<<18) | ((c2&0x3F)<<12) | ((c3&0x3F)<<6) | (c4&0x3F);

return code;

}

I64 BytesUTF8(U8 *str,I64 k,I64 klen)
{
I64 lchr=str[k];
  if((lchr&0x80)==0x00)
  {
    return 1;
  }
  if(k<klen-1 && (lchr&0xE0)==0xC0 && (str[k+1]&0xC0)==0x80)
  // 2 byte UTF-8
  {
    return 2; 
  }
  else if(k<klen-2 && (lchr&0xF0)==0xE0
  && (str[k+1]&0xC0)==0x80
  && (str[k+2]&0xC0)==0x80)
  // 3 byte UTF-8
  {
    return 3; 
  }
  else if(k<klen-3 && (lchr&0xF8)==0xF0
  && (str[k+1]&0xC0)==0x80
  && (str[k+2]&0xC0)==0x80
  && (str[k+3]&0xC0)==0x80)
  // 4 byte UTF-8
  {
    return 4;
  }
  else
  {
    return -1;
  }
}

I64 CheckRemapUTF8(U8 *str, I64 *refk, I64 klen)
{
I64 k = refk[0];
I64 lchr=str[k];
I64 llchr = lchr;

        if((lchr&0x80)==0x00)
        {
          return lchr;
        }
        if(k<klen-1 && (lchr&0xE0)==0xC0 && (str[k+1]&0xC0)==0x80)
        // 2 byte UTF-8
        {
          // I64 t = 'a'; t |= 'b'<<8; // t -> 'ab'
          //lchr = remapUTF8((lchr)|(str[k+1]<<8));
          lchr = convertUnicode(remapUTF8(lchr,str[k+1]));
          k++; 
        }
        else if(k<klen-2 && (lchr&0xF0)==0xE0
        && (str[k+1]&0xC0)==0x80
        && (str[k+2]&0xC0)==0x80)
        // 3 byte UTF-8
        {
          // I64 t = 'a'; t |= 'b'<<8; // t -> 'ab'
          //lchr = remapUTF8((lchr)|(str[k+1]<<8)|(str[k+2]<<16));
          lchr = convertUnicode(remapUTF8(lchr,str[k+1],str[k+2]));
          k+=2; 
        }
        else if(k<klen-3 && (lchr&0xF8)==0xF0
        && (str[k+1]&0xC0)==0x80
        && (str[k+2]&0xC0)==0x80
        && (str[k+3]&0xC0)==0x80)
        // 4 byte UTF-8
        {
          // I64 t = 'a'; t |= 'b'<<8; // t -> 'ab'
          //lchr = remapUTF8((lchr)|(str[k+1]<<8)|(str[k+2]<<16)|(str[k+3]<<24));
          lchr = convertUnicode(remapUTF8(lchr,str[k+1],str[k+2],str[k+3]));
          k+=3;
        }
        else
        {
          //Print("Invalid UTF-8!\n");
          if(_testUTF<100)
          {
            Print("INVALID UTF-8: '%32ts'!\n",(str+refk[0]));
            _testUTF++;
          }

          return lchr;
        }


if(lchr != -1)
{
  refk[0]=k;

  return lchr;
}
else
{
  if(_testUTF<100)
  {
    Print("UNKNOWN UTF-8: '%32ts'!\n",(str+refk[0]));
    _testUTF++;
  }

  //refk[0]=k;

  return llchr;
}
}

U0 StrFileSafe(U8 *f)
{
  I64 lsep = 0;
  I64 kk=0,k=0,klen = StrLen(f),lchr='/';
  for(k=0;k<klen;k++)
  {
    if(
    (lchr != '/' && f[k] >= '0' && f[k] <= '9')
    || (f[k] >= 'A' && f[k] <= 'Z')
    || (f[k] >= 'a' && f[k] <= 'z')
    || f[k] == '_'
    || (k < klen-1 && lchr != '.' && lchr != '/' && f[k] == '.') 
    || (lchr != '/' && f[k] == '/'))
    {
      f[kk] = f[k];
    }
    else
    {
      f[kk] = 'Z';
    }
    lchr = f[kk];
    if(lchr == '/')
    {
      lsep = 0;
    }
    else
    {
      lsep++;
    }

    if(lsep < 23) kk++;    
  }

  f[kk] = '\0';
}
//I64 _k =0;
//U8 *_str = "‚Äôsgsgg";
//I64 _klen = StrLen(_str);
//I64 lchr = CheckRemapUTF8(_str,&_k,_klen);

//Print("%c, %d\n",lchr,_k);



I64 _docprintnewline = FALSE;
I64 _docprintlchr = -1;
I64 _docprintindol = FALSE;
I64 _docprintcount = 0;


U0 SingleHtmlPrintRaw(CDoc *doc,U8 *str,I64 dollar=FALSE,I64 wrapW=-1)
{// To print Safe Raw Text (No $$, 127 and No Controls)
// Convert UTF-8
  if(!str) throw('NULL');

  
  I64 k,lchr=_docprintlchr,klen=StrLen(str);
  I64 wrapK = 0;
  for(k=0;k<klen;k++)
  {
    lchr=str[k];

    lchr = CheckRemapUTF8(str,&k,klen);// k as reference

    if(lchr == '$$'){if(dollar){lchr='$$$$';}else{lchr='S';}}
    if(lchr == '~'+1)lchr=' ';
    if( lchr < '' 
    && lchr != '\r'
    && lchr != '\n'
    && lchr != '\t'
    )
    {
      lchr='?';
    }
    
    if(doc) DocPrint(doc,"%c",lchr); // should be Putkey?
    else PutChars(lchr);

    if(lchr == '\n') wrapK = 0;

    if(wrapW > 0 && wrapK > wrapW 
    && (lchr == ' ' || lchr == '\t'
    || lchr == '-' || lchr == ','
    || lchr == ':' || lchr == 'ƒ'
    || lchr == '_' || lchr == '!'
    || lchr == '?'
    || lchr == '.' || lchr == ';')
    )
    {
      if(doc) DocPrint(doc,"\n"); // should be Putkey?
      else PutChars('\n');
      lchr = '\n';

      wrapK = 0;
    }

    
    wrapK++;
    _docprintcount++;
  }
  _docprintlchr = lchr;   
}


U0 SingleHtmlPrint(CDoc *doc,U8 *str)
{// To decode and print text in a HTML tag. 
// (Strips multiple spaces, no newlines, decode &amp; and no $$, 127 and No Controls)
// Convert UTF-8
  if(!str) {Print("NULLSingleHTMLPRINT");
  return;
  }
  
  I64 k,lchr = _docprintlchr,klen=StrLen(str);
  for(k=0;k<klen;k++)
  {
    if(str[k] != '\t' &&
    str[k] != '\n' &&
    str[k] != '\r' && (str[k] < '' || str[k] == '~'+1)){}
    else if((lchr == ' ' && str[k] == ' ')
          || (lchr == ' ' && str[k] == '\t')          
          || (lchr == ' ' && str[k] == '\r')          
          || (lchr == ' ' && str[k] == '\n')          
    ){}
    else
    {
      lchr=str[k];
      if(lchr == '\t')lchr=' ';
      else if(lchr == '\r')lchr=' ';
      else if(lchr == '\n')lchr=' ';

      if(lchr == '&')
      {
        //SingleHtmlPrintRaw(doc,parseEntity(str+k));
        U8 *ematch = StrMatch(";",str+k);
        if(ematch && (ematch - (str+k))<10)
        {
          lchr = parseEntity(str+k,ematch);
          if(lchr != -1)
          {
            str = ematch;
            k=0;// the k++ jumps the ;
            klen = StrLen(str);
          }
          else
          {
            lchr = '&';
          }
        }
      }
      else
      {
        lchr = CheckRemapUTF8(str,&k,klen);// k as reference
      }
      // some unicode and &#xxx; things may return those
      // THISONLYCHECKSSINGLECHARS, THOSECANRETURNMULTI-CHAR
      if(lchr != '\t' && lchr != '\r' && lchr != '\n' && lchr < '')
        lchr='?';
      if(lchr == '$$')lchr='S';
      if(lchr == '~'+1)lchr=' ';  
      if(doc) DocPrint(doc,"%c",lchr); // should be Putkey?
      else PutChars(lchr);      
    }

    _docprintcount++;
  }
  _docprintlchr = lchr;   
}

U0 HtmlPrint(CDoc *doc,...)
{
  I64 k;
  for(k=0;k<argc;k++)
  {
    SingleHtmlPrint(doc,argv[k]);
  }
}

U0 HtmlPrintRaw(CDoc *doc,...)
{
  I64 k;
  for(k=0;k<argc;k++)
  {
    SingleHtmlPrintRaw(doc,argv[k]);
  }
}

U0 HtmlPrintNewLine(CDoc *doc,I64 depth)
{
  if(doc) DocPrint(doc,"\n%h*c",depth*2,' '); // should be Putkey?
  else Print("\n%h*c",depth*2,' ');
}



