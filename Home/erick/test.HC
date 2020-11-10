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

U8 *address = MAlloc(10);
I64 i;
for(i=0;i<2000;i++)
{
  if(i % 80== 0)
  {
    Print("\n");
    if(!YorN) break;
  
  }
  
  Print("%s",address[i]);
}