%{
/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/
#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "ast.h"

#define CHECK_YYNOMEM(ptr) if ((ptr) == NULL) YYNOMEM;
#define CHECK_LENGTH(var, num) if ((num) >= 0) var = num; else { yyerror("negative length"); YYERROR; }

int yylex(void);
void yy_scan_string(char* s);
int yylex_destroy(void);
void yyerror(const char*);

extern char* strbuf;

const char *tokens[] = {
    "Document",
    "TextElement",
    "Paragraph",
    "Bold",
    "Italic",
    "Underline",
    "Strikethrough",
    "Header1",
    "Header2",
    "Header3",
    "Header4",
    "Header5",
    "Header6",
    "Quote",
    "Link",
    "Image",
    "InlineCode",
    "BlockCode",
    "HRule",
    "SVG"
};

const char* svg_tokens[] = {
    "Line",
    "Polyline",
    "Polygon",
    "Circle",
    "Ellipse",
    "Rect",
    "Text"
};

DOM* dom_root = NULL;

/*********** END OF C CODE ******************/
/** YOU WILL HAVE TO COMPLETE THE DOCUMENT BELOW **/
%}

%define parse.lac full
%define parse.error detailed

%union {
    char* text;
    int number;
    DOM* dom;
    DomList* dom_list;
    SvgCoord* svg_coord;
    SvgCoordList* svg_coord_list;
    SvgInst* svg;
    SvgList* svg_list;
}

%destructor { free($$); } <text>
%destructor { free_dom($$); } <dom>
%destructor { free_dom_list($$); } <dom_list>
%destructor { free($$); } <svg_coord>
%destructor { free_svg_coord_list($$); } <svg_coord_list>
%destructor { free_svg_inst($$); } <svg>
%destructor { free_svg_list($$); } <svg_list>

%token NEWLINE BLANK_LINE
%token BOLD ITALIC
%token UNDERLINE STRIKETHROUGH
%token H1 H2 H3 H4 H5 H6
%token QUOTE
%token EXCLAM
%token LPAREN RPAREN
%token LBRACKET RBRACKET
%token HR
%token INLINE_CODE BLOCK_CODE
%token XSVG_BEGIN XSVG_END
%token COMMA
%token LINE POLYLINE POLYGON CIRCLE ELLIPSE RECT
%token XSVG_TEXT
%token <text> TEXT
%token STR
%token <number> NUMBER

%type <dom> document block
%type <dom_list> block_list paragraph line text
%type <svg_coord_list> coord_list
%type <svg_coord> coord
%type <svg_list> svg_block_list
%type <svg> svg_block
%start document

%%

text:
    TEXT {
        DOM* dom = new_dom(TextElement, NULL);
        dom->text = $1;
        $$ = new_dom_list(dom);
    }
    | BOLD text BOLD {
        DOM* dom = new_dom(Bold, $2);
        $$ = new_dom_list(dom);
    }
    | ITALIC text ITALIC {
        DOM* dom = new_dom(Italic, $2);
        $$ = new_dom_list(dom);
    }
    | UNDERLINE text UNDERLINE {
        DOM* dom = new_dom(Underline, $2);
        $$ = new_dom_list(dom);
    }
    | STRIKETHROUGH text STRIKETHROUGH {
        DOM* dom = new_dom(Strikethrough, $2);
        $$ = new_dom_list(dom);
    }
    | INLINE_CODE text INLINE_CODE {
        DOM* dom = new_dom(InlineCode, $2);
        $$ = new_dom_list(dom);
    };
line:
    text line {
        $$ = $1;
        $$->next = $2;
    }
    | text { $$ = $1; };
paragraph:
    line NEWLINE paragraph {
        $$ = $1;
        DomList* curr = $$;
        while (curr->next != NULL) curr = curr->next;
        curr->next = $3;
    }
    | line { $$ = $1; };
block:
    H1 TEXT {
        $$ = new_dom(Header1, NULL);
        $$->text = $2;
    }
    | H2 TEXT {
        $$ = new_dom(Header2, NULL);
        $$->text = $2;
    }
    | H3 TEXT {
        $$ = new_dom(Header3, NULL);
        $$->text = $2;
    }
    | H4 TEXT {
        $$ = new_dom(Header4, NULL);
        $$->text = $2;
    }
    | H5 TEXT {
        $$ = new_dom(Header5, NULL);
        $$->text = $2;
    }
    | H6 TEXT {
        $$ = new_dom(Header6, NULL);
        $$->text = $2;
    }
    | paragraph {
        $$ = new_dom(Paragraph, $1);
    }
    | BLOCK_CODE BLANK_LINE paragraph BLANK_LINE BLOCK_CODE {
        $$ = new_dom(BlockCode, $3);
    }
    | XSVG_BEGIN coord COMMA coord svg_block_list XSVG_END {
        $$ = new_dom(SVG, NULL);
        $$->svg_children = $5;
    }
    | EXCLAM LBRACKET TEXT RBRACKET LPAREN TEXT RPAREN{
        $$ = new_dom(Image, NULL);
        $$->text = $3;
        $$->url = $6;
    };

