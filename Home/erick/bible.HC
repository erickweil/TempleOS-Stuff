#include "::/Home/Net/HtmlFunctions"

// Use Custom Memory

// Adam("#include \"C:/Home/erick/bible_Adam.HC\"" );
//#include "::/Home/erick/bible_Adam.HC"
// Parse Bible verses db
// Downloaded from Scratch project 
// "The Entire Bible on Scratch!" from erickweil
// at https://scratch.mit.edu/projects/102991620/

I64 getUTF8Off(I64 charOff, U8 *buffer)
{
  I64 k = 0;
  while(TRUE)
  {
    I64 chr = buffer[k];
    if(chr == 0)
    {
      break;
    }

    charOff--;

    if(charOff<= 0) break;

    k+= BytesUTF8(buffer,k,k+4);
  }
  return k;
}

U8 *getLine(I64 line,U8 *buffer)
{
  I64 k = 0;
  I64 line_count = 0;
  I64 line_start = 0;
  I64 line_end = 0;
  while(TRUE)
  {
    I64 chr = buffer[k];
    if(chr == 0)
    {
      line_end = k;
      break;
    }


    if(line_count == line-1)
    {
      line_start = k;
    }
    else if(line_count == line+1)
    {
      line_end = k-1; // Skipe the \n
      break;
    }
    else if(line_count > line+1) break;


    if(chr == '\n') line_count++;

    k++;
    //if(k>10000) return NULL;
  }
  if(line_count>1)
  {
    //Print("WTF %d\n",line_start);
    line_start++;
  }
  
  I64 length = line_end - line_start;

  //Print("%d, %d-%d\n",length,line_start,line_end);
  if(length <= 0) return NULL;

  U8 *retBuffer = CMCAlloc(length+1);
  MemCpy(retBuffer,buffer+(line_start),length);

  //Print("%s\n",buffer+line_start);
  
  return retBuffer;
}

I64 getLineNumber(I64 line,U8 *buffer)
{
  U8 *l = getLine(line,buffer);
  if(!l) throw('NULL');

  I64 ret = Str2I64(l);
  CMFree(l);

  return ret;
}

U0 bible_main()
{
//  U8 *FileRead(U8 *filename,I64 *_size=NULL,I64 *_attr=NULL)
//{//Read whole file from disk.
    I64 bookN = 10;
    I64 chapterN = 2;
    I64 verseN = 3; 
    U8 *bookName = getLine(bookN-1,books);
    if(bookName)
    {
      
      HtmlPrintRaw(NULL,bookName);
      Print(" %d:%d\n",chapterN,verseN);

      //I64 ch_off = getLineNumber(bookN-1,books_off);
      //I64 ch_off = books_off[bookN-1];
      //Print(" ch:%d",ch_off);

      //I64 vs_off = chapters_off[ch_off+chapterN-1];
      //Print(" vs:%d",vs_off);

      //I64 tx_off = verses_off[vs_off+verseN-1];
      //Print(" tx:%d",tx_off);

      //tx_off = getUTF8Off(tx_off,verses);
      //Print(" btx:%d\n",tx_off);
      //U8 *verse = getLine(0,verses+tx_off);
      //U8 *verse = CMCAlloc(65);
      //MemCpy(verse,lines+tx_off,64);
      
      U8 *verse = BibleGetVerse(bookN,chapterN,verseN);

      //Print("%s",verse);
      Print("\n\n");
      HtmlPrintRaw(NULL,verse);
      Print("\n");
      Free(verse);
    }
    else
    Print("NULL\n");


    CMFree(bookName);
    CustomMemoryCheck;
    CustomMemoryReset;

//  HtmlPrintRaw(NULL,books);
//  HtmlPrintRaw(NULL,books_off);
//  HtmlPrintRaw(NULL,books);
//  HtmlPrintRaw(NULL,books);

//  Free(lines);  
//  Free(books);
//  Free(books_off);
//  Free(chapters_off);
//  Free(verses_off);
}


U0 remap_verses_off()
{
  I64 k;
  for(k=0;k<verses_offsz;k++)
  {
    I64 tx_off = verses_off[k];

    I64 btx_off = getUTF8Off(tx_off,verses);

    if(k %100 == 0)
    {
      Print("tx:%d\tbtx:%d",tx_off,btx_off);
    }

    verses_off[k] = btx_off;
  }
}


U0 save_verses_off()
{
  // Create DolDoc at filename location
  CDoc *doc=DocNew("::/Home/erick/bibliapt_verses_boff.TXT");    
  doc->flags|=DOCF_PLAIN_TEXT|DOCF_NO_CURSOR;
  I64 k;  
  for(k=0;k<verses_offsz;k++)
  {
    I64 tx_boff = verses_off[k];
    DocPrint(doc,"%d\n",tx_boff);
  }
  DocWrite(doc,FALSE);

  DocDel(doc);
}

U0 write_bible()
{
  // Create DolDoc at filename location
  CDoc *doc=DocNew("::/Home/erick/biblia.DD");    
  doc->flags|=DOCF_PLAIN_TEXT|DOCF_NO_CURSOR;
//  CDoc *doc = NULL;
  U8 *buffer = CMCAlloc(10000);

  I64 book,chapter,verse;  //1-indexed
  for(book=1;book<=BibleNBooks();book++)
  {
    U8 *bookName = getLine(book-1,books);

    //DocPrint(doc,"$$TR,\"%s\"$$\n$$ID,2$$",bookName);
    DocPrint(doc,"$$TR,\"");
    HtmlPrintRaw(doc,bookName);
    DocPrint(doc,"\"$$\n$$ID,2$$");

    for(chapter=1;chapter<=BibleNChapters(book);chapter++)
    {
      DocPrint(doc,"$$TR,\"%d\"$$\n$$ID,2$$",chapter);

       
      for(verse=1;verse<=BibleNVerses(book,chapter);verse++)
      {
        //I64 tx_boff = verses_off[k];
        //  DocPrint(doc,"%d\n",tx_boff);
        U8 *vtxt = BibleGetVerse(book,chapter,verse,buffer);
        DocPrint(doc,"%d:%d",chapter,verse);

        //HtmlPrintRaw(doc,vtxt);
        
        SingleHtmlPrintRaw(doc,vtxt,TRUE,60);

        DocPrint(doc,"\n\n");

        //break; 
      }

      DocPrint(doc,"$$ID,-2$$");  

      //break;
    }
    
    //$$ID,-2$$$$ID,-2$$$$TR,"Exodus"$$

    DocPrint(doc,"$$ID,-2$$");  

    CMFree(bookName);

  }
  DocWrite(doc,FALSE);

  DocDel(doc);

  CMFree(buffer);
}

//save_verses_off;

//remap_verses_off;

//bible_main
write_bible;