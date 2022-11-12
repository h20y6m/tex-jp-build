% pdfoutput.ch for \npTeX\ PDF output.

@x nptex-base.ch(3715)
@d random_seed_code=elapsed_time_code+1 {code for \.{\\pdfrandomseed}}
@y
@d random_seed_code=elapsed_time_code+1 {code for \.{\\pdfrandomseed}}
@d nptex_pdfoutput_code=random_seed_code+1 {code for \.{\\npTeXpdfoutput}}
@z

@x nptex-base.ch(3721)
@d eTeX_int=random_seed_code+1 {first of \eTeX\ codes for integers}
@y
@d eTeX_int=nptex_pdfoutput_code+1 {first of \eTeX\ codes for integers}
@z

@x tex.web(10296)
  pack_job_name(".dvi");
  while not b_open_out(dvi_file) do
    prompt_file_name("file name for output",".dvi");
@y
  if pdfoutput then begin
    pack_job_name(".pdf");
    ret_err:=pdf_open_out(dvi_file);
    if ret_err<>0 then begin
      print_nl("Error "); print_int(ret_err);
      print(" open PDF output.");
      history:=fatal_error_stop; jump_out;
    end;
  end else begin
    pack_job_name(".dvi");
    while not b_open_out(dvi_file) do
      prompt_file_name("file name for output",".dvi");
  end;
@z

@x nptex-base.ch(5856)
@!del_node:pointer; {used when delete the |dir_node| continued box}
@y
@!del_node:pointer; {used when delete the |dir_node| continued box}
@!ret_err:integer; {returned error number}
@z

@x tex.web(12802)
  print(", "); print_int(dvi_offset+dvi_ptr); print(" bytes).");
  b_close(dvi_file);
@y
  if pdfoutput then begin
    print(").");
    ret_err:=pdf_close(dvi_file);
    if ret_err<>0 then begin
      print_nl("Error "); print_int(ret_err);
      print(" generating PDF output.");
      history:=fatal_error_stop;
    end;
  end else begin
    print(", "); print_int(dvi_offset+dvi_ptr); print(" bytes).");
    b_close(dvi_file);
  end;
@z

@x tex.web(24324)
procedure close_files_and_terminate;
var k:integer; {all-purpose index}
@y
procedure close_files_and_terminate;
var k:integer; {all-purpose index}
@!ret_err:integer; {returned error number}
@z

@x nptex-base.ch(10440)
primitive("Ucharcat",convert,Ucharcat_convert_code);@/
@!@:Ucharcat_}{\.{\\Ucharcat} primitive@>
@y
primitive("Ucharcat",convert,Ucharcat_convert_code);@/
@!@:Ucharcat_}{\.{\\Ucharcat} primitive@>
primitive("npTeXpdfoutput",last_item,nptex_pdfoutput_code);
@!@:npTeX_pdfoutput_}{\.{\\npTeXpdfoutput} primitive@>
@z

@x nptex-base.ch(10461)
random_seed_code:     print_esc("pdfrandomseed");
@y
random_seed_code:     print_esc("pdfrandomseed");
nptex_pdfoutput_code: print_esc("npTeXpdfoutput");
@z

@x nptex-base.ch(10479)
random_seed_code:  cur_val := random_seed;
@y
random_seed_code:  cur_val := random_seed;
nptex_pdfoutput_code: cur_val := pdfoutput;
@z

@x nptex-base.ch(12498)
@* \[54] System-dependent changes.
@y
@* \[54/\npTeX\ PDF output] System-dependent changes for \npTeX\ PDF output.

@<Global...@> =
@!pdfoutput: cinttype;

@* \[54] System-dependent changes.
@z
