// use Custom Memory

#include "::/Home/Net/HtmlParser"

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
  res=CMCAlloc(sizeof(URL));
  
  res->scheme = NULL;
  res->host = NULL;
  res->port = NULL;
  res->path = NULL;
  res->query = NULL;
  res->fragment = NULL;

  if(scheme && StrLen(scheme) > 0)
  {
    res->scheme = CMCAlloc(StrLen(scheme)+1);
    StrCpy(res->scheme,scheme);
  }
  if(host&& StrLen(host) > 0)
  {
    res->host = CMCAlloc(StrLen(host)+1);
    StrCpy(res->host,host);
  }
  if(port && StrLen(port) > 0)
  {
    res->port = CMCAlloc(StrLen(port)+1);
    StrCpy(res->port,port);
  }
  if(path && StrLen(path) > 0)
  {
    res->path = CMCAlloc(StrLen(path)+1);
    StrCpy(res->path,path);
  }
  if(query && StrLen(query) > 0)
  {
    res->query = CMCAlloc(StrLen(query)+1);
    StrCpy(res->query,query);
  }
  if(fragment && StrLen(fragment) > 0)
  {
    res->fragment = CMCAlloc(StrLen(fragment)+1);
    StrCpy(res->fragment,fragment);
  }

  return res;
}

U0 URLDel(URL *res)
{//Don't free the next
  if (!res) return;

  if(res->scheme)CMFree(res->scheme);
  if(res->host)CMFree(res->host);
  if(res->port)CMFree(res->port);
  if(res->path)CMFree(res->path);
  if(res->query)CMFree(res->query);
  if(res->fragment)CMFree(res->fragment);
  
  CMFree(res);
};


U8 *BuildUrl(URL *a,I64 GetOnly=FALSE)
{
  U8 *buf = CMCAlloc(
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
    match[0] = '\0';lchr=':';
    scheme = str;
   
    str = match + 3;
  }
  else if(StrNCmp("//",str,2) == 0)   
  {
    str = str + 2;
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
    tmp = CMCAlloc(StrLen(path)+2);
    StrCpy(tmp+1,path);
    tmp[0] = '/';
    path = tmp;
  }

  // Every string will be copied, empty will be NULL
  URL *address = URLNew(scheme,host,port,path,query,fragment);


  if(tmp) CMFree(tmp);
  
  return address;

}






