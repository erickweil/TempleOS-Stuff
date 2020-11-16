//Place this file in /Home and change
//anything you want.

U0 UserStartUp()
{//Run each time a user a spawned
  DocTermNew;
  Type("::/Doc/Start.DD");
  Print("\n\n    $$MA+B-UL,\"Graphic Dir\",LM=\"#include \\\"::/Home/erick/hello.HC\\\";\\nListdirs(1);\\n\"$$");
  Print("    $$MA+B-UL,\"KC Browser\",LM=\"#include \\\"::/Home/Net/KCBrowser.HC\\\";\\n\"$$\n\n");
  LBts(&Fs->display_flags,DISPLAYf_SHOW);
  WinToTop;
  WinZBufUpdate;
  Dir;
}

U0 SrvStartUp()
{//Run each time a srv task is spawned.
  DocTermNew;
  LBts(&Fs->display_flags,DISPLAYf_SHOW);
  WinToTop;
  WinZBufUpdate;
}

U0 StartUpTasks()
{
//  CTask *user1,*user2;
//  user1=User;
//  user2=User;
//  WinToTop(user1);
//  WinTileVert;
//  "Boot Time:%7.3fs\n",tS;
//  XTalk(user1,"Cd;#include \"Once\";\n");
//  Silent;	//no output to scrn
//  ACInit("/*;!*/Bible.TXT*");
//  Silent(OFF); //no output to scrn

  // Assim vai ter so 1 terminal
  CTask *user1;
  user1=User;
  
  WinToTop(user1);
  WinMax(user1);
  //WinTileVert;
  "Boot Time:%7.3fs\n",tS;
  XTalk(user1,"Cd;#include \"Once\";\n");
  Silent;	//no output to scrn
  ACInit("/*;!*/Bible.TXT*");
  Silent(OFF); //no output to scrn

}

StartUpTasks;

"\nTempleOS V%5.3f\t%D %T\n\n",sys_os_version,sys_compile_time,sys_compile_time;

"\n\nBom dia!\n\n";
