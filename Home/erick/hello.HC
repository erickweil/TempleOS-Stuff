// Hello, first of all, I'm from Brazil, so sorry for portuguese comments
// This file have a function called Listdirs, it allows you to list dirs
// Really, is a ICONIFIEDdir listing.
// Include this file, then call the function
// Like that:
// #include "hello";Listdirs(1);


#include "::/Home/erick/image";
#include "::/Home/erick/StringUtils";



//##################################################
//                    TESTS
// Trying to understand HolyC
//##################################################


// Para escrever algum texto
U0 texto() 
{//Veja que texto sozinho funciona tambem
// Pode tambem formatar valores

"Hello World!!!\n";
Print("Hello World!!\n\n");
"Exemplo de valor:%d \n", 100;

}


// Variaveis
//	U0	void
//	I8	char
//	I32	int
//	F64	float

U0 variaveis()
{// Experimentando a declaracao de variaveis

I32 numero = 16;
"O valor e: %d \n", numero;
F64 real = 3.2;

"O outro valor e: %d \n", real;

if(numero < 20)
{
	"Essa linha deve escrever\n";
}
else
{
	"ERRONAOERAPARAESCREVER\n";
}


}


U0 fibonacci()
{// Escreve os numeros de fibonacci de 1 ate 144
I32 a = 0;
I32 b = 1;
I32 c = 0;

while(a < 100)
{
c = a;
a = a + b;
b = c;
"%d \n", a;
}
}


I32 fibonacci_rec(I32 iter)
{//Cuidado com recursividade porque se for infinito crasha o sistema
if(iter <= 1) return 1;
else return fibonacci_rec(iter-1) + fibonacci_rec(iter-2);
}

//##################################################
//                   LISTDIRS
//Here our journey begins
//##################################################

U0 MyPutFileLink(U8 *filename,U8 *full_name=NULL)
{//Put $LK,"DolDoc",A="FI:::/Doc/DolDocOverview.DD"$ file,line link to StdOut, $LK,"DocPut",A="MN:DocPut"$.
  if (!filename) return;

//  LK_DOC,LK_DOC_ANCHOR,LK_DOC_FIND,LK_DOC_LINE
  if (filename[0]=='A'&&filename[2]==':') {
  
    "$$LK,\"%s\",A=\"AI:%s\"$$",filename+3,filename+3;
  }
  else 
  {
    if(StrFind(".DD.Z",filename) || StrFind(".DD",filename) ) 
    {
     
      "$$LK-UL,\"%s\",A=\"FI:%s\"$$",filename,full_name; 
    }
    else if(StrFind(".HC.Z",filename) || StrFind(".HC",filename) ) 
    {
      "$$BG,YELLOW$$";
      "$$LK-UL,\"%s\",A=\"FI:%s\"$$$$FG$$$$BG$$",filename,full_name; 
    }
    else
    {
      "$$LK-UL,\"%s\",A=\"FI:%s\"$$$$IV,0$$$$FG$$$$BG$$",filename,full_name; 
    }
  }

}

//U0 SpriteWithLM(U8 *LM_action)
//{
//"$$SP+PU,\" \",LM=\"#include \"::/Apps/Titanium/Run\"",BI=1$$"
//}

U0 PrintGraphicDirEntry(CDirEntry *dir,I64 row_step,I64 max_name)
{// Desenha um diretorios ou arquivo na tela, como um texto DolDoc
  if (!dir) return;
   
  //I64 name_len = StrLen(dir->name);
  U8 *str = NULL; 
  if (dir->attr & RS_ATTR_DIR)
  {
    str = "$$MA-UL,T=\"%s\",LM=\"Cd(\\\"%s\\\");Listdirs(1);\n\"$$";  
    if(row_step == 0) 
    {
     //Print("%h*c",max_name/2-1,' ');
     Print("$$CM-RE,LE=%d$$",max_name/2);

     MySprite(1);
     
     Print("$$CM-RE,LE=%d$$",max_name/2);
          
    }
    else if(row_step >= 1)
    {   
       // "%h*c",(max_name-name_len)/2,' ';       
        Print(str,
        SU_centralize(dir->name,max_name,row_step-1),
        dir->full_name);
       // "%h*c",(max_name-name_len)/2 + (max_name-name_len)%2,' ';
    }
  }
  else
  {
    str = "$$LK-UL,\"%s\",A=\"FI:%s\"$$"; 
    if(row_step == 0) 
    {
     Print("$$CM-RE,LE=%d$$",max_name/2);

     
     if(StrFind(".DD.Z",dir->name) || StrFind(".DD",dir->name) ) 
     {  
      MySprite(3$ER$); // DolDoc 
     }
     else if(StrFind(".HC.Z",dir->name) || StrFind(".HC",dir->name) )  
     {
      MySprite(4$ER$); // HolyC
     }
     else
     {
      MySprite(2$ER$); 
     }
     Print("$$CM-RE,LE=%d$$",max_name/2);
     
    }
    if(row_step >= 1)
    {
       //"%h*c",(max_name-name_len)/2,' ';       
        Print(str,
        SU_centralize(dir->name,max_name,row_step-1),
        dir->full_name); 
       //"%h*c",(max_name-name_len)/2 + (max_name-name_len)%2,' ';      
    }
    
  }

}


