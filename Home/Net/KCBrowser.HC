// use Custom Memory

//Adam("#include \"C:/Home/Net/SerialNetv2.HC\"" );
//Adam("#include \"C:/Home/Net/CustomMem.HC\"" );
#include "::/Home/Net/HtmlParser"

//#include "::/Home/Net/KCBrowserCookies"


U8 *KC_PrevUrl = NULL;



public class URL {
// scheme://host:port/path?query#fragment
  U8 *scheme;
  U8 *host;
  U8 *port;
  U8 *path;
  U8 *query;
  U8 *fragment;
};

// HTML DOM

URL *URLNew(U8 *scheme, U8 *host, U8 *port, U8 *path, U8 *query, U8 *fragment)
{
  URL *res;
  res=CAlloc(sizeof(URL));
  
  res->scheme = StrNew2(NULL,scheme);
  res->host = StrNew2(NULL,host);
  res->port = StrNew2(NULL,port);
  res->path = StrNew2(NULL,path);
  res->query = StrNew2(NULL,query);
  res->fragment = StrNew2(NULL,fragment);

//  if(scheme && StrLen(scheme) > 0)
//  {
//    res->scheme = CAlloc(StrLen(scheme)+1);
//    StrCpy(res->scheme,scheme);
//  }

  return res;
}

U0 URLDel(URL *res)
{//Don't free the next
  if (!res) return;

  if(res->scheme)Free(res->scheme);
  if(res->host)Free(res->host);
  if(res->port)Free(res->port);
  if(res->path)Free(res->path);
  if(res->query)Free(res->query);
  if(res->fragment)Free(res->fragment);
  
  Free(res);
};


U8 *BuildUrl(URL *a,I64 GetOnly=FALSE)
{
  U8 *buf = CAlloc(
  StrLen(a->scheme)+3+StrLen(a->host)+1+StrLen(a->port)+StrLen(a->path)
  + 1 +StrLen(a->query)+1+StrLen(a->fragment) +1); // DONTFORGETTHE+1
  
// scheme://host:port/path?query#fragment
  U8 *ret = buf;
  if(a->scheme && !GetOnly)
  {
    StrCpy(buf,a->scheme);buf += StrLen(a->scheme);
    StrCpy(buf,"://");buf += 3;
  }
  if(a->host && !GetOnly)
  {
    StrCpy(buf,a->host);buf += StrLen(a->host);    
  }
  if(a->port && !GetOnly)
  {
    buf[0] =':';buf += 1;
    StrCpy(buf,a->port);buf += StrLen(a->port);    
  }
  if(a->path)
  {
    if(a->path[0] != '/')
    {
      buf[0] ='/';buf += 1;
    }
    StrCpy(buf,a->path);buf += StrLen(a->path);    
  }
  if(a->query)
  {
    buf[0] ='?';buf += 1;
    StrCpy(buf,a->query);buf += StrLen(a->query);    
  }
  if(a->fragment)
  {
    buf[0] ='#';buf += 1;
    StrCpy(buf,a->fragment);
  }

  return ret;
}

