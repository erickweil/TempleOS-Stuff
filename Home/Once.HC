//Place this file in /Home and change
//anything you want.

//This file is executed by the
//first terminal window upon start-up.
//See $LK,"Once",A="FF:~/HomeSys.HC,Once"$ and $LK,"Home Files",A="FF:::/Doc/GuideLines.DD,/Home Files"$.

//Delete the rest from this file.

// Copied from $LK,"Keyboard",A="::/Kernel/SerialDev/Keyboard.HC.Z"$


#define KEY_TABLE_SIZE	80

asm {
PTBR_NORMAL_KEY_SCAN_DECODE_TABLE::
	DU8	0,CH_ESC,"1234567890-=",CH_BACKSPACE,'\t'; //16
	DU8	"qwertyuiop[[",'\n',0,"as";                //32
	DU8	"dfghjkl;~'",'\\',"]zxcv";                 //48
	DU8	"bnm,.;/",'*',0,CH_SPACE,0,0,0,0,0,0;      //64
	DU8	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0;       //80
PTBR_SHIFT_KEY_SCAN_DECODE_TABLE::
	DU8	0,CH_SHIFT_ESC,"!@#$$%^&*()_+",CH_BACKSPACE,'\t';
	DU8	"QWERTYUIOP`{",'\n',0,"AS";
	DU8	"DFGHJKL:^\"",0,"}ZXCV";
	DU8	"BNM<>:?",'*',0,CH_SHIFT_SPACE,0,0,0,0,0,0;
	DU8	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0;
PTBR_CTRL_KEY_SCAN_DECODE_TABLE::
	DU8	0,CH_ESC,"1234567890-=",CH_BACKSPACE,'\t';
	DU8	CH_CTRLQ,CH_CTRLW,CH_CTRLE,CH_CTRLR,CH_CTRLT,CH_CTRLY,CH_CTRLU,
		CH_CTRLI,CH_CTRLO,CH_CTRLP,"[]",'\n',0,CH_CTRLA,CH_CTRLS;
	DU8	CH_CTRLD,CH_CTRLF,CH_CTRLG,CH_CTRLH,CH_CTRLJ,CH_CTRLK,CH_CTRLL,
		";'\`",0,"\\",CH_CTRLZ,CH_CTRLX,CH_CTRLC,CH_CTRLV;
	DU8	CH_CTRLB,CH_CTRLN,CH_CTRLM,",./",0,'*',0,CH_SPACE,0,0,0,0,0,0;
	DU8	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0;
}


/*
U8 ScanCode2Char(I64 sc)
{//Scan code to ASCII val.
  U8 *table=NORMAL_KEY_SCAN_DECODE_TABLE;
  if (sc&SCF_E0_PREFIX)
    return 0;
  if (sc&SCF_CTRL)
    table=CTRL_KEY_SCAN_DECODE_TABLE;
  else if (sc&SCF_SHIFT) {
    if (!(sc&SCF_CAPS))
      table=SHIFT_KEY_SCAN_DECODE_TABLE;
  } else {
    if (sc&SCF_CAPS)
      table=SHIFT_KEY_SCAN_DECODE_TABLE;
  }
  sc&=0x7F;
  if (sc>=0x50)
    return '?';
  else
    return table[sc];
}
*/

// Need reboot to restore back
U0 setKeyboard(U8 *normal,U8 *shift, U8 *ctrl)
{
  I64 k;
  U8 *normal_table = NORMAL_KEY_SCAN_DECODE_TABLE;
  U8 *shift_table = SHIFT_KEY_SCAN_DECODE_TABLE;
  U8 *ctrl_table = CTRL_KEY_SCAN_DECODE_TABLE;
  for(k=0;k<KEY_TABLE_SIZE;k++)
  {
    normal_table[k] = normal[k];
  }
  for(k=0;k<KEY_TABLE_SIZE;k++)
  {
    shift_table[k] = shift[k];
  }
  for(k=0;k<KEY_TABLE_SIZE;k++)
  {
    ctrl_table[k] = ctrl[k];
  }
}

// Teclado PT-BR
U0 setPTBRKeyboard()
{
  U8 *normal_table = PTBR_NORMAL_KEY_SCAN_DECODE_TABLE;
  U8 *shift_table = PTBR_SHIFT_KEY_SCAN_DECODE_TABLE;
  U8 *ctrl_table = PTBR_CTRL_KEY_SCAN_DECODE_TABLE;
  setKeyboard(normal_table,shift_table,ctrl_table);
}

U0 iniciar()
{
 // " /  /  /  /  /  /  /  /  /  /  /\n";
 // "   /  /  /  /  /  /  /  /  /  /  /\n";
 // "  /  /  /  /  /  /  /  /  /  /  /\n";
 // " /  /  /  /  /  /  /  /  /  /  /\n";
 // "   /  /  /  /  /  /  /  /  /  /  /\n";
 // "  /  /  /  /  /  /  /  /  /  /  /\n";
 // " /  /  /  /  /  /  /  /  /  /  /\n";
  
  //"$$LK,\"Links Rapidos\",A=\"::/Home/bomdia.DD\"$$\n";
  // $LK,"Links Rapidos",A="::/Home/bomdia.DD"$ 
  
 // Type("::/Home/bomdia.DD");
 // "\n";
 // DocBottom;
 //Listdirs(1);
  
}

U0 Tmp()
{
  OnceExe;
  switch (sys_boot_src.u16[0]) {
    case BOOT_SRC_ROM:
      "Continue booting hard drive ";
      if (YorN) {
	DocBottom;
	ExeFile("C:/Home/Once");
      }
      break;
    case BOOT_SRC_DVD:
      "\nIf you answer 'No' you can play with\n"
	    "the live CD without installing.\n\n"
	    "Install onto hard drive ";
      if (YorN) {
	DocBottom;
	RunFile("::/Misc/OSInstall",,TRUE);
      }
      if (FileFind("::/Misc/Tour")) {
	"\nTake Tour";
	if (YorN) {
	  DocBottom;
	  Cd("::/Misc/Tour");
	  InFile("Tour");
	}
      }
      break;
    case BOOT_SRC_RAM:
    case BOOT_SRC_HARDDRV:
      "$$PURPLE$$$$TX+CX,\"Tip of the Day\"$$$$FG$$\n";
      TipOfDay;
      //Type("::/Doc/Customize.DD");
      //if (FileFind("::/Misc/Tour")) {
	//"\nTake Tour";
	//if (YorN) {
	//  DocBottom;
	//  Cd("::/Misc/Tour");
	//  InFile("Tour");
	//}
      //}
      iniciar;
      break;
  }
}

Tmp;
