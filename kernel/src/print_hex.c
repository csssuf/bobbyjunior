extern void print_char(n);

void
print_hex(n)
int n;
{
    static char chars[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    int tmp;
    int i;
    for(i = 12; i >= 0; i -= 4) {
        tmp = (n >> i) & 0xF;
        print_char(chars[tmp]);
    }
}