URL *ParseUrl(U8 *str)
{// the str arg will be modified!


//DocTermNew;
//Yield;
//if(StrNCmp(,"https:",6)==0 || StrNCmp(URL,"http:",5)==0)
//{
  /*
  Syntax$FG,0$$UL,0$
  Main article: $MA,"Uniform Resource Identifier &#160;Generic syntax",LM="KCTest(\"en.wikipedia.org\",\"/wiki/Uniform_Resource_Identifier#Generic_syntax\");"$
  Every HTTP URL conforms to the syntax of a generic URI.
  The URI generic syntax consists of a hierarchical sequence of 
  five components:$MA,"&#91;14&#93;",LM="KCTest(\"en.wikipedia.org\",\"#cite_note-FOOTNOTERFC_3986,_section_32005-15\");"$ 
  
  URI = scheme:[//authority]path[?query][#fragment] 
  
  where the authority component divides into three subcomponents:   
  authority = [userinfo@]host[:port] 

  Ok... but these are
  Valid Addresses to our purposes

  Absolute
  scheme://host[:port]/[path][?query][#fragment]
  
  Scheme Relative
  //host[:port]/[path][?query][#fragment]
  
  Host Relative, Absolue Path
  /path[?query][#fragment]

  /path?query#fragment
  /path?query
  /path#fragment
  /path  
  
  Host Relative, Relative Path
  path[?query][#fragment]

  path?query#fragment
  path?query
  path#fragment
  path  

  
  Same Page
  [?query][#fragment]

  ?query#fragment
  ?query
  #fragment  $WW,0$
  */
   
  // StrMatch returns a pointer to a char array
  // inside the haystack including needle. OR NULL

  U8 *scheme=NULL; 
  U8 *host=NULL; 
  U8 *port=NULL; 
  U8 *path=NULL; 
  U8 *query=NULL; 
  U8 *fragment=NULL;

  //I64 strlen = StrLen(str);
  U8 *tmp=NULL;
  U8 *match;
  I64 lchr=-1;  
  I64 absPath = FALSE;
  // scheme.

  if(str[0] != '/' && (match = StrMatch("://",str)) != NULL)   
  {
    //  scheme://dgdfgdf
    //        0
    match[0] = '\0';lchr='/';
    scheme = str;
   
    str = match + 3;
  }
  else if(StrNCmp("//",str,2) == 0)   
  {
    str = str + 2;lchr='/';
  }  

  // host
  if(str[0] != '/' && (match = StrMatch(":",str)) != NULL)   
  {
    // dgdfgdf:8080
    //        0
    match[0] = '\0';lchr=':';
    host = str;

    str = match + 1;
    
    // port
    if((match = StrMatch("/",str)) != NULL)   
    {
      // 8080/  
      match[0] = '\0';lchr='/';
      port = str;
   
      str = match+1;
    }
    else
    {
      // 8080<EOF> ! A / should be there anyway...      
      // dgdfgdf:8080
      port = str;

      str = str+StrLen(str);
    }
  }
  else if(str[0] != '/' && (match = StrMatch("/",str)) != NULL)   
  {
    // dgdfgdf/dgdfgdf
    match[0] = '\0';lchr='/';
    host = str;

    str = match + 1;
  }
  else if(str[0] != '/' && lchr == '/')
  {
    //dgdfgdf<EOF>
    host = str;

    str = str+StrLen(str); 
  }

  //path
  if((match = StrMatch("?",str)) != NULL)   
  {
    if(lchr == '/') absPath = TRUE;

    match[0] = '\0';lchr='?';
    path = str;

    str = match + 1;
  }
  else if((match = StrMatch("#",str)) != NULL)   
  {  
    if(lchr == '/') absPath = TRUE;

    match[0] = '\0';lchr='#';
    path = str;

    str = match + 1;
  }
  else
  {
    if(lchr == '/') absPath = TRUE;

    path = str;
    str = str+StrLen(str);
  }
 
  // query
  if(lchr == '?')
  {
    if((match = StrMatch("#",str)) != NULL)   
    {  
      match[0] = '\0';lchr='#';
      query = str;

      str = match + 1;
    }
    else
    {
      query = str;
      str = str+StrLen(str);
    }    
  }
  
  // fragment
  if(lchr == '#')
  {
    fragment = str;
  }

  if(absPath)
  {
    tmp = CAlloc(StrLen(path)+2);
    StrCpy(tmp+1,path);
    tmp[0] = '/';
    path = tmp;
  }

  // Every string will be copied, empty will be NULL
  URL *address = URLNew(scheme,host,port,path,query,fragment);


  if(tmp) Free(tmp);
  
  return address;

}






