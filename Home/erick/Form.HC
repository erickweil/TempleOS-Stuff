//  See $LK,"::/Demo/DolDoc/Form.HC"$
class FormUrl
{//Use <CTRL-l> and sel "Data", "List" or "Check Box"
//to generate the formats.
  U8  *Url	format "$$DA+M,A=\"URL:%s\"$$\n"; //+M is unlimited len U8 *.
};

U0 FormDemo()
{

  Print("Teste\n\nEditar o URL?");
  if(YorN){
  FormUrl fds;
  
  // CAN'T Use Custom Memory
  fds.Url=StrNew("https://google.com");
  
  if (DocForm(&fds)) 
  {
    "Url=%s\n",fds.Url;

  } 
  else
  {
    "Cancel\n";
  }

  "\n\nClassRep Example\n";  

  ClassRep(&fds);
  Free(fds.Url);
  }  

  //See also $LK,"ClassRepD",A="MN:ClassRepD"$().
}

FormDemo;


