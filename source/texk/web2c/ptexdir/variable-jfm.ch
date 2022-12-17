
@x [l.12189]
@p @t\4@>@<Declare additional functions for ML\TeX@>@/
@y
@p @t\4@>@<Declare additional functions for ML\TeX@>@/
@<Declare additional functions called in |read_font_info|@>@/
@z

@x [l.12189]
begin g:=null_font;@/
@y
@!nom_base:str_number; {|nom_base|}
begin g:=null_font;@/
@z

@x [l.12245]
pack_file_name(nom,aire,"");
@y
nom_base:=make_nom_base(nom);
pack_file_name(nom_base,aire,"");
@z

@x [l.29467]
@* \[56] System-dependent changes.
@y
@ @<Declare additional functions called in |read_font_info|@>=
function make_nom_base(@!nom:str_number):str_number;
label found;
var i, p: integer;
begin p:=0;
  for i:=str_start[nom] to str_start[nom+1]-1 do
    if str_pool[i]=':' then begin
      p:=i;
      goto found;
    end;
  make_nom_base:=nom;
found:
  if p<>0 then begin
    for i:=str_start[nom] to p-1 do
      append_char(str_pool[i]);
    make_nom_base:=slow_make_string;
  end;
end;

@* \[56] System-dependent changes.
@z
