
//ADAM INCLUDED #include "::/Home/Net/HtmlFunctions"
#include "::/Home/Net/Http"
//#define HTML_BZ	131072
#define HTML_BZ	65536
//#define HTML_BZ	32768
//#define HTML_BZ 6000000
// HTML DOM
// The U8* in this need to be FREE-able
public class DocNode {
  // next elem in same depth
  DocNode *next;
  // first elem one depth inside
  DocNode *child;
  // parent. root have NULL parent
  DocNode *parent;
  // Attributes of the tag, or NULL if none
  DocNodeAttr *attr;
  // name of the TAG, or NULL if Raw-Text Tag
  U8 *name;
  // when Raw-Text Tag, text content, NULL otherwise
  U8 *innerText;
};

DocNode *DocNodeNew(DocNode *parent,U8 *name, U8 *innerText)
{// Create a new DocNode, remember to call DocNodeDel
 //Don't forget these $MA-X+PU,"sizeof(DocNode)",LM="Find(\"sizeof(DocNode)\",\"/*\");View;"$.  CDC
  DocNode *res;
  res=CAlloc(sizeof(DocNode));

  res->parent = parent;  
  res->next = NULL;
  res->child = NULL;
  res->attr = NULL;

  if(name && StrLen(name)>0)
  {
    res->name = CAlloc(StrLen(name)+1);
    StrCpy(res->name,name);
  }
  else
    res->name = NULL;
  if(innerText && StrLen(innerText)>0)
  {
    res->innerText = CAlloc(StrLen(innerText)+1);
    StrCpy(res->innerText,innerText);
  }
  else
    res->innerText = NULL;
  
  return res;
}


U0 DocNodeDel(DocNode *dc,I64 depth=0,I64 doNext=TRUE)
{//Free recursively RECURSIVE
  if (!dc) return;

  if(depth > 64){Print("Error Freeing! Too Deep!");throw('TOODEEP');}

  if(dc->child)
  {
    DocNodeDel(dc->child,depth+1,TRUE);
  }
//  dc->child = NULL;

  DocNodeAttr *attr = dc->attr;
  DocNodeAttr *_attr;
  while(attr)
  {
    _attr = attr; 
    attr = attr->next;
    DocNodeAttrDel(_attr);   
  }
//  dc->attr = NULL;

  if(dc->name)
    Free(dc->name);
//  dc->name = NULL;

  if(dc->innerText)
    Free(dc->innerText);
//  dc->innerText = NULL;


  //DocNode *dold = dc;
  DocNode *_dc;
  //if(doNext) while((dc = dc->next) != NULL)
  //{
  //  DocNodeDel(dc,depth+1,FALSE);
  //}
  if(!doNext)
  {
    Free(dc);
  }
  else
  {
    _dc = dc;
    dc = dc->next;
    Free(_dc); 

    while(dc)
    {
      _dc = dc;
      dc = dc->next;
      DocNodeDel(_dc,depth+1,FALSE);
    }
  }
}



U0 DocNodePrint(DocNode *dc,I64 onlyText=FALSE,I64 depth=0,CDoc *doc=NULL,I64 doNext=TRUE)
{// up to 64 depth RECURSIVE. need to think twice
  if (!dc) return;

//  Print("%d\n",depth);
    
  if(depth >= 64){Print("Error Printing! Too Deep!");throw('TOODEEP');}

  if(dc->name)
  {
    if(!onlyText || !CheckIsHidden(dc->name))
    {
      if(!onlyText)
      {
        HtmlPrintNewLine(doc,depth);
      
        if(dc->attr)
        {
          
          HtmlPrint(doc,"<",dc->name);
          DocNodeAttr *attr = dc->attr;
          while(attr)
          {
            if(attr->name && attr->value)
              HtmlPrintRaw(doc," ",attr->name,"=\"",attr->value,"\"");   
            else if(attr->name)
              HtmlPrintRaw(doc," ",attr->name);   
            attr = attr->next;
          }
          HtmlPrint(doc,">");
        }
        else HtmlPrint(doc,"<",dc->name,">");
      }
      
      //HtmlPrintNewLine(doc,depth);
          
      if(dc->child)  
      {
        DocNodePrint(dc->child,onlyText,depth+1,doc,TRUE);
      }
      
      HtmlPrintNewLine(doc,depth);
          
      if(!onlyText)
        HtmlPrint(doc,"</",dc->name,">");
    } 
  }
  else if(dc->innerText)
  {
    HtmlPrintNewLine(doc,depth);
    if(dc->parent 
      && dc->parent->name 
      && CheckEscapedContent(dc->parent->name))
      HtmlPrintRaw(doc,dc->innerText);
    else
      HtmlPrint(doc,dc->innerText);
  }
  else HtmlPrint(doc,"<NULL></NULL>");
  
  if(doNext) while((dc = dc->next) != NULL)
  {
    DocNodePrint(dc,onlyText,depth,doc,FALSE);  
  }
//  Sleep(10);
}


