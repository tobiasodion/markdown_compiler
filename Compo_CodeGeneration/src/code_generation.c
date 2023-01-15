#include "ast.h"

#define SIMPLE_STRINGS_IMPL
#include "simple_strings.h"
#include <string.h>
#include <stdio.h>

const char HTML_HEADER[] = 	"<!DOCTYPE html>\n"
                            "<html>\n"
                            "  <head>\n"
                            "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
                            "    <meta charset=\"utf-8\">\n"
                            "    <title>Markdown to HTML</title>\n"
                            "    <link rel=\"stylesheet\" href=\"github-markdown.css\">\n"
                            "  </head>\n"
                            "  <body>\n"
                            "  <article class=\"markdown-body\">\n";

const char HTML_FOOTER[] = 	"  </article>\n"
                            "  </body>\n"
                            "</html>";

void add_indentation(string str, unsigned int indent_lvl) {
    for (int t = 0; t < indent_lvl; t++) {
        APPEND_ARR(str, "  ");
    }
}

string code_generation_from_svg(SvgInst *svg, unsigned int indent)
{
    if (svg == NULL){
        return STR("");
    }
        
    switch (svg->kind)
    {
        case Line:
        {
            SvgCoordList *svg_coords = svg->coords;
            string html = STR("");
            
            add_indentation(html, indent);

            char str[10];

            APPEND_ARR(html, "<line ");

            APPEND_ARR(html, "x1=\"");

            sprintf(str, "%d", svg_coords->coord->x);
            APPEND_ARR(html, str);

            APPEND_ARR(html, "\" y1=\"");
            char str2[10];
            sprintf(str2, "%d", svg_coords->coord->y);
            APPEND_ARR(html, str2);

            svg_coords = svg_coords->next;
            APPEND_ARR(html, "\" x2=\" ");

            char str3[10];
            sprintf(str3, "%d", svg_coords->coord->x);
            APPEND_ARR(html, str3);

            char str4[10];
            sprintf(str4, "%d", svg_coords->coord->y);
            APPEND_ARR(html, "\" y2=\" ");
            APPEND_ARR(html, str4);

            APPEND_ARR(html, "\" stroke=\"");
            APPEND_ARR(html, svg->color_stroke);
            APPEND_ARR(html, "\" />");

            return html;
        }
        case Polyline:
        {

        SvgCoordList *svg_coords = svg->coords;
        string html = STR("");
        add_indentation(html, indent);

        APPEND_ARR(html, "<polyline fill=\"none\" points=\"");
        
        while (svg_coords != NULL)
        {
            char res[25];
            sprintf(res, "%d,%d ", svg_coords->coord->x, svg_coords->coord->y);
            APPEND_ARR(html, res);
            svg_coords = svg_coords->next;
        }

        APPEND_ARR(html, "\" stroke=\"");
        APPEND_ARR(html, svg->color_stroke);

        
        APPEND_ARR(html, "\" />");

        return html;
        }
        case Polygon:
        {

            SvgCoordList *svg_coords = svg->coords;
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<polyline fill=\"");
            APPEND_ARR(html, svg->color_fill);
            APPEND_ARR(html, "\" stroke=\"");
            APPEND_ARR(html, svg->color_stroke);
            APPEND_ARR(html, "\" points=\"");

            while (svg_coords != NULL)
            {
                char res[25];
                sprintf(res, "%d,%d ", svg_coords->coord->x, svg_coords->coord->y);
                APPEND_ARR(html, res);
                svg_coords = svg_coords->next;
            }
            APPEND_ARR(html, "\" />");

            return html;
        }
        case Circle:
        {
            SvgCoordList *svg_coords = svg->coords;
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<circle ");

            char coords[25];
            sprintf(coords, "cx=\"%d\" cy=\"%d\" ", svg_coords->coord->x, svg_coords->coord->y);
            APPEND_ARR(html, coords);

            char r[25];
            sprintf(r, "r=\"%d\" ", svg->width);
            APPEND_ARR(html, r);

            APPEND_ARR(html, "fill=\"");
            APPEND_ARR(html, svg->color_fill);
            APPEND_ARR(html, "\" stroke=\"");
            APPEND_ARR(html, svg->color_stroke);
            APPEND_ARR(html, "\" />");

            return html;
        }
        case Ellipse:
        {
            SvgCoordList *svg_coords = svg->coords;
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<ellipse ");

            char coords[25];
            sprintf(coords, "cx=\"%d\" cy=\"%d\" ", svg_coords->coord->x, svg_coords->coord->y);
            APPEND_ARR(html, coords);

            char r[25];
            sprintf(r, "rx=\"%d\" ry=\"%d\" ", svg->width, svg->height);
            APPEND_ARR(html, r);

            APPEND_ARR(html, "fill=\"");
            APPEND_ARR(html, svg->color_fill);
            APPEND_ARR(html, "\" stroke=\"");
            APPEND_ARR(html, svg->color_stroke);
            APPEND_ARR(html, "\" />");

            return html;
        }
        case Rect:
        {
            SvgCoordList *svg_coords = svg->coords;
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<rect ");

            char coords[25];
            sprintf(coords, "x=\"%d\" y=\"%d\" ", svg_coords->coord->x, svg_coords->coord->y);
            APPEND_ARR(html, coords);

            char size[25];
            sprintf(size, "width=\"%d\" height=\"%d\" ", svg->width, svg->height);
            APPEND_ARR(html, size);

            APPEND_ARR(html, "fill=\"");
            APPEND_ARR(html, svg->color_fill);
            APPEND_ARR(html, "\" stroke=\"");
            APPEND_ARR(html, svg->color_stroke);
            APPEND_ARR(html, "\" />");

            return html;
        }
        case Text:
        {
            SvgCoordList *svg_coords = svg->coords;
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<text ");

            char coords[25];
            sprintf(coords, "x=\"%d\" y=\"%d\" ", svg_coords->coord->x, svg_coords->coord->y);
            APPEND_ARR(html, coords);

            APPEND_ARR(html, "anchor=\"");
            APPEND_ARR(html, svg->anchor);
            APPEND_ARR(html, "\" fill=\"");
            APPEND_ARR(html, svg->color_fill);
            APPEND_ARR(html, "\" stroke=\"");
            APPEND_ARR(html, svg->color_stroke);
            APPEND_ARR(html, "\" >");
            APPEND_ARR(html, svg->text);

            APPEND_ARR(html, "</text>");

            return html;
        }
    }
}


