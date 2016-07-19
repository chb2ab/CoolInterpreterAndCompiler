
/* resources used to help figure out how to handle nested comments */
/* http://dinosaur.compilertools.net/flex/flex_11.html */
/* http://stackoverflow.com/questions/12943229/removing-nested-comments-bz-lex */
%options flex /* match longest */

/* lexical grammar */
%lex
%x COMMENT
%%
/* var commentnesting = 0; */
// comments are handled by entering a comment state that increments and decrements the commentnesting variable. The state can only be exited when commentnestin == 0.

// filerighter is defined in main.js, the function is used to write the output to the -lex file

// Newlines are handled in main.js by checking each line as they are read in for a newline character.

\s+                                /* skip whitespace */
"--"[^\n]*                         /* skip comments */
"(*"                               { this.begin('COMMENT'); commentnesting += 1; }
<COMMENT>"(*"                      { commentnesting += 1; }
<COMMENT>"*)"                      { commentnesting -= 1; if (commentnesting == 0) this.popState(); }
<COMMENT><<EOF>>                   { return "EOF"; }
<COMMENT>(.|[\n\r]*)               /* skipp comments */
["]((\\\")|("\\\\")|[^"\0\n])*?["]    {
    if (yytext.length-2 > 1024)
        return "EOF";
    var offset = 0;
    while ( yytext.charAt(yytext.length-2-offset) == "\\" )
        offset += 1;
    if (offset%2 == 1)
        return "EOF";
    filerighter(line_num);
    filerighter("string");
    filerighter(yytext.substring(1, yytext.length-1)) 
} // Check that string is below the limit and that it doesn't end in a backslashed quotation mark. 
"@"                                { filerighter(line_num); filerighter("at"); }
[cC][aA][sS][eE]\b                 { filerighter(line_num); filerighter("case"); }
[cC][lL][aA][sS][sS]\b             { filerighter(line_num); filerighter("class"); }
"=>"                               { filerighter(line_num); filerighter("rarrow"); }
"<="                               { filerighter(line_num); filerighter("le"); }
":"                                { filerighter(line_num); filerighter("colon"); }
","                                { filerighter(line_num); filerighter("comma"); }
"/"                                { filerighter(line_num); filerighter("divide"); }
"."                                { filerighter(line_num); filerighter("dot"); }
[eE][lL][sS][eE]\b                 { filerighter(line_num); filerighter("else"); }
"="                                { filerighter(line_num); filerighter("equals"); }
[eE][sS][aA][cC]\b                 { filerighter(line_num); filerighter("esac"); }
[f][aA][lL][sS][eE]\b              { filerighter(line_num); filerighter("false"); }
[fF][iI]\b                         { filerighter(line_num); filerighter("fi"); }
[iI][fF]\b                         { filerighter(line_num); filerighter("if"); }
[iI][nN]\b                         { filerighter(line_num); filerighter("in"); }
[iI][nN][hH][eE][rR][iI][tT][sS]\b { filerighter(line_num); filerighter("inherits"); }
[0-9]+                             {
    var pint = parseInt(yytext);
    if ( pint > 2147483647)
        return "EOF";
    filerighter(line_num);
    filerighter("integer");
    filerighter(pint);
} // Integers need to be below the cutoff to be valid
[iI][sS][vV][oO][iI][dD]\b         { filerighter(line_num); filerighter("isvoid"); }
"<-"                               { filerighter(line_num); filerighter("larrow"); }
"{"                                { filerighter(line_num); filerighter("lbrace"); }
[lL][eE][tT]\b                     { filerighter(line_num); filerighter("let"); }
[lL][oO][oO][pP]\b                 { filerighter(line_num); filerighter("loop"); }
"("                                { filerighter(line_num); filerighter("lparen"); }
"<"                                { filerighter(line_num); filerighter("lt"); }
"-"                                { filerighter(line_num); filerighter("minus"); }
[nN][eE][wW]\b                     { filerighter(line_num); filerighter("new"); }
[nN][oO][tT]\b                     { filerighter(line_num); filerighter("not"); }
[oO][fF]\b                         { filerighter(line_num); filerighter("of"); }
"+"                                { filerighter(line_num); filerighter("plus"); }
[pP][oO][oO][lL]\b                 { filerighter(line_num); filerighter("pool"); }
"}"                                { filerighter(line_num); filerighter("rbrace"); }
")"                                { filerighter(line_num); filerighter("rparen"); }
";"                                { filerighter(line_num); filerighter("semi"); }
[tT][hH][eE][nN]\b                 { filerighter(line_num); filerighter("then"); }
"~"                                { filerighter(line_num); filerighter("tilde"); }
"*"                                { filerighter(line_num); filerighter("times"); }
[t][rR][uU][eE]\b                  { filerighter(line_num); filerighter("true"); }
[wW][hH][iI][lL][eE]\b             { filerighter(line_num); filerighter("while"); }
[A-Z][\w]*\b                       { filerighter(line_num); filerighter("type"); filerighter(yytext); }
[a-z][\w]*\b                       { filerighter(line_num); filerighter("identifier"); filerighter(yytext); }

/lex

%start expressions
%% /* language grammar */
// No grammar
expressions
    : 1 { return $1; }
    ;