I64 HtmlParseAttr(U8 *buffer,DocNode *parent)
{// Always return on >

  //0   <tag a="" b="" ... >
  //2   <tag >
  //3   <tag />
  //3   <tag/>
  //        0
  I64 last;
  DocNodeAttr *newAttr = NULL;
  DocNodeAttr *lastAttr = NULL;

  while(TRUE) // Return only if reached EOF or >
  {
    last = HttpNextWord(buffer,HTML_BZ);
    if(last == -1) break;
    if(last == '>') break;
    if(StrLen(buffer) == 0) break;
    if(last != '=') break;

    newAttr = DocNodeAttrNew(buffer);
    if(lastAttr) lastAttr->next = newAttr;
    else parent->attr = newAttr;

    //Print("\t'%s'",buffer);

    last = HttpNextString(buffer,HTML_BZ,'"','\'');
    if(last == -1) break;
    if(last == '>') break;
    if(last != '"' && last != '\'') break;

    //Print("='%s'\n",buffer);
    if(StrLen(buffer)>0)
    {
      newAttr->value = CAlloc(StrLen(buffer)+1);
      StrCpy(newAttr->value,buffer);
    }

    if(last == '>') break;

    lastAttr = newAttr;
  }

  

  // Find the >
  if(last == -1) return -1;
  if(last == '>') return last;

  last = HttpNext(buffer,HTML_BZ,-1,   '>',-1);// Skip until '>'
  return last;     
}

//StrICmp CDC
I64 HtmlParse(DocNode *parent,U8 *buffer,I64 depth=0)
{// up to 64- Recursive.

  if(!parent || !parent->name) throw('NULL');

  if(depth>64)
  {
    Print("Error Parsing! Too Deep!");throw('TOODEEP');
  }

  Print(".");

  //Print("Parsing %s\n",parent->name);
  I64 autoClose;
  DocNode *node = NULL;  
  I64 last;
  do {

    autoClose = FALSE;
    //>     <name a='' b=''> dfgdgdfgfdg </name>
    // 0    i
    last = HttpNext(buffer,HTML_BZ,-1,   '<',-1); // Skip until '<'
    if(last == -1)
    {
      return -1;
    }
    //Print("  Raw :'%s'\n",buffer);
    // Raw Text Node
    if(StrLen(buffer)>0)
    {
      DocNode *raw_node = DocNodeNew(parent,NULL,buffer);
      if(node == NULL)
      {
        parent->child = raw_node;
      }
      else
      {
        node->next = raw_node;
      }
      node = raw_node; 
    }
    //Print("'<': '%s'\n",buffer);
    //0  <name a='' b=''> dfgdgdfgfdg </name>
    //1  <name> dfgdgdfgfdg </name>
    //2  <name
    //>
    //    0   i
    //last = HttpNext(buffer,HTML_BZ,-1,   ' ','>');// Skip until ' ' or '>'
    last = HttpNextWord(buffer,HTML_BZ);
    if(last == -1) return -1;
    
    if(buffer[StrLen(buffer)-1] == '/')
    {
      autoClose = TRUE;
      buffer[StrLen(buffer)-1] = '\0'; 
    }
      
    //Print("  Name:'%s' Last'%c'\n",buffer,last);
    if(StrLen(buffer) == 0)
    {
      Print("NULL name Tag last='%c'",last);
      //ignore
    }
    else if(buffer[0] == '!')
    {
      // Skip Comments <!--.........-->
      if(StrNICmp(buffer,"!--",3) == 0)
      {
        if(last == '>' && StrNICmp(buffer+(StrLen(buffer)-2),"--",2) == 0) 
        {                                          // e.g. <!---->
          //ignore
        }
        else last = HttpNextMatch(buffer,HTML_BZ,"-->");
      }
      else
      {// Ignore !Doctype
        last = HttpNext(buffer,HTML_BZ,-1,   '>',-1);// Skip until '>'
        if(last == -1)
        {
          return -1;
        }
      }
    }    
    else if(buffer[0] == '/')// Fecha a ultima tag; deveria checar os nomes ne
    {
      if(CheckAutoClose(buffer+1))
      {
        Print("Wrong Closing:%s can't be closed\n",buffer+1); 
      }
      else if(StrICmp(buffer+1,parent->name)==0)
      {
        //Print("Closing %s\n",parent->name);
        Print(";");
        return 1;
      }
      else
      {
        Print("Wrong Closing:%s!=%s\n",buffer+1,parent->name);
        if(depth > 0)
        {
          Print(";");
          return 2;
        }
      }
    }   
    else
    {
      DocNode *new_node = DocNodeNew(parent,buffer,NULL);
      if(!new_node->name) throw('NULL');
      if(node == NULL)
      {
        parent->child = new_node;
      }
      else
      {
        node->next = new_node;
      }
      node = new_node; 
     
      //0  <name a='' b=''> dfgdgdfgfdg </name>
      //        0         i
      //1  <name> dfgdgdfgfdg </name>
      //        0X
      //2  <name/>
      //         0X
      //3  <name a='' b=''/>
      //        0          i
      if(last == '/')
      {
        autoClose = TRUE;
      }
      
      if(last != '>')// Has arttributes?
      {
        //last = HttpNext(buffer,HTML_BZ,-1,   '>',-1);// Skip until ' '
        //if(last == -1)
        // {
        //  return -1;
        //}
        last = HtmlParseAttr(buffer,node);
        if(last == -1) return -1;

        //Print("  Args:'%s'\n",buffer);
        if(buffer[StrLen(buffer)-1] == '/')
          autoClose = TRUE;
      }


      // Do all childs (Only if not AutoClosing)
      if(!autoClose && !CheckAutoClose(node->name))
      {
        if(CheckEscapedContent(node->name))
        {
          if(StrICmp(node->name,"style")==0)
            last = HttpNextMatch(buffer,HTML_BZ,"</style>");
          else
            last = HttpNextMatch(buffer,HTML_BZ,"</script>");
          
          if(buffer[0] !='\0')
          {
            DocNode *escaped_node = DocNodeNew(node,NULL,buffer);
            node->child = escaped_node;
          }
        }
        else {
        I64 code = HtmlParse(node,buffer,depth+1);
        if(code == -1) return -1; // End of input;

        if(code == 2) //Wrong Tag Closing
        {
          if(StrICmp(buffer+1,parent->name)==0)
          {
            //Print(".Closing %s\n",parent->name);
            Print(";");
            return 1;
          }
          else
          {
            Print("Stoped, but yet Wrong Closing:%s!=%s\n",buffer+1,parent->name);
            //return 2;
          }
        }
        }
      }
      else
      {
        //Print("AutoClosed %s\n",node->name);
      }
    }
    //Yield;
  }
  while(TRUE);

  // Should never return 0
  Print("???????????????????");
  return 0;
}


