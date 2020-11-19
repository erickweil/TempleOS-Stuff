// Trying to understand HolyC Strings and Pointers and Memory
U0 testChars()
{
// Tem que dar Free quando usa MAlloc
U8 *chars = MAlloc(10);

chars[0] = 'a';
chars[1] = 'a';
chars[2] = 'a';
chars[3] = 'a';
chars[4] = 'a';
chars[5] = 'a';
chars[6] = 'a';
chars[7] = 'a';
chars[8] = 'a';
chars[9] = '\n';
Print(chars);

Free(chars);

// Nao pode dar Free quando usa o "" (BADFREE)
// Substitui o pointer basicamente
chars = "123456782342\n";

// Strings nao sao imutaveis!!!!
chars[0] = 'a';

Print(chars);
}


//U8 *readMemory(I64 address)
//{
//U8 *mem = *address;
//return mem;
//
//}


//Print(readMemory(0xFF)[0]); // FAULT, GENERALPROTECTION
/*
U8 *address = MAlloc(10);
I64 i;
for(i=0;i<2000;i++)
{
  if(i % 80== 0)
  {
    Print("\n");
    if(!YorN) break;
  
  }
  
  Print("%s",address[i]);
}


Normal
Caps Off: 
';' '227633266741'

Caps On:
':' '17819819315253'

Num On:
';' '35412005363765'

Num and Caps:
':' '53004191412277'


NumPad
Caps Off:
';' '777389080629'

Caps On:
':' '18369575129141'

Num On:
';' '35961761177653'

Num and Caps:
':' '53553947226165'

*/

U0 testKey()
{




Print("%c %X\n\n",';',227633266741);
Print("%c %X\n\n",';',17819819315253);
Print("%c %X\n\n",';',35412005363765);
Print("%c %X\n\n",':',53004191412277);

Print("\n\n");

Print("%c %X\n\n",';',777389080629);
Print("%c %X\n\n",';',18369575129141);
Print("%c %X\n\n",';',35961761177653);
Print("%c %X\n\n",':',53553947226165);


}


testKey;