svg_block:
    POLYLINE coord_list STR {
        $$ = new_svg_inst(Polyline,$2);
    }
    |
    POLYGON coord_list STR STR {
        $$ = new_svg_inst(Polygon,$2);
    }
    |
    CIRCLE coord NUMBER STR STR {
        $$ = new_svg_inst(Circle,new_svg_coord_list($2));
    }
    |
    ELLIPSE coord NUMBER NUMBER STR STR {
         $$ = new_svg_inst(Ellipse,new_svg_coord_list($2));
    }
    |
    RECT coord NUMBER NUMBER STR STR {
         $$ = new_svg_inst(Rect,new_svg_coord_list($2));
    }
    |
    XSVG_TEXT coord STR STR STR {
         $$ = new_svg_inst(Text,new_svg_coord_list($2));
    }
    ;

svg_block_list:
    svg_block svg_block_list {
        if ($1 == NULL) {
            $$ = $2;
        } else {
            $$ = new_svg_list($1);
            $$->next = $2;
        }
    }
    |
    svg_block {
        $$ = new_svg_list($1);
    };

coord: 
    NUMBER COMMA NUMBER {
        $$ = new_svg_coord($1,$3);
    };

coord_list:
    coord coord_list {
        $$ = new_svg_coord_list($1);
        $$->next = $2;
    }
    |
    coord {
        $$ = new_svg_coord_list($1);
    };

block_list:
    block BLANK_LINE block_list {
        if ($1 == NULL) {
            $$ = $3;
        } else {
            $$ = new_dom_list($1);

            $$->next = $3;
        }
    }
    | block NEWLINE block_list {
        if ($1 == NULL) {
            $$ = $3;
        } else {
            $$ = new_dom_list($1);

            $$->next = $3;
        }
    }
    | block {
        $$ = new_dom_list($1);
    };

document: block_list {
    dom_root = $$ = new_dom(Document, $1);
    YYACCEPT;
};

%%

/*********** C CODE (YOU DO NOT HAVE TO MODIFY IT) ******************/

void svg_display(SvgInst* svg, int depth) {
    if (svg == NULL) return;
    for (int i = 0; i < depth - 2; i++) {
        printf("│   ");
    }
    printf("├─── %s", svg_tokens[svg->kind]);
    SvgCoordList* curr_coord = svg->coords;
    printf(" [");
    while (curr_coord != NULL) {
        printf(" (%d, %d)", curr_coord->coord->x, curr_coord->coord->y);
        curr_coord = curr_coord->next;
    }
    printf("]");
    printf(" w=%d", svg->width);
    printf(" h=%d", svg->height);
    if (svg->text != NULL) printf(" \"%s\"", svg->text);
    if (svg->anchor != NULL) printf(" anchor=%s", svg->anchor);
    if (svg->color_stroke != NULL) printf(" cs=%s", svg->color_stroke);
    if (svg->color_fill != NULL) printf(" cf=%s", svg->color_fill);
    printf("\n");
}

void dom_display(DOM* dom, int depth) {
    if (dom == NULL) return;
    int i = 0;

    if (depth == 1) {
        printf("%s", tokens[dom->dom_el]);
    } else {
        for (i = 0; i < depth - 2; i++) {
            printf("│   ");
        }
        printf("├─── %s", tokens[dom->dom_el]);
    }
    if (dom->text != NULL) {
        printf(" (%s)", dom->text);
    }
    if (dom->url != NULL) {
        printf(" (%s)", dom->url);
    }
    printf("\n");

    SvgList* svg_child = dom->svg_children;

    while (svg_child != NULL) {
        svg_display(svg_child->svg, depth + 1);

        svg_child = svg_child->next;
    }

    DomList* current_child = dom->children;

    while (current_child != NULL) {
        dom_display(current_child->dom, depth + 1);

        current_child = current_child->next;
    }
}

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
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
    if (argc == 2) {
        FILE* f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Cannot open file");
            return -1;
        }
        fseek(f, 0, SEEK_END);
        int length = ftell(f);
        rewind(f);
        input = malloc(sizeof(char) * (length + 1));
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
    }
    int ret = yyparse();

    if (input != NULL) {
        free(input);
    }
    if (argc == 2) {
        yylex_destroy();
    }
    if (strbuf != NULL) {
        free(strbuf);
    }

    if (ret > 0) return ret;
    else {
        dom_display(dom_root, 1);

        free_dom(dom_root);
    }
}

/*********** END OF C CODE ******************/
