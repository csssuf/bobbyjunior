extern int getchar();

typedef void * val;

struct cons {
	val left, right;
};

struct cons conses[512];

// null-terminated strings allocated end-to-end
char symbs[512];
int symbend = 0;

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
		while (*str != NULL
	} else {
		return &symbs[i-len];
	}
}

// Symbol mappings
struct tblent {
	val key, val;
};

struct tblent symbtbl[128];

val
eval(term)
val term;
{
	// integers are less than 512, obviously
	if (term < 512) {
		return term;
	} /* else if (term > (void *) symbs && */
	  /*          term < (void *) symbs + sizeof(symbs)) { */
	  /*       int i; */
	  /*       for (i = 0; i < sizeof(symbtbl); ++i) { */
	  /*       	if (val == symbtbl[i]) { */
				
}