U0 DocNodeBrowsePrint(DocNode *dc,I64 depth,CDoc *doc,I64 doNext=TRUE)
{// up to 64 depth RECURSIVE. need to think twice
  if (!dc) return;


  if(depth == 0){DocPrint(doc,"$$WW,1$$$$BLACK$$");}  

  if(depth > 64){Print("Error Printing! Too Deep!");throw('TOODEEP');}

  I64 changedColor = FALSE;
  I64 changedUL = FALSE;
  I64 changedIV = FALSE;
  I64 changedWW = FALSE;


  I64 ident = 0;
  I64 changedSY = FALSE;
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
        DocPrint(doc,"\n");
      }
      
      if(StrICmp(dc->name,"br")==0)
      {
        DocPrint(doc,"\n");
        _docprintnewline = TRUE;
      }
      else if(CheckN(dc->name,"blockquote","ul","ol"))
      {
        DocPrint(doc,"$$ID,2$$\n");ident=2;HtmlPrint(doc," ");
      }
      else if(StrICmp(dc->name,"sub")==0)
      {
        DocPrint(doc,"$$SY,3$$");changedSY = TRUE;
      }
      else if(StrICmp(dc->name,"sup")==0)
      {
        DocPrint(doc,"$$SY,-3$$");changedSY = TRUE;
      }
      else if(CheckN(dc->name,"strong","b","th"))
      {
        DocPrint(doc,"$$IV,1$$");changedIV = TRUE;
      }
      else if(CheckN(dc->name,"i","cite"))
      {
        DocPrint(doc,"$$BLUE$$");changedColor = TRUE;
      }
      else if(StrICmp(dc->name,"li")==0)
      {
        DocPrint(doc,"þ ");
      }
      else if(StrICmp(dc->name,"mark")==0)
      {
        DocPrint(doc,"$$BG,YELLOW$$");changedColor = TRUE;
      }
      else if(StrICmp(dc->name,"ins")==0)
      {
        DocPrint(doc,"$$UL,1$$");changedUL = TRUE;
      }
      else if(StrICmp(dc->name,"hr")==0)
      {
        DocPrint(doc,"%h78c",'-');
      }
      else if(StrICmp(dc->name,"title")==0)
      {
        DocPrint(doc,"$$PURPLE$$$$TX+CX,\"");changedColor=TRUE;_docprintindol=TRUE;
      }
      else if(StrICmp(dc->name,"table")==0)
      {
        DocPrint(doc,"$$ID,2$$$$WW,0$$");changedWW=TRUE;ident=2;
      }
      else if(CheckN(dc->name,"h1","h2","h3","h4","h5","h6"))
      {
        if(StrICmp(dc->name,"h1")==0){DocPrint(doc,"$$PURPLE$$$$ID,2$$");ident=2;}
        if(StrICmp(dc->name,"h2")==0){DocPrint(doc,"$$RED$$$$ID,3$$");ident=3;}
        if(StrICmp(dc->name,"h3")==0){DocPrint(doc,"$$BLUE$$$$ID,4$$");ident=4;}
        if(StrICmp(dc->name,"h4")==0){DocPrint(doc,"$$DKGRAY$$$$ID,5$$");ident=5;}
        if(StrICmp(dc->name,"h5")==0){DocPrint(doc,"$$ID,6$$");ident=6;}
        if(StrICmp(dc->name,"h6")==0){DocPrint(doc,"$$ID,7$$");ident=6;}
        
        changedColor=TRUE;
      }
      else if(StrICmp(dc->name,"a")==0)
      {
        DocPrint(doc,"$$MA-X+PU,\"");_docprintindol=TRUE;
      }
      else if(StrICmp(dc->name,"iframe")==0)
      {
        DocPrint(doc,"(IFRAME)$$MA-X+PU,\"");_docprintindol=TRUE;
        HtmlPrintRaw(doc,DocNodeSearchAttr(dc->attr,"src","NULL"));
      }
      else if(StrICmp(dc->name,"button")==0)
      {
        DocPrint(doc,"$$MA-UL+B,\"");_docprintindol=TRUE;
      }
      else if(StrICmp(dc->name,"img")==0)
      {
        hrefValue = DocNodeSearchAttr(dc->attr,"alt","");
        DocPrint(doc,"$$LTBLUE$$");
        HtmlPrint(doc,"(IMG ",hrefValue,")");changedColor=TRUE;

        DocPrint(doc,"$$MA-X+PU,\"Download Img");_docprintindol=TRUE;            
      }
      
      }

      

      if(dc->child)  
        DocNodeBrowsePrint(dc->child,depth+1,doc);
         
      if(_docprintindol)
      {
      if(CheckN(dc->name,"a","iframe","img"))
      {
        hrefValue = DocNodeSearchAttr(dc->attr,"href",NULL);
        if(!hrefValue || StrLen(hrefValue)==0) hrefValue = DocNodeSearchAttr(dc->attr,"src","NULL");
        
        DocPrint(doc,"\",LM=\"KCTest(\\\"");
        HtmlPrintRaw(doc,hrefValue);
        DocPrint(doc,"\\\",\\\"");
        HtmlPrintRaw(doc,KC_PrevUrl);
        DocPrint(doc,"\\\");View;\n\"$$");
        
        _docprintindol=FALSE;
      }
      else if(StrICmp(dc->name,"title")==0)
      {
        DocPrint(doc,"\"$$\n\n");
        _docprintindol=FALSE;
      }
      else if(StrICmp(dc->name,"button")==0)
      {
        DocPrint(doc,"\"$$");_docprintindol=FALSE;
      }
      }

      if(!_docprintindol){
      
      if(changedColor)DocPrint(doc,"$$BLACK$$$$BG$$");
      if(changedUL)DocPrint(doc,"$$UL,0$$");
      if(ident>0)DocPrint(doc,"$$ID,-%d$$",ident);
      if(changedSY)DocPrint(doc,"$$SY,0$$");
      if(changedIV)DocPrint(doc,"$$IV,0$$");
      if(changedWW)DocPrint(doc,"$$WW,1$$");


      if(CheckN(dc->name,"th","td"))
      {
        DocPrint(doc,"\t");
      }
      

      if(block_level)
      {
        DocPrint(doc,"\n");
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

    HtmlPrint(doc,dc->innerText);
  }
  else{
    throw('NULL');
  }
  
  if(doNext){
    DocNode *node = dc->next;
    while(node)
    {
      DocNodeBrowsePrint(node,depth+1,doc,FALSE);

      node = node->next;
    }
  }

  if(depth == 0){DocPrint(doc,"$$FG$$");}  

}


