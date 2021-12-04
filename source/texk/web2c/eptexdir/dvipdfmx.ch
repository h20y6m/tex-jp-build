%% Support for dvipdfmx

@x l.10123
@d random_seed_code=elapsed_time_code+1 {code for \.{\\pdfrandomseed}}
@y
@d random_seed_code=elapsed_time_code+1 {code for \.{\\pdfrandomseed}}
@d dvipdfmx_code=random_seed_code+1 {code for \.{\\dvipdfmx}}
@z

@x l.10125
@d eTeX_int=random_seed_code+1 {first of \eTeX\ codes for integers}
@y
@d eTeX_int=dvipdfmx_code+1 {first of \eTeX\ codes for integers}
@z

@x l.15777
  b_close(dvi_file);
@y
  b_close(dvi_file);
  @<Run dvipdfmx@>;
@z

@x l.29040
procedure close_files_and_terminate;
var k:integer; {all-purpose index}
@y
procedure close_files_and_terminate;
var k:integer; {all-purpose index}
@!rundvipdfmx_ret:integer; {return value from |rundvipdfmx|}
@z

@x l.30028
primitive("Ucharcat",convert,Ucharcat_convert_code);@/
@!@:Ucharcat_}{\.{\\Ucharcat} primitive@>
@y
primitive("Ucharcat",convert,Ucharcat_convert_code);@/
@!@:Ucharcat_}{\.{\\Ucharcat} primitive@>
primitive("dvipdfmx",last_item,dvipdfmx_code);@/
@!@:dvipdfmx_}{\.{\\dvipdfmx} primitive@>
@z

@x l.30040
random_seed_code:     print_esc("pdfrandomseed");
@y
random_seed_code:     print_esc("pdfrandomseed");
dvipdfmx_code:        print_esc("dvipdfmx");
@z

@x l.30055
random_seed_code:  cur_val := random_seed;
@y
random_seed_code:  cur_val := random_seed;
dvipdfmx_code:
  begin
  if dvipdfmx <> 0 then begin
    cur_val := 1;
  end
  else cur_val := 0;
  end;
@z

@x l.53201
@* \[54] System-dependent changes.
@y
@ @<Glob...@>=
@!dvipdfmx:cinttype;

@ @<Run dvipdfmx@>=
begin
  if dvipdfmx <> 0 then begin
    print_nl("run dvipdfmx... ");
    rundvipdfmx_ret := rundvipdfmx(output_file_name);
    if rundvipdfmx_ret = 0 then print("success")
    else begin
      history := fatal_error_stop;
      print("failure "); print_int(rundvipdfmx_ret);
    end;
    print_char(".");
  end;
end

@* \[54] System-dependent changes.
@z