U0 HtmlContent()
{

I64 lchr = 0;
I64 chr;
I64 inside = 0;
while((chr = HttpNextChar())!=-1)
{
  if(chr == '<') inside=1; 
  else if(chr == '>') inside=0;
  else if(inside == 0)
  {
    if(chr != '\r'
       && !(chr == '\t' && lchr == '\t')
       && !(chr == '\n' && lchr == '\n')
       && !(chr == ' ' && lchr == ' ')
    )
    {
      Print("%c",chr);
      lchr = chr;
    }
  }
}

}









U0 test(U8 *HTML=NULL)
{

HttpResetIter();


if(!HTML)
{
  SerialBegin(1,9600);
  SerialFlush();

  TunnelPing();
  Print("\n");
//  HttpGet("www.google.com","443","/search?q=memory",0);
//  HttpGet("www.google.com","443","/search?q=templeos",0);
//  HttpGet("passapassa.com.br","443","/",0);
  HttpGet("stackoverflow.com","443","/questions/23714383/what-are-all-the-possible-values-for-http-content-type-header/",NULL,0);
  DocNodeAttr *headers = HttpParseHeaders();
  DocNodeAttrDel(headers,TRUE);
}
else
{
//  buf=StrPrintJoin(NULL,HTML,argc,argv);
  TestOffline = HTML;
}


DocNode *root = DocNodeNew(NULL,"ROOT",NULL);

U8 *buffer = CAlloc(HTML_BZ+1);//Max contiguous string (Later should depend on Content-Size)

HtmlParse(root,buffer);

Free(buffer);

Print("\n\nFinished Parsing\n\n$$BLACK$$");

// Create DolDoc at filename location
CDoc *doc=DocNew("::/Home/Net/out.HTML");    
doc->flags|=DOCF_PLAIN_TEXT|DOCF_NO_CURSOR;

DocNodePrint(root,FALSE,0,doc);


DocNodePrint(root,FALSE,0,NULL);


DocWrite(doc,FALSE);


DocDel(doc);

DocNodeDel(root);
//CMFree(root);

//HtmlContent();

Print("$$FG$$\n\n");


if(HTML)
{
  TestOffline = NULL;
}

Free(iterBuffer);
iterBuffer=NULL;

//if(YorN){
//CustomMemoryPrint();
//}


//CustomMemoryFree();
//CustomMemoryReset();
}

//test;
/*
test(
"
<!DOCTYPE html>
<html>
<head>
  <meta charset=\"utf-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <title>Conexao BD< /title> 
  <!--[if lt IE 9]> 
    <script src=\"http://html5shiv.googlecode.com/svn/trunk/html5.js\"></script> 
  <![endif]--> 
  <!--  --  A >B- >AAA-->\r\n<!--sdfsdfsdf--><p>Oi?</p>  
</head>
<body>
  <h1>
    ERRO AO CARREGAR
    <span style=\"color:#FFFFFF\">
      (TEM ERRO NENHUM, SAIA DAQUI)
    </span>
  </h1> 
  <h2>
    já foram enviados 13 macacos &quot;treinados&quot; para resolver o problema.
  </h2>
  <img src=\"http://2.bp.blogspot.com/-hEKKrXmwVRc/TfbLrNH5eEI/AAAAAAAAoj4/_xs0Z3qAOD8/s1600/article-1206973-06153D1D000005DC-213_468x267.jpg\"/>
  <br/>
  <a href=\"TESTE\">Teste&lt;&gt;&le;&ge;</a> 
</body> 
</html>
"

);
*/