//TestOffline = "<!DOCTYPE html><style>a>aa</style><script>bb</script> <html> <head> <meta charset=\"utf-8\"> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> <title>Conexao BD</title> <!--[if lt IE 9]> <script src=\"http://html5shiv.googlecode.com/svn/trunk/html5.js\"></script> <![endif]--> <!--  --  A >B- >AAA-->\r\n<!--sdfsdfsdf--><p>Oi?</p>  </head> <body> <h1>ERRO AO CARREGAR<span style=\"color:#FFFFFF\">(TEM ERRO NENHUM, SAIA DAQUI)</span></h1> <h2>jÃ¡ foram enviados 13 macacos treinados para resolver o problema.</h2> <img src=\"http://2.bp.blogspot.com/-hEKKrXmwVRc/TfbLrNH5eEI/AAAAAAAAoj4/_xs0Z3qAOD8/s1600/article-1206973-06153D1D000005DC-213_468x267.jpg\"/><br/> <a href=\"TESTE\">Teste</a> </body> </html>";
class FormUrl
{//Use <CTRL-l> and sel "Data", "List" or "Check Box"
//to generate the formats.
  U8  *Url	format "$$DA+M,A=\"URL:%s\"$$\n"; //+M is unlimited len U8 *.
};


U0 KCTest(U8 *url=NULL,U8 *prev_url=NULL,I64 PrintMemory=FALSE,I64 PrintHTML=FALSE)
{// path need to be relative

Print("\n\n$$WW,1$$$$PURPLE$$$$TX+CX,\"KC BROWSER\"$$$$FG$$\n\n");

URL *addr = NULL;
URL *prev_addr = NULL;
U8 *tmp = NULL;
U8 *rdn = NULL;
U8 *buffer = NULL;
DocNode *root = NULL;
CDoc *doc = NULL;
U8 *DocFilename = NULL;
I64 SUCCESS = FALSE;
DocNodeAttr *headers = NULL;

U8 *headerContentType = NULL;
do {

  if(url)
  {
    addr = ParseUrl(url);
  }

  if(url && prev_url)
  {
    prev_addr = ParseUrl(prev_url);

  if(!addr->scheme)
  {
    addr->scheme = prev_addr->scheme;
    prev_addr->scheme=NULL;
    if(!addr->host)
    {
    addr->host = prev_addr->host;
    prev_addr->host=NULL;

    if(!addr->port)
    {
      addr->port = prev_addr->port;
      prev_addr->port=NULL;

      if(!addr->path)
      {
        addr->path = prev_addr->path;
        prev_addr->path=NULL;

        if(!addr->query)
        {
          addr->query = prev_addr->query;
          prev_addr->query=NULL;
        }
      }
      else if(addr->path[0] != '/' && prev_addr->path)
      {
        // Relative
        // asdasd/asdasdas///asdasd.html
        U8 *cropped = prev_addr->path;
        U8 *match;
        while((match = StrMatch("/",cropped)) != NULL)
        {
          cropped = match+1;
        }
        // asdasd/asdasdas///asdasd.html
        //                   0
        cropped[0] = '\0';

        //U8 *newpath = CAlloc(StrLen(prev_addr->path)+StrLen(addr->path)+1);
        //StrCpy(newpath,prev_addr->path);
        //StrCpy(newpath+StrLen(prev_addr->path),addr->path);

        U8 *newpath = StrNew2(NULL,prev_addr->path,addr->path);
        Free(addr->path);
        addr->path = newpath;
      }
    }
    }
  }
  }


  if(!addr)
  {
    Print("?\n");

    FormUrl fds;
  
    // CAN'T Use Custom Memory
    fds.Url=StrNew("https://");

    if (DocForm(&fds)) 
    {
      "Typed=%s\n\n",fds.Url;
      
      addr = ParseUrl(fds.Url);

      
      Free(fds.Url);
    } 
    else
    {
      "Cancel\n";

      Free(fds.Url);
      break;
    }

    //"\n\nClassRep Example\n";  
    //ClassRep(&fds);
    
  }  


  buffer = CAlloc(HTML_BZ+1);//Max contiguous string
  

  if(!TestOffline)
  {

  if(!addr->host)
  {
    Print("Invalid URL, NULL host");break;
  }

  if(!addr->path)
  {
    addr->path = StrNew("/");
  }

  if(!addr->port)
  {
    if(addr->scheme)
    {
      if(StrICmp(addr->scheme,"http") == 0)
        addr->port = StrNew("80");
      else if(StrICmp(addr->scheme,"https") == 0)
        addr->port = StrNew("443");
      else
      {
        Print("Invalid Scheme, must be https or http.");break;   
      }
    }
    else addr->port = StrNew("443");
  }


  KC_PrevUrl = BuildUrl(addr);


  tmp = BuildUrl(addr,TRUE);
  // to allow different caches for different queries
  if(addr->query)
  {
    rdn = CAlloc(7);//6 chars
    I64 queryLen = StrLen(addr->query);
    rdn[0] = (queryLen%26)+'A';
    rdn[1] = ((queryLen/26)%26)+'A';
    if(queryLen>3)
    {
      I64 sum = addr->query[0] ^ addr->query[1] ^ addr->query[2]; 
      rdn[2] = (sum%26)+'A';
      rdn[3] = ((sum/26)%26)+'A';
    }

    rdn[4] = (addr->query[queryLen-1]%26)+'A';

    if(queryLen>1)
      rdn[5] = (addr->query[queryLen-2]%26)+'A';
  }
 
  // cut big paths
  if(StrLen(addr->path)+StrLen(addr->host) > 66)
  {
    if(StrLen(addr->host)>32)
    {
      addr->host[32] = '\0';
    }

    addr->path[66-StrLen(addr->host)] = '\0';
  }

  if(addr->path[StrLen(addr->path)-1] == '/')
  {
   
    DocFilename = StrNew2(NULL,"::/NetH/",addr->host,addr->path,rdn,"index.DD");
  }
  else
  {
    DocFilename = StrNew2(NULL,"::/NetH/",addr->host,addr->path,rdn,".DD");
  }

  // Remove %
  StrFileSafe(DocFilename+3);
  
  Print("\nUrl: %s\n\n\n\nHost: %s\n\nPort: %s\n\nPath: %s\n\nFilename: %s\n\nVisit this Page? ",KC_PrevUrl,addr->host,addr->port,tmp,DocFilename);

  if(!YorN){break;}

  HttpResetIter;

  SerialBegin(1,9600);
  SerialFlush();

  if(TunnelPing() && TunnelPing())
  {
    Print("\n");

    
      HttpGet(addr->host,addr->port,tmp,KCookiesGenCookieLine(),0);

      headers = HttpParseHeaders(buffer,HTML_BZ);
      
      if(tmp)Free(tmp);
      if((tmp=DocNodeSearchAttr(headers,"Location"))!=NULL)
      {
        Print("Click to Follow Redirect:\n$$MA,\"%s\",LM=\"KCTest(\\\"%s\\\",\\\"%s\\\");\n\"$$\n\n",
        tmp,tmp,KC_PrevUrl);
        tmp=NULL;

        //break; 
      }

      headerContentType = DocNodeSearchAttr(headers,"Content-Type");

      KCookiesParseHeaders(headers);
  }
  else
  {
    Print("\nPing to Tunnel Failed!\n");break;
  }
}
else
{
  HttpResetIter;
}


  // Create DolDoc at filename location
  doc=DocNew(DocFilename);    
  doc->flags|=DOCF_PLAIN_TEXT|DOCF_NO_CURSOR;



  I64 lchr;
  if(headerContentType == NULL)
  {// Unknown, a error?
    Print("\n\nNULL CONTENT TYPE\n\n");
    if(YorN){

    lchr= HttpFill(buffer,HTML_BZ);
    SingleHtmlPrintRaw(doc,buffer,TRUE);

    SUCCESS = TRUE;    
    }
  }
  else if(StrNICmp(headerContentType,"text/html",9)==0)
  {

    root = DocNodeNew(NULL,"ROOT",NULL);

    HtmlParse(root,buffer);

    Print("\n\nFinished Parsing\n\n");

    DocPrint(doc,"URL:\n$$MA-X+PU,\"%s\",LM=\"KCTest(\\\"%s\\\");View;\n\"$$\n\n\n",
    KC_PrevUrl,KC_PrevUrl);

    if(PrintHTML)
      DocNodePrint(root,FALSE,0,doc);


    DocNodeBrowsePrint(root,0,doc);

    SUCCESS = TRUE;
  }
  else if(StrNICmp(headerContentType,"text",4)==0)
  {
    Print("\n\nPLAIN TEXT %s\n\n",headerContentType);
    if(YorN){

    lchr= HttpFill(buffer,HTML_BZ);

    SingleHtmlPrintRaw(doc,buffer,TRUE);


          
    SUCCESS = TRUE;
    }
  }
  //else  application/x-www-form-urlencoded 
  //
  //
  else // Binary
  {
    Print("\n\nUNSUPORTED CONTENT TYPE %s\n\n",headerContentType);
    if(YorN){

    //SerialReadStringOut(CHAR_END);// TESTING
    lchr= HttpFill(buffer,HTML_BZ);

    DocFilename[StrLen(DocFilename)-4] = '.';
    DocFilename[StrLen(DocFilename)-3] = 'B';
    DocFilename[StrLen(DocFilename)-2] = 'I';
    DocFilename[StrLen(DocFilename)-1] = 'N';

    FileWrite(DocFilename,buffer,lchr);


    SUCCESS = FALSE; // To not write the doc
    }
  }

  if(SUCCESS)
  {   
    try
    {
      DocWrite(doc,FALSE);
      SUCCESS = TRUE;
    }
    catch 
    {
      "Error: Ch:%c:%P\n",Fs->except_ch,Fs->except_callers[0];
      if (Fs->except_ch=='Drv') {
        "Filename...\n";
      }
      Fs->catch_except=TRUE;

      // trying again...
      
      StrCpy(doc->filename.name,"::/Home/Net/out.DD");
      DocWrite(doc,FALSE);
      SUCCESS = FALSE;
    }
  }
}
while(FALSE);

// Free Everything

if(buffer)Free(buffer);

if(addr)URLDel(addr);

if(prev_addr)URLDel(prev_addr);

if(tmp)Free(tmp);

if(rdn)Free(rdn);

if(doc)DocDel(doc);

if(root)DocNodeDel(root);

if(headers)DocNodeAttrDel(headers,TRUE);

if(KC_PrevUrl)Free(KC_PrevUrl);
KC_PrevUrl = NULL;

if(iterBuffer)Free(iterBuffer);
iterBuffer = NULL;

if(DocFilename)
{
  tmp = StrNew(DocFilename);
  Free(DocFilename);

  DocFilename = tmp;
  tmp = NULL;
}

Print("\n");
Print("\n");


//if(!SUCCESS || PrintMemory)
//  CustomMemoryPrint();
//else
//  CustomMemoryCheck();
//CustomMemoryReset();


if(DocFilename)
{
  Ed(DocFilename);
  Free(DocFilename);
}

}