I64 PrintDirEntry(CDirEntry *dir)//,I64 count, I64 max_count)
{
  if (!dir) return 0;
 
  I64 name_count = StrLen(dir->name);

//  if (dir->attr & RS_ATTR_DIR)
//   name_count += 3;
//  else
//   name_count += 2;

  
//  if((count + name_count) > max_count)
//  {
//    Print("\n\n\n\n");
//    name_count = -StrLen(dir->name);
 // }
//  else if(count > 0) 
//  {
//    Print("$$CM-RE,LE=2$$");
//  }
  
  
  if (dir->attr & RS_ATTR_DIR)
  {    
    "$$MA-UL,T=\"%s\",LM=\"Cd(\\\"%s\\\");Listdirs();\n\"$$",
    dir->name,
    dir->full_name;

    return name_count;
  }
  else
  {    
    MyPutFileLink(dir->name,dir->full_name);
    return name_count;
  }

}


//                   Listdirs
// This function draws files and directories with icons
// Make sure to call with graphic arg set to 1 in order to see icons
// - Automatically detects the terminal width (but don't update after)
// - Files with name too long will be wraped and may truncate last part
// - Only Directories, .DD and .HC files have unique icons
// - See $LK,"StringUtils",A="FI:::/Home/erick/StringUtils.HC"$ and $LK,"image",A="FI:::/Home/erick/image.HC"$
U0 Listdirs(I64 graphic = 0)
{//List directory.
  // Para ficar limpo sempre
  //DocTermNew;

  // Causa BADFREE
  // DocClear;
  CTask *task = Fs;
  // Calcular o tamanho da tela
  I64 max_count = task->win_right - task->win_left;
  // I64 columns = 8;
  // I64 max_name = (max_count / columns)-2;
 
  I64 max_name = 10;
  I64 columns = max_count/(max_name+1);
  
 
  // Cria uma string (eh um array de char)
  U8 *st;
  // Recebe o valor de texto do diretorio atual
  st=DirCur;
  // Escreve na tela
  Print("$$FG$$$$BG$$$$MA,\"Directory\",LM=\"PopUpCd;Listdirs(%d);\\n\"$$ of %s",
  graphic,st
  ); 

  Print("\n\n");

  //Opcoes
  if(graphic == 0)
  {
    "$$MA-UL,T=\"Icon Mode\",LM=\"Listdirs(1);\n\"$$";
  }
  else
  {
    "$$MA-UL,T=\"List Mode\",LM=\"Listdirs();\n\"$$";
  }

  "    $$MA-UL,T=\"Clear Term\",LM=\"DocTermNew;Listdirs(%d);\n\"$$",graphic;
  

  // Carrega uma lista de diretorios
  CDirEntry *dirlist = FilesFind("*");
  Print("\n");
  I64 count = 0;

  Print("\n\n");
  count = 0;

  if(graphic == 0)
  {
  Print("$$ID,2$$");

  while (dirlist) {
    //Free(st);
    //st=MAllocIdent(dirlist->full_name);
    //Print(st);
    I64 name_count = PrintDirEntry(dirlist);//,count,max_count);
    if(name_count < 0)
    {
      count = -name_count;
    }
    else
    {
      count += name_count;
    }
    //Print(dirlist->full_name);
    Print("\n");
    CDirEntry *dirtmp = dirlist->next;    
    DirEntryDel(dirlist);
    dirlist = dirtmp;
  }
  Print("$$ID,-2$$\n\n");

  // Libera a lista de diretorios
  DirEntryDel(dirlist); 

  }
  else
  {
  while (dirlist) {
   

    
    CDirEntry *rowHead = dirlist;
    I64 row_step;
    for(row_step=0;row_step<3;row_step++)
    {
      dirlist = rowHead;
      count = 0;
      while(count < columns && dirlist)
      {
        Print("$$CM-RE,LE=1$$");
        PrintGraphicDirEntry(dirlist,row_step,max_name);
    
        // Nao deleta.. deleta depois
        dirlist = dirlist->next;
        count+=1;
      }
      if(row_step==0)
      Print("\n\n");

      Print("\n");
    }
    Print("\n");
    // Deletando o result
    dirlist = rowHead;
    count = 0;
    while(count < columns && dirlist)
    {
      CDirEntry *dirtmp2 = dirlist->next;
      DirEntryDel(dirlist);
      dirlist = dirtmp2;
      count+=1;
    }
    
  }
  }
  //Print("$$ID,-2$$\n\n");
  //else
  //{
  //  Print("No Dirs!\n"); 
  //}





  // Libera a string
  SU_freeBuffer;
  Free(st);
}

//Listdirs(1);