string code_generation_from_dom(DOM* dom, unsigned int indent) {
    /*
    YOU HAVE TO COMPLETE THIS FUNCTION TO PRODUCE THE HTML EQUIVALENT FOR EACH DOM ELEMENT
    */
    if (dom == NULL) return STR("");

    switch (dom->dom_el) {
        case Document: {
            string html = STR("");
            add_indentation(html, indent);

            DomList *child = dom->children;
            while (child != NULL) {
                string child_html = code_generation_from_dom(child->dom, indent + 1);

                APPEND_STR(html, child_html);

                child = child->next;
            }

            return html;
        }
        case SVG:
        {
            string html = STR("");

            SvgList *child = dom->svg_children;
            APPEND_ARR(html, "<svg  viewBox=\"0 0 200 100\">\n");
            while (child != NULL)
            {
                string child_svg = code_generation_from_svg(child->svg, indent + 1);

                APPEND_STR(html, child_svg);
                APPEND_ARR(html, "\n");

                child = child->next;
            }

            add_indentation(html, indent);
            APPEND_ARR(html, "</svg>\n");

            return html;
        }
        case Header1: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h1>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h1>\n");

            return html;
        }
        case Header2: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h2>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h2>\n");

            return html;
        }
        case Header3: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h3>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h3>\n");

            return html;
        }
        case Header4: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h4>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h4>\n");

            return html;
        }
        case Header5: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h5>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h5>\n");

            return html;
        }
        case Header6: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<h6>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</h6>\n");

            return html;
        }
        case Paragraph: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<p>\n");

            DomList *child = dom->children;
            DOM *previous_child = NULL;

            while (child != NULL) {
                // We check here if we have two TextElement besides, it should have a space between.
                if (previous_child != NULL) {
                    if (previous_child->dom_el == TextElement) {
                        APPEND_ARR(html, " ");
                    }
                } else {
                    add_indentation(html, indent + 1);
                }

                string content = code_generation_from_dom(child->dom, indent + 1); // Indentation not relevant here

                APPEND_STR(html, content);

                previous_child = child->dom;
                child = child->next;
            }

            APPEND_ARR(html, "\n");
            add_indentation(html, indent);
            APPEND_ARR(html, "</p>\n");

            return html;
        }
        case TextElement: {
            string html = STR(dom->text);

            return html;
        }
        case Bold: {
            string html = STR("<b>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</b>");

            return html;
        }
        case Italic: {
            string html = STR("<i>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</i>");

            return html;
        }
        case Strikethrough: {
            string html = STR("<s>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</s>");

            return html;
        }
        case Underline: {
            string html = STR("<u>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</u>");

            return html;
        }
        case Quote: {
            string html = STR("");
            add_indentation(html, indent);

            APPEND_ARR(html, "<blockquote>");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "</blockquote>\n");

            return html;
        }
        case InlineCode: {
            string html = STR("<code>");

            if (dom->children != NULL) {
                string content = code_generation_from_dom(dom->children->dom, indent + 1); // Identation not relevant here

                APPEND_STR(html, content);
            }

            APPEND_ARR(html, "</code>");

            return html;
        }
        case BlockCode: {
            string html = STR("");
            add_indentation(html, indent);
    
            APPEND_ARR(html, "<pre><code>\n");

            DomList *child = dom->children;
            DOM *previous_child = NULL;

            while (child != NULL) {
                // We check here if we have two TextElement besides, it should have a space between.
                if (previous_child != NULL) {
                    if (previous_child->dom_el == TextElement) {
                        APPEND_ARR(html, "\n");
                    }
                } else {
                    //add_indentation(html, indent + 1);
                }

                string content = code_generation_from_dom(child->dom, indent + 1); // Indentation not relevant here

                APPEND_STR(html, content);

                previous_child = child->dom;
                child = child->next;
            }

            APPEND_ARR(html, "\n");
            //add_indentation(html, indent);
            APPEND_ARR(html, "</code></pre>\n");
            
            return html;
        }
        case HRule: {
            string html = STR(" ");
            add_indentation(html, indent);

            APPEND_ARR(html, "<hr/>\n");
            return html;
        }
        case Link:
        {
            string html = STR(" ");

            add_indentation(html, indent);
            html = STR("<a href=\"");
            APPEND_ARR(html, dom->url);
            APPEND_ARR(html, "\" >");

            APPEND_ARR(html, dom->text);

            APPEND_ARR(html, "</a>\n");
           
            return html;
        }
        case Image:
        {
            string html = STR(" ");
            add_indentation(html, indent);

            html = STR("<img src=\"");
            APPEND_ARR(html, dom->url);
            APPEND_ARR(html, "\" alt=\"");
            APPEND_ARR(html, dom->text);
            APPEND_ARR(html, "\" />");
            APPEND_ARR(html, "\n");
            return html;
        }
        default: {
            return STR("");
        }
    }
}

string code_generation(DOM* dom) {
    string final_code = STR(HTML_HEADER);
    string dom_code = code_generation_from_dom(dom, 2);

    APPEND_STR(final_code, dom_code);
    APPEND_ARR(final_code, HTML_FOOTER);

    spls_free_string(dom_code);

    return final_code;
}