KCTest(NULL,NULL,TRUE);

//KCTest("?q=COVID19","https://www.google.com/search");
//KCTest("https://app.passapassa.com.br/passapassa/");

//KCTest("https://www.jw.org/pt/",NULL,TRUE);
//KCTest("https://stackoverflow.com/questions/23714383/what-are-all-the-possible-values-for-http-content-type-header",NULL,TRUE);
//KCTest("https://raw.githubusercontent.com/erickweil/TempleOS-Stuff/main/Home/bomdia.DD",NULL,TRUE);
//KCTest("https://www.google.com/search?q=cats&tbm=isch",NULL,TRUE);
//KCTest("https://www.old.reddit.com/",NULL,TRUE);
//KCTest("https://www.reddit.com/",NULL,TRUE);

//}
//}

//test();

//Print("END");

U0 testURL()
{


U8 *static_str = "https://aaa:bbb/ccc/ccc/cc?asadsdasd#sdfsffd";
U8 *str = CMCAlloc(StrLen(static_str)+1);
StrCpy(str,static_str);


URL *addr = ParseUrl(str);

Print("%s \n\n",static_str);

if(addr->scheme) Print("Scheme: %s\n",addr->scheme);
if(addr->host) Print("Host: %s\n",addr->host);
if(addr->port) Print("Port: %s\n",addr->port);
if(addr->path) Print("Path: %s\n",addr->path);
if(addr->query) Print("Query: %s\n",addr->query);
if(addr->fragment) Print("Fragment: %s\n",addr->fragment);

U8 *rebuild_str = BuildUrl(addr);

Print("%s \n\n",rebuild_str);


URLDel(addr);
addr = NULL;

CMFree(str);
CMFree(rebuild_str);
//if(YorN){
//CustomMemoryPrint();
//}

CustomMemoryPrint();

CustomMemoryReset();
}


