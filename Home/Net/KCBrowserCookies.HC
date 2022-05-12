// Needs HtmlFunctions


DocNodeAttr *KC_Cookies;

U0 KCookies()
{
  Print("Creating Cookies");
  KC_Cookies = DocNodeAttrNew("COOKIES",NULL);
}

KCookies;


U0 KCookiesParseLine(U8 *cookieLine)
{
  if(!cookieLine || StrLen(cookieLine) == 0) return;

  //name=value;........ other info .......

  U8 *match = StrMatch("=",cookieLine);
  if(!match) return;

  match[0] = '\0';

  U8 *cookieName=cookieLine; 

  U8 *match2 = StrMatch(";",match+1);
  if(!match2) return;

  match2[0] = '\0';

  U8 *cookieValue=match+1; 


  DocNodeAttr *existing_attr = DocNodeSearchAttrNode(KC_Cookies,cookieName);
  if(existing_attr)
  {
    Free(existing_attr->value);
    existing_attr->value = StrNew(cookieValue,adam_task);
  }
  else
  {
    DocNodeAttr *newCookie = DocNodeAttrNew(cookieName,cookieValue,adam_task);
    DocNodeAttr *_cookies = KC_Cookies;

    KC_Cookies = newCookie;
    KC_Cookies->next = _cookies;
  }
}

U0 KCookiesParseHeaders(DocNodeAttr *attr)
{
  
  while(attr != NULL)
  {
    if(attr->name && StrICmp(attr->name,"Set-Cookie")==0)
    {
      KCookiesParseLine(attr->value);
    }
    attr = attr->next;
  }

}

U8 *KCookiesGenCookieLine()
{
  U8 *_tmp = NULL;
  U8 *ret = NULL;

  DocNodeAttr *attr = KC_Cookies;
  while(attr != NULL)
  {
    if(ret)
    {
      _tmp = StrNew2(NULL,ret,"; ",attr->name,"=",attr->value);
      Free(ret);
    }
    else
      _tmp = StrNew2(NULL,attr->name,"=",attr->value);
    
    
    ret = _tmp;
    
    attr = attr->next;
  }
  return ret;
}