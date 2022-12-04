%{
/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* BEGIN MODE SYSTEM DECLARATION */
int mode_caller[8];
int mode_caller_len = 0;

void mode_caller_push(int mode);
int mode_caller_peek(void);
int mode_caller_pop(void);

#define BEGIN_MODE(mode) mode_caller_push(YY_START); BEGIN((mode));
#define END_MODE BEGIN(mode_caller_pop());
/* END MODE SYSTEM DECLARATION */

/* BEGIN STRING MANIPULATION DECLARATION */
#define STRBUFCAP 1024

char* strbuf = NULL;
size_t strbuflen = 0;

void strbufapp(char c);
char* strbufclr(void);
char* str_copy(char *str);
/* END STRING MANIPULATION DECLARATION */

void print_token(char *token);
void print_token_with_str(char *token, char *str);
void print_token_with_number(char *token, int number);

/*********** END OF C CODE ******************/

/*
Here is my personal list of tokens for my grammar.
You are welcome to use it if your grammar does not match what was expected:

NEWLINE
BLANK_LINE
BOLD
ITALIC
UNDERLINE
STRIKETHROUGH
H1
H2
H3
H4
H5
H6
QUOTE
EXCLAM
LPAREN
RPAREN
LBRACKET
RBRACKET
HR
INLINE_CODE
BLOCK_CODE
XSVG_BEGIN
XSVG_END
COMMA
LINE
POLYLINE
POLYGON
CIRCLE
ELLIPSE
RECT
XSVG_TEXT
TEXT
STR
NUMBER
*/

/** YOU WILL HAVE TO COMPLETE THE DOCUMENT BELOW **/
%}

newline "\n"
bold "**"
italic "*"
underline "__"
strikethrough "~~"
h1 "#"[[:blank:]]*
h2 "##"[[:blank:]]*
h3 "###"[[:blank:]]*
h4 "####"[[:blank:]]*
h5 "#####"[[:blank:]]*
h6 "######"[[:blank:]]*
quote ">"[[:blank:]]*
exclam "!"
lparen "("
rparen ")"
lbracket "["
rbracket "]"
hr "---"[[:blank:]]*
inline-code "`"
block-code "```"[[:blank:]]*
xsvg-begin "```xsvg:"
xsvg-end "```"
comma ","
line "line"
polyline "polyline"
polygon "polygon"
circle "circle"
ellipse "ellipse"
rect "rect"
xsvg-text "text"
str [[:blank:]]*[a-zA-Z]+[[:blank:]]*
text [[:blank:]]*"\""[a-zA-Z\s]+"\""[[:blank:]]*
number -?[0-9]+

%x BOLD_MODE TEXT_MODE ITALIC_MODE UNDERLINE_MODE STRIKETHROUGH_MODE INLINE_CODE_MODE BRACKET_MODE PAREN_MODE XSVG_MODE

%%

<INITIAL>[[:blank:]]*{newline} {
    print_token("NEWLINE"); // It will print the token NEWLINE
};

([[:blank:]]*{newline}){2} {
    print_token("BLANK_LINE");
};

<INITIAL>{bold}	{
    BEGIN_MODE(BOLD_MODE); // You can switch to another mode

    print_token("BOLD");
};

<BOLD_MODE>{bold} {
    END_MODE; // It will go back to the previous mode

    print_token("BOLD");
};

<INITIAL>{italic} {
    BEGIN_MODE(ITALIC_MODE); // You can switch to another mode

    print_token("ITALIC");
};

<ITALIC_MODE>{italic} {
    END_MODE; // It will go back to the previous mode

    print_token("ITALIC");
};

<INITIAL>{underline} {
    BEGIN_MODE(UNDERLINE_MODE); // You can switch to another mode

    print_token("UNDERLINE");
};

<UNDERLINE_MODE>{underline} {
    END_MODE; // It will go back to the previous mode

    print_token("UNDERLINE");
};

<INITIAL>{strikethrough} {
    BEGIN_MODE(STRIKETHROUGH_MODE); // You can switch to another mode

    print_token("STRIKETHROUGH");
};

<STRIKETHROUGH_MODE>{strikethrough} {
    END_MODE; // It will go back to the previous mode

    print_token("STRIKETHROUGH");
};

^{h1} {
    print_token("H1");
}

^{h2} {
    print_token("H2");
}

^{h3} {
    print_token("H3");
}

^{h4} {
    print_token("H4");
}

^{h5} {
    print_token("H5");
}

^{h6} {
    print_token("H6");
}

^{quote} {
    print_token("QUOTE");
}

^{hr} {
    print_token("HR");
}

<INITIAL>{inline-code} {
    BEGIN_MODE(INLINE_CODE_MODE); // You can switch to another mode

    print_token("INLINE_CODE");
};

<INLINE_CODE_MODE>{inline-code} {
    END_MODE; // It will go back to the previous mode

    print_token("INLINE_CODE");
};

^{block-code} {
    print_token("BLOCK-CODE");
}

{exclam} {
    print_token("EXCLAM");
}

<INITIAL>{lparen} {
    BEGIN_MODE(PAREN_MODE); // You can switch to another mode

    print_token("LPAREN");
};

<PAREN_MODE>{rparen} {
    END_MODE; // It will go back to the previous mode

    print_token("RPAREN");
};

<INITIAL>{lbracket} {
    BEGIN_MODE(BRACKET_MODE); // You can switch to another mode

    print_token("LBRACKET");
};

<BRACKET_MODE>{rbracket} {
    END_MODE; // It will go back to the previous mode

    print_token("RBRACKET");
};

^{xsvg-begin} {
    BEGIN_MODE(XSVG_MODE); // You can switch to another mode

    print_token("XSVG_BEGIN");
};