/*
 
You can find every content type here:
$MA-X+PU,"http://www.iana.org/assignments/media-types/media-types.xhtml",LM="KCTest(\"http://www.iana.org/assignments/media-types/media-types.xhtml\",\"https://stackoverflow.com:443/questions/23714383/what-are-all-the-possible-values-for-http-content-type-header\");View;\n"$


The most common type are:


$ID,2$
 þ Type application 
application/java-archive
application/EDI-X12 
application/EDIFACT 
application/javascript 
application/octet-stream 
application/ogg 
application/pdf 
application/xhtml+xml 
application/x-shockwave-flash 
application/json 
application/ld+json 
application/xml 
application/zip 
application/x-www-form-urlencoded 

þ Type audio 
audio/mpeg 
audio/x-ms-wma 
audio/vnd.rn-realaudio 
audio/x-wav 

þ Type image


image/gif 
image/jpeg 
image/png 
image/tiff 
image/vnd.microsoft.icon 
image/x-icon 
image/vnd.djvu 
image/svg+xml 

þ Type multipart 
multipart/mixed 
multipart/alternative 
multipart/related (using by MHTML (HTML mail).) 
multipart/form-data 

þ Type text 
text/css 
text/csv 
text/html 
text/javascript (obsolete) 
text/plain 
text/xml 

þ Type video 
video/mpeg 
video/mp4 
video/quicktime 
video/x-ms-wmv 
video/x-msvideo 
video/x-flv 
video/webm 

þ Type vnd : 
application/vnd.android.package-archive
application/vnd.oasis.opendocument.text 
application/vnd.oasis.opendocument.spreadsheet 
application/vnd.oasis.opendocument.presentation 
application/vnd.oasis.opendocument.graphics 
application/vnd.ms-excel 
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet 
application/vnd.ms-powerpoint 
application/vnd.openxmlformats-officedocument.presentationml.presentation 
application/msword 
application/vnd.openxmlformats-officedocument.wordprocessingml.document 
application/vnd.mozilla.xul+xml 

$ID,-2$
*/

//testURL();