U0 DocNodeBrowsePrint(DocNode *dc,I64 depth,CDoc *doc,I64 doNext=TRUE)
{// up to 64 depth RECURSIVE. need to think twice
  if (!dc) return;


  if(depth == 0){DocPrint(doc,"$$WW,1$$$$BLACK$$");}  

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
        DocPrint(doc,"\n");
      }
      
      if(StrICmp(dc->name,"br")==0)
      {
        DocPrint(doc,"\n");
        _docprintnewline = TRUE;
      }
      else if(CheckN(dc->name,"h1","h2","h3","h4","h5","h6"))
      {
        DocPrint(doc,"$$PURPLE$$$$ID,2$$");changedColor=TRUE;ident=2;
      }
      else if(StrICmp(dc->name,"a")==0)
      {
        DocPrint(doc,"$$MA,\"");_docprintindol=TRUE;
      }
      else if(StrICmp(dc->name,"img")==0)
      {
        //hrefValue = DocNodeSearchAttr(dc,"alt","");
        //Print("\n$$MA+B-UL,\"IMG%s\"$$\n",hrefValue);
      }
      
      }

      if(dc->child)  
        DocNodeBrowsePrint(dc->child,depth+1,doc);
      

      if(StrICmp(dc->name,"a")==0)
      {
        hrefValue = DocNodeSearchAttr(dc,"href","NULL");
        DocPrint(doc,"\",LM=\"KCTest(\\\"%s\\\",\\\"%s\\\");\"$$",
        hrefValue,KC_PrevUrl);
        
        _docprintindol=FALSE;
      }

      if(!_docprintindol){
      
      if(changedColor)DocPrint(doc,"$$BLACK$$$$UL,0$$");
      if(ident>0)DocPrint(doc,"$$ID,-%d$$",ident);

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


//TestOffline = "<!DOCTYPE html><style>a>aa</style><script>bb</script> <html> <head> <meta charset=\"utf-8\"> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> <title>Conexao BD</title> <!--[if lt IE 9]> <script src=\"http://html5shiv.googlecode.com/svn/trunk/html5.js\"></script> <![endif]--> <!--  --  A >B- >AAA-->\r\n<!--sdfsdfsdf--><p>Oi?</p>  </head> <body> <h1>ERRO AO CARREGAR<span style=\"color:#FFFFFF\">(TEM ERRO NENHUM, SAIA DAQUI)</span></h1> <h2>já foram enviados 13 macacos treinados para resolver o problema.</h2> <img src=\"http://2.bp.blogspot.com/-hEKKrXmwVRc/TfbLrNH5eEI/AAAAAAAAoj4/_xs0Z3qAOD8/s1600/article-1206973-06153D1D000005DC-213_468x267.jpg\"/><br/> <a href=\"TESTE\">Teste</a> </body> </html>";


U0 KCTest(U8 *url,U8 *prev_url=NULL)
{// path need to be relative

URL *addr = ParseUrl(url);
URL *prev_addr = NULL;
if(prev_url)
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

        U8 *newpath = CMCAlloc(StrLen(prev_addr->path)+StrLen(addr->path)+1);
        StrCpy(newpath,prev_addr->path);
        StrCpy(newpath+StrLen(prev_addr->path),addr->path);
        CMFree(addr->path);
      
        addr->path = newpath;
      }
    }
    }
  }
  URLDel(prev_addr);
}


HttpResetIter;


if(!TestOffline)
{
SerialBegin(1,9600);
SerialFlush();

TunnelPing();
TunnelPing();
Print("\n");

U8 *host = addr->host;
U8 *getPath = addr->path;
U8 *port = addr->port;

if(!host)
{
  Print("Invalid URL");return;
}

if(!getPath)
{
  addr->path = CMStr("/");
}

if(!port)
{
  if(addr->scheme)
  {
    if(StrICmp(addr->scheme,"http") == 0)
    addr->port = CMStr("80");
    else if(StrICmp(addr->scheme,"https") == 0)
    addr->port = CMStr("443");
    else
    {
      Print("Invalid Scheme");return;   
    }
  }
  else addr->port = CMStr("443");
}

KC_PrevUrl = BuildUrl(addr);


U8 *tmp = BuildUrl(addr,TRUE);


Print("\n%s\n\nHost:%s:%s\nPath:%s\n\n",KC_PrevUrl,addr->host,addr->port,tmp);

if(!YorN){return;}


HttpGet(addr->host,addr->port,tmp,0);

URLDel(addr);
CMFree(tmp);

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

//Print("Print Doc?:");if(YorN){}
//DocNodePrint(root);
//DocNodeBrowsePrint(root);


// Create DolDoc at filename location
CDoc *doc=DocNew("::/Home/Net/outbrowse.DD");    
doc->flags|=DOCF_PLAIN_TEXT|DOCF_NO_CURSOR;

DocNodeBrowsePrint(root,0,doc);

DocWrite(doc,FALSE);

DocDel(doc);





CMFree(KC_PrevUrl);
//Print("Free Doc?");if(ask && YorN){}
DocNodeDel(root);

//HtmlContent();

Print("\n");
Print("\n");

CMFree(iterBuffer);
iterBuffer = NULL;

//if(YorN){
//CustomMemoryPrint();
//}

CustomMemoryPrint();


//CustomMemoryFree();
CustomMemoryReset();


Ed("::/Home/Net/outbrowse.DD");
}

//while(YorN)
//{
//HttpResetIter();
//KCTest("templeos.org","");

KCTest("?q=Test","https://www.google.com/search");
//KCTest("https://app.passapassa.com.br/passapassa/");
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


//testURL();