<XSVG_MODE>{xsvg-end} {
    END_MODE; 
    print_token("XSVG_END");
};

<XSVG_MODE>{comma} {
    print_token("COMMA");
};

<XSVG_MODE>{line} {
    print_token("LINE");
};

<XSVG_MODE>{polyline} {
    print_token("POLYLINE");
};

<XSVG_MODE>{polygon} {
    print_token("POLYGON");
};

<XSVG_MODE>{circle} {
    print_token("CIRCLE");
};

<XSVG_MODE>{ellipse} {
    print_token("ELLIPSE");
};

<XSVG_MODE>{rect} {
    print_token("RECT");
};

<XSVG_MODE>{xsvg-text} {
    print_token("XSVG_TEXT");
};

<XSVG_MODE>{number} {
    print_token_with_str("NUMBER", yytext);
};

<XSVG_MODE>\n {
    print_token("NEWLINE");
};

<XSVG_MODE>"\"".+"\"" {
    print_token_with_str("STR", yytext);
};

<XSVG_MODE>[a-zA-Z\s]+ {
    print_token_with_str("STR", yytext);
};

<INITIAL,BOLD_MODE,ITALIC_MODE,UNDERLINE_MODE,STRIKETHROUGH_MODE,INLINE_CODE_MODE,BRACKET_MODE,PAREN_MODE>. {
    BEGIN_MODE(TEXT_MODE);

    // yytext is containing the text captured by the regular
    // expression.
    // The expression "*yytext" is to catch only one character (the first one).
    // We will append our character in a global string
    strbufapp(*yytext);
};

<TEXT_MODE>({newline}|{bold}|{italic}|{underline}|{strikethrough}|^{h1}|^{h2}|^{h3}|^{h4}|^{h5}|^{h6}|^{quote}|{inline-code}|^{block-code}|{lbracket}|{rbracket}|{lparen}|{rparen})(.|\n)* {
    END_MODE;

    // We give the full capture to Flex to be analyzed again
    // otherwise the content will be lost
    yy_scan_string(yytext);

    char* txt = strbufclr(); // We retrieve the global string made with strbufapp()
    char *copy = str_copy(txt); // We have to make a copy of the global string or the yytext when needed
    print_token_with_str("TEXT", copy); // Will print the token TEXT along with the string
};

<TEXT_MODE><<EOF>> {
    // <<EOF>> means the end of the markdown file.
    END_MODE;

    char* txt = strbufclr();
    char *copy = str_copy(txt);
    print_token_with_str("TEXT", copy);
};

<TEXT_MODE>. {
    strbufapp(*yytext);
};

<XSVG_MODE>. {}

%%

/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/

//Implementaion of stack methods to manage the states 
//In declaration sections, the stack is defined as an string(char*) array of size 9 to store the states 
//The mode_caller_length serves at the top of stack pointer. It is initialized to 0 in the declarations section
//Hence this scanner can operate in a maximum of 9 states

void mode_caller_push(int mode) {
    mode_caller[mode_caller_len++] = mode;
}

int mode_caller_peek(void) {
    return mode_caller_len == 0 ? INITIAL : mode_caller[mode_caller_len - 1];
}

int mode_caller_pop(void) {
    int caller = mode_caller_peek();
    if (mode_caller_len > 0) {
        mode_caller_len--;
    }
    return caller;
}
/**********************************************************************/

void strbufapp(char c) {
    if (strbuf == NULL) {
        strbuf = malloc(sizeof(char) * STRBUFCAP);
    }
    if (strbuflen >= STRBUFCAP - 2) {
        char* new_strbuf = malloc(sizeof(char) * 2 * STRBUFCAP);
        strncpy(new_strbuf, strbuf, strbuflen);
        free(strbuf);
        strbuf = new_strbuf;
    }
    strbuf[strbuflen++] = c;
}

char* strbufclr(void) {
    strbuf[strbuflen] = '\0';
    strbuflen = 0;
    return strbuf;
}

char* str_copy(char *str) {
    char* copy = malloc(strlen(str) + 1);

    strcpy(copy, str);

    return copy;
}

void print_token(char *token) {
    printf("TOKEN: %s\n", token);
}

void print_token_with_str(char *token, char *str) {
    printf("TOKEN: %s | String: \"%s\"\n", token, str);
}

void print_token_with_number(char *token, int number) {
    printf("TOKEN: %s | Number: \"%d\"\n", token, number);
}

int yywrap(void) {
    return 1;
}

int main(int argc, char* argv[]) {
#if YYDEBUG
    extern int yydebug;
    yydebug = 1;
#endif
    char* input = NULL;
    char *original_input = NULL;
    if (argc != 2) {
        fprintf(stderr, "Please use program as: ./compo FILE.md");
        return -1;
    }

    strbuf = malloc(sizeof(char) * STRBUFCAP);
    FILE* f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Cannot open file");
        return -1;
    }
    fseek(f, 0, SEEK_END);
    int length = ftell(f);
    rewind(f);
    input = malloc(sizeof(char) * (length + 1));
    original_input = input;
    if (input == NULL) {
        fprintf(stderr, "Cannot allocate enough memory for file");
        return -2;
    }
    fread(input, sizeof(char), length, f);
    fclose(f);
    *(input + length) = 0;
    unsigned int i = 0;
    while (i < length && isspace(*input)) {
        input++;
        i++;
    }
    unsigned int j = length - i - 1;
    while (j > i && isspace(*(input + j))) *(input + j--) = 0;
    yy_scan_string(input);

    int ret = yylex();

    if (original_input != NULL) {
        free(original_input);
    }
    yylex_destroy();
    if (strbuf != NULL) {
        free(strbuf);
    }

    return ret;
}
/*********** END OF C CODE ******************/
