// use Custom Memory

#include "::/Home/Net/HtmlParser"

U8 *KCDomain = NULL;

U0 DocNodeBrowsePrint(DocNode *dc,I64 depth=0,I64 doNext=TRUE)
{// up to 64 depth RECURSIVE. need to think twice
  if (!dc) return;


  if(depth == 0){Print("$$BLACK$$");}  

  if(depth > 64){Print("Error Printing! Too Deep!");throw('TOODEEP');}

  I64 changedColor = FALSE;
  I64 ident = 0;
  U8 *hrefValue;
    
  if(dc->name)
  {
 //   Print("name: '%s' depth:%d\n",dc->name,depth);
 //   if(!YorN) throw('NO');

    if(!CheckIsHidden(dc->name))
    {
      if(!_docprintindol){
      I64 block_level = CheckBlock(dc->name);
      if(block_level && !_docprintnewline)
      {
        Print("\n");
      }
      
      if(StrICmp(dc->name,"br")==0)
      {
        Print("\n");
        _docprintnewline = TRUE;
      }
      else if(CheckN(dc->name,"h1","h2","h3","h4","h5","h6"))
      {
        Print("$$PURPLE$$$$ID,2$$");changedColor=TRUE;ident=2;
      }
      else if(StrICmp(dc->name,"a")==0)
      {
        Print("$$MA,\"");_docprintindol=TRUE;
      }
      else if(StrICmp(dc->name,"img")==0)
      {
        //hrefValue = DocNodeSearchAttr(dc,"alt","");
        //Print("\n$$MA+B-UL,\"IMG%s\"$$\n",hrefValue);
      }
      
      }

      if(dc->child)  
        DocNodeBrowsePrint(dc->child,depth+1);
      

      if(StrICmp(dc->name,"a")==0)
      {
        hrefValue = DocNodeSearchAttr(dc,"href","NULL");
        Print("\",LM=\"Print(\\\"Deseja Mesmo Acessar Este Site?\\n%s\\n\\\",\\\"%s%s\\\");\nKCTest(\\\"%s\\\",\\\"%s\\\");\"$$",
        "%s",
        KCDomain,
        hrefValue,
        KCDomain,
        hrefValue);
        
        _docprintindol=FALSE;
      }

      if(!_docprintindol){
      
      if(changedColor)Print("$$BLACK$$$$UL,0$$");
      if(ident>0)Print("$$ID,-%d$$",ident);

      if(block_level)
      {
        Print("\n");
        _docprintnewline = TRUE;
      }
      else
      {
        _docprintnewline = FALSE;
      }
      
      }
    } 
  }
  else if(dc->innerText)
  {
  //  Print("innerText: '%s' depth:%d\n",dc->innerText,depth);
  //  if(!YorN) throw('NO');


    HtmlTextPrint(dc->innerText);
  }
  else{
    throw('NULL');
  }
  
  if(doNext){
    DocNode *node = dc->next;
    while(node)
    {
      DocNodeBrowsePrint(node,depth+1,FALSE);

      node = node->next;
    }
  }

  if(depth == 0){Print("$$FG$$");}  

}


//TestOffline = "<!DOCTYPE html><style>a>aa</style><script>bb</script> <html> <head> <meta charset=\"utf-8\"> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> <title>Conexao BD</title> <!--[if lt IE 9]> <script src=\"http://html5shiv.googlecode.com/svn/trunk/html5.js\"></script> <![endif]--> <!--  --  A >B- >AAA-->\r\n<!--sdfsdfsdf--><p>Oi?</p>  </head> <body> <h1>ERRO AO CARREGAR<span style=\"color:#FFFFFF\">(TEM ERRO NENHUM, SAIA DAQUI)</span></h1> <h2>já foram enviados 13 macacos treinados para resolver o problema.</h2> <img src=\"http://2.bp.blogspot.com/-hEKKrXmwVRc/TfbLrNH5eEI/AAAAAAAAoj4/_xs0Z3qAOD8/s1600/article-1206973-06153D1D000005DC-213_468x267.jpg\"/><br/> <a href=\"TESTE\">Teste</a> </body> </html>";


U0 KCTest(U8 *domain,U8 *path)
{

//DocTermNew;
//Yield;
if(StrNCmp(path,"https:",6)==0 || StrNCmp(path,"http:",5)==0)
{
    // StrMatch returns a pointer to a char array
    // inside the haystack including needle. OR NULL
    domain = StrMatch("://",path);
    if(!domain)throw('INVALID');

       
    domain = domain+3;
    
    path = StrMatch("/",domain);
    if(!path)throw('INVALID');

    path[0] = '\0';    

    path = path+1;

    Print("Domain:'%s'\n",domain);    

    Print("Path:'%s'\n",path);    
    
    if(!YorN)
    return;
}




HttpResetIter;


if(!TestOffline)
{
SerialBegin(1,9600);
SerialFlush();

TunnelPing();
TunnelPing();
Print("\n");


KCDomain = domain;
HttpGet(domain,443,path,0);

HttpParseHeaders();
}


//DocTermNew;

//Print("Create Doc?:");if(ask && YorN){}

DocNode *root = DocNodeNew(NULL,"ROOT",NULL);

//Print("Alloc buff?:");if(ask && YorN){}
//Print("Allocated Buffer\n");
U8 *buffer = CMCAlloc(HTML_BZ+1);//Max contiguous string

//Print("Parse?:");if(ask && YorN){}

HtmlParse(root,buffer);

//Print("Free buffer?");if(ask && YorN){}
//Print("Free buffer\n");
CMFree(buffer);


Print("\n\nFinished Parsing\n\n");

Print("Print Doc?:");if(YorN){}
//DocNodePrint(root);
DocNodeBrowsePrint(root);

//Print("Free Doc?");if(ask && YorN){}
DocNodeDel(root);

//HtmlContent();

Print("\n");
Print("\n");

CMFree(iterBuffer);
iterBuffer = NULL;

//if(YorN){
CustomMemoryPrint();
//}


//CustomMemoryFree();
CustomMemoryReset();
}

//while(YorN)
//{
//HttpResetIter();
KCTest("www.google.com","search?q=ASCII+Table");
//}

//test();

//Print("END");