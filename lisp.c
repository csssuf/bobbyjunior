#define NULL ((void*)0)

extern int getchar();

typedef void * val;

struct cons {
	val car, cdr;
};

struct cons conses[512];

panic(s)
char *s;
{
	putstr("FATAL: ");
	putstr(s);
	halt();
}

// null-terminated strings allocated end-to-end
char symbs[512];
int symbend = 0;

val symb_print;

int
strlen(c)
char *c;
{
	int len = 0;
	while(*(c++) != '\0') len++;
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

struct tblent binds[256];
int nbinds = 0;

bind(name, vl)
val name;
val vl;
{
	if (nbinds == sizeof(binds)/sizeof(binds[0])) {
		panic("Too many bindings");
	}
	binds[nbinds].key = name;
	binds[nbinds].val = vl;
	nbinds++;
}

typedef void (*builtin)(nargs, args);

builtin builtins[32];
int nbuiltins = 0;

struct cons *
ascons(v)
val v;
{
	if (v > (char*) &conses &&
	    v < (char*) &conses + sizeof(conses)) {
		return (struct cons *)v;
	}
	panic("ascons: bad cell");
}

val eval();

builtin_apply(fn, args)
builtin fn;
struct cons *args;
{
	val *bargs = calloc(8*sizeof(val));
	int nargs;

	while (args != NULL) {
		bargs[nargs++] = eval(args->car);
		args = ascons(args->cdr);
	}

	fn(bargs, nargs);
}

val
eval(term)
val term;
{
	struct cons *term1;
	// integers are all less than 512, obviously
	if (term < 512) {
		return term;
	} else if (term > (char*) symbs &&
	           term < (char*) symbs + sizeof(symbs)) {
	        int i;
	        for (i = 0; i < nbinds; ++i) {
		        if (term == binds[i].key) {
			        return binds[i].val;
		        }
	        }
	        panic("Unbound variable");
	} else if (term > (char*) conses &&
	           term < (char*) conses + sizeof(conses)) {
		val fn;

		term1 = (struct cons *) term;
		fn = eval(term1->car);

		if (fn > &builtins &&
		    fn < &builtins + sizeof(builtins)) {
			builtin_apply(fn, ascons(term1->cdr));
		}
	}
}

lisp_print(nargs, args)
val *args;
{
	if (nargs != 1) {
		panic("Bad args to print");
	}
	putstr(args[0]);
}

val
make_builtin(name, blt)
char *name;
builtin blt;
{
	if (nbuiltins == sizeof(builtins)/sizeof(builtins[0])) {
		panic("Too many builtins");
	}
	builtins[nbuiltins] = blt;

	bind(intern(name), &builtins[nbuiltins++]);
}

lisp_init()
{
	make_builtin("print", lisp_print);
}
