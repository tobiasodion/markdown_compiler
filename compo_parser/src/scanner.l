%{
/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"
#include "y.tab.h"

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

//void print_token(char *token);
//void print_token_with_str(char *token, char *str);
//void print_token_with_number(char *token, int number);

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
    return NEWLINE; // It will print the token NEWLINE
};

([[:blank:]]*{newline}){2} {
    return BLANK_LINE;
};

<INITIAL>{bold}	{
    BEGIN_MODE(BOLD_MODE); // You can switch to another mode

    return BOLD;
};

<BOLD_MODE>{bold} {
    END_MODE; // It will go back to the previous mode

    return BOLD;
};

<INITIAL>{italic} {
    BEGIN_MODE(ITALIC_MODE); // You can switch to another mode

    return ITALIC;
};

<ITALIC_MODE>{italic} {
    END_MODE; // It will go back to the previous mode

    return ITALIC;
};

<INITIAL>{underline} {
    BEGIN_MODE(UNDERLINE_MODE); // You can switch to another mode

    return UNDERLINE;
};

<UNDERLINE_MODE>{underline} {
    END_MODE; // It will go back to the previous mode

    return UNDERLINE;
};

<INITIAL>{strikethrough} {
    BEGIN_MODE(STRIKETHROUGH_MODE); // You can switch to another mode

    return STRIKETHROUGH;
};

<STRIKETHROUGH_MODE>{strikethrough} {
    END_MODE; // It will go back to the previous mode

    return STRIKETHROUGH;
};

^{h1} {
    return H1;
}

^{h2} {
    return H2;
}

^{h3} {
    return H3;
}

^{h4} {
    return H4;
}

^{h5} {
    return H5;
}

^{h6} {
    return H6;
}

^{quote} {
    return QUOTE;
}

^{hr} {
    return HR;
}

<INITIAL>{inline-code} {
    BEGIN_MODE(INLINE_CODE_MODE); // You can switch to another mode

    return INLINE_CODE;
};

<INLINE_CODE_MODE>{inline-code} {
    END_MODE; // It will go back to the previous mode

    return INLINE_CODE;
};

^{block-code} {
    return BLOCK_CODE;
}

^{exclam} {
    return EXCLAM;
}

<INITIAL>{lparen} {
    BEGIN_MODE(PAREN_MODE); // You can switch to another mode

    return LPAREN;
};

<PAREN_MODE>{rparen} {
    END_MODE; // It will go back to the previous mode

    return RPAREN;
};

<INITIAL>{lbracket} {
    BEGIN_MODE(BRACKET_MODE); // You can switch to another mode

    return LBRACKET;
};

<BRACKET_MODE>{rbracket} {
    END_MODE; // It will go back to the previous mode

    return RBRACKET;
};

^{xsvg-begin} {
    BEGIN_MODE(XSVG_MODE); // You can switch to another mode

    return XSVG_BEGIN;
};

<XSVG_MODE>{xsvg-end} {
    END_MODE; 
    return XSVG_END;
};

<XSVG_MODE>{comma} {
    return COMMA;
};

<XSVG_MODE>{line} {
    return LINE;
};

<XSVG_MODE>{polyline} {
    return POLYLINE;
};

<XSVG_MODE>{polygon} {
    return POLYGON;
};

<XSVG_MODE>{circle} {
    return CIRCLE;
};

<XSVG_MODE>{ellipse} {
    return ELLIPSE;
};

<XSVG_MODE>{rect} {
    return RECT;
};

<XSVG_MODE>{xsvg-text} {
    return XSVG_TEXT;
};

<XSVG_MODE>{number} {
    return NUMBER;
};

<XSVG_MODE>\n {
    return NEWLINE;
};

<XSVG_MODE>"\"".+"\"" {
    return STR;
};

<XSVG_MODE>[a-zA-Z\s]+ {
    return STR;
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
    return TEXT; // Will print the token TEXT along with the string
};

<TEXT_MODE><<EOF>> {
    // <<EOF>> means the end of the markdown file.
    END_MODE;

    char* txt = strbufclr();
    char *copy = str_copy(txt);
    return TEXT;
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

/*void print_token(char *token) {
    printf("TOKEN: %s\n", token);
}

void print_token_with_str(char *token, char *str) {
    printf("TOKEN: %s | String: \"%s\"\n", token, str);
}

void print_token_with_number(char *token, int number) {
    printf("TOKEN: %s | Number: \"%d\"\n", token, number);
}*/
/*********** END OF C CODE ******************/
