extern int getchar();

typedef void * val;

struct cons {
	val car, cdr;
};

struct cons conses[512];

panic(s)
char *s;
{
	putstr(s);
	halt();
}

// null-terminated strings allocated end-to-end
char symbs[512];
int symbend = 0;

val symb_print;

int
strlen(c)
char c;
{
	int len = 0;
	while(*c++ != '\0') len++;
	return len;
}

val
intern(str)
char * str;
{
	int i = 0;
	int len = 0;
	char *str1 = str;
	while (i < symbend) {
		if (*str1 == symbs[i]) {
			if (symbs[i] == '\0') break;
			str1++;
			i++;
			len++;
		} else {
			str1 = str;
			len = 0;
			while (str[i] != NULL) {
				i++;
			}
		}
	}

	if (i == symbend) {
		while (*str != '\0') {
			if (symbend == sizeof(symbs))
				panic("Ran out of symbol space");
			symbs[symbend++] = *(str++);
		}
	} else {
		return &symbs[i-len];
	}
}

// Symbol mappings
struct tblent {
	val key, val;
};

struct tblent binds[128];
int nbinds = 0;

struct cons *
ascons(v)
val v;
{
	if (term > (void*) conses &&
	    term < (void*) conses + sizeof(conses)) {
		return (struct cons *)v;
	}
	panic("ascons: bad cell");
}

val
eval(term)
val term;
{
	struct cons *term1;
	// integers are all less than 512, obviously
	if (term < 512) {
		return term;
	} else if (term > (void*) symbs &&
	           term < (void*) symbs + sizeof(symbs)) {
	        int i;
	        for (i = 0; i < nbinds; ++i) {
		        if (val == binds[i].key) {
			        return binds[i].val;
		        }
	        }
	        panic("Unbound variable");
	} else if (term > (void*) conses &&
	           term < (void*) conses + sizeof(conses)) {
		term1 = (struct cons *) term;

		if (term1.car == symb_print) {
			
	}
}

lisp_init()
{
	symb_print = intern("print");
}
