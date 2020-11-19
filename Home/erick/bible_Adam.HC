// Include as Adam, so you load one time only.


I32 *parseNumberLines(U8 *buffer,I64 *out_size)
{// the buffer WILLBEMODIFIED
  I64 ret_size = 256 * sizeof(I32);
  I32 *ret = CAlloc(ret_size);  

  I64 k = 0;
  I64 line_count = 0;
  while(TRUE)
  {
    I64 chr = buffer[k];
    if(chr == 0)
    {
      break;
    }


    if(chr == '\n')
    {
      buffer[k] = '\0';
      
      I64 number = Str2I64(buffer);
      //Print("'%s' --> %d\n",buffer,number);

      ret[line_count] = number;

      buffer = buffer+(k+1);
      k = 0;
      line_count++;

      if(line_count >= ret_size / sizeof(I32))
      {// Resize
        I64 _ret = ret;
        ret = CAlloc(ret_size*2);

        MemCpy(ret,_ret,ret_size);
        ret_size = ret_size*2;

        Free(_ret);
      }
    }
    else
    {
      k++;
    }
  }

  Print("\nFinished with size %d/%d (%d bytes)",line_count,ret_size/sizeof(I32),ret_size);
  out_size[0] = line_count;    
  return ret;
}


U8 *books = NULL;
I64 books_offsz = 0;
I32 *books_off = NULL;

I64 chapters_offsz = 0;
I32 *chapters_off = NULL;

I64 verses_offsz = 0;
I32 *verses_off = NULL;

U8 *verses = NULL;

I64 BibleNBooks()
{
  return 66;
}

I64 BibleNChapters(I64 book)
{
  book--;//1-indexed
  if(book == 65) return 22;
  
  return books_off[book+1] - books_off[book];
}

I64 BibleNVerses(I64 book,I64 chapter)
{
  book--;//1-indexed
  chapter--;//1-indexed
  if(book == 65 && chapter == 21) return 21;
  
  I64 chOff = books_off[book];

  return chapters_off[chOff + chapter+1] - chapters_off[chOff + chapter];
}





U8 *BibleGetVerse(I64 book,I64 chapter,I64 verse,U8 *buffer=NULL)//buffer should be big
{
  if(book < 0 || book > BibleNBooks()) throw('INVALID');

  if(chapter < 0 || chapter > BibleNChapters(book)) throw('INVALID');

  if(verse < 0 || verse > BibleNVerses(book,chapter)) throw('INVALID');

  book--;chapter--;verse--;//1-indexed
  //I64 ch_off = getLineNumber(bookN-1,books_off);
  I64 ch_off = books_off[book];
  //Print(" ch:%d",ch_off);

  I64 vs_off = chapters_off[ch_off+chapter];
  //Print(" vs:%d",vs_off);

  I64 tx_off = verses_off[vs_off+verse];
  //Print(" tx:%d",tx_off);

  I64 len;
  if(book == 65 && chapter == 21 && verse == 20) 
    len = 63;
  else
    len = (verses_off[vs_off+verse+1] - tx_off)-1;// remove \n

  if(!buffer) buffer = CAlloc(len+1);
  
  MemCpy(buffer,verses+tx_off,len);

  buffer[len] = '\0';
  return buffer;
}
//Print("Loading Books\n");
//books = FileRead("::~/erick/bibliapt_books.TXT");  
//books_off = FileRead("::~/erick/bibliapt_books_off.TXT");
//chapters_off = FileRead("::~/erick/bibliapt_chapters_off.TXT");
//verses_off = FileRead("::~/erick/bibliapt_verses_off.TXT");
//verses = FileRead("::~/erick/bibliapt_lines.TXT");

U0 loadBible()
{

  Print("Loading Books\n");

  books = FileRead("::~/erick/bibliapt_books.TXT");  

  books_off = parseNumberLines(FileRead("::~/erick/bibliapt_books_off.TXT"),&books_offsz);
  chapters_off = parseNumberLines(FileRead("::~/erick/bibliapt_chapters_off.TXT"),&chapters_offsz);
  verses_off = parseNumberLines(FileRead("::~/erick/bibliapt_verses_boff.TXT"),&verses_offsz);

  verses = FileRead("::~/erick/bibliapt_lines.TXT");
}


U0 freeBible()
{
  Free(books);
  Free(books_off);
  Free(chapters_off);
  Free(verses_off);
  Free(verses);
}


loadBible;
//freeBible;

//CustomMemoryPrint;
//CustomMemoryReset;
