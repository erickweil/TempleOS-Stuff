// Trying to understand HolyC Strings and Pointers and Memory

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
