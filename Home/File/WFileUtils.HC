/*
$LK,"Doc Overview",A="FI:::/Doc/DolDocOverview.DD"$
$LK,"Doc Routines",A="HI:DolDoc"$


See $LK,"::/Doc/Widget.DD"$, $LK,"::/Demo/DolDoc/DemoDoc.DD"$, and $LK,"::/Demo/ToHtmlToTXTDemo/ToHtml.HC"$.


*/

// Allow managing of Files as DolDoc's

U0 StringAsDoc(U8 *string,U8 *name)
{

//  SettingsPush; //See $LK,"SettingsPush",A="MN:SettingsPush"$
//  WinHorz(0,80-1); //Sets doc width for word wrap.
  
  CDoc *doc=DocNew(name);    
  doc->flags|=DOCF_PLAIN_TEXT|DOCF_NO_CURSOR;

  DocPrint(doc,"%s",string); 
 
  DocWrite(doc,FALSE);
  
  DocDel(doc);

//  SettingsPop;
}

/*
StringAsDoc("Teste de$$$$ Documento DolDocTeste de Documento DolDocTeste de Documento DolDocTeste de Documento DolDocTeste de Documento D
olDocTeste de Documento DolDocTest
 de Documento DolDocTeste de Documento DolDocTeste de
 Documento DolDocTeste de Documento DolDocTeste de Documento
 DolDoc","::/Home/File/Teste.DD");

*/