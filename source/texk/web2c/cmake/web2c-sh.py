#!/usr/bin/env python3
import argparse
import os.path
import re
import subprocess
import sys

option_verbose = False


def main():
    global option_verbose

    parser = argparse.ArgumentParser()
    parser.add_argument("basefile")
    parser.add_argument("--srcdir", default=".")
    parser.add_argument("--web2c", default="./web2c")
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    option_verbose = args.verbose

    if option_verbose:
        print("args: " + str(sys.argv))

    web2c = args.web2c
    srcdir = args.srcdir
    basefile = args.basefile

    pascalfile = basefile + ".p"
    cfile = basefile + ".c"
    hfile = "cpascal.h"
    more_defines = []
    web2c_options = ["-c" + basefile]
    def precmd(lines): return lines
    def midcmd(lines): return lines
    fixwrites_options = []
    splitup_options = ["-i", "-l", "65000"]
    def postcmd(lines): return lines
    output = cfile
    output_files = [cfile, basefile + ".h"]

    if basefile in ["pbibtex", "pdvitype", "ppltotf", "ptftopl"]:
        more_defines = [srcdir + "/ptexdir/ptex.defines"]
        hfile = "ptexdir/kanji.h"
    elif basefile in ["upbibtex", "updvitype", "uppltotf", "uptftopl"]:
        more_defines = [srcdir + "/uptexdir/uptex.defines"]
        hfile = "uptexdir/kanji.h"

    if basefile in ["bibtex", "pbibtex", "upbibtex"]:
        midcmd = cvtbib_sed
    elif basefile in ["mf", "mflua", "mfluajit", "tex", "aleph", "etex", "pdftex", "ptex", "eptex", "euptex", "uptex", "xetex"]:
        if basefile.startswith("mf"):
            more_defines = [srcdir + "/web2c/texmf.defines",
                            srcdir + "/web2c/mfmp.defines"]
            precmd = cvtmf1_sed
            web2c_options = ["-m", "-c" + basefile + "coerce"]
            midcmd = cvtmf2_sed
        else:
            more_defines = [srcdir + "/web2c/texmf.defines",
                            srcdir + "/synctexdir/synctex.defines"]
            web2c_options = ["-t", "-c" + basefile + "coerce"]
            fixwrites_options = ["-t"]

        prog_defines = srcdir + "/" + basefile + "dir/" + basefile + ".defines"
        if os.path.isfile(prog_defines):
            more_defines += [prog_defines]
        hfile = "texmfmp.h"
        def postcmd(lines): return run(
            [web2c + "/splitup", *splitup_options, basefile], lines)
        cfile = basefile + "0.c"
        output = ""
        output_files = [basefile + s for s in ["0.c", "1.c", "2.c", "3.c",
                                               "4.c", "5.c", "6.c", "7.c", "8.c", "9.c", "ini.c", "d.h", "coerce.h"]]

    try:
        lines = cat([srcdir + "/web2c/common.defines",
                    *more_defines, pascalfile])
        lines = precmd(lines)
        lines = run([web2c + "/web2c", "-h" + hfile, *web2c_options], lines)
        lines = midcmd(lines)
        lines = run([web2c + "/fixwrites", *
                    fixwrites_options, basefile], lines)
        lines = postcmd(lines)
        if output:
            with open(output, "w") as o:
                o.writelines(lines)

        if basefile in ["bibtex", "pbibtex", "upbibtex"]:
            pass
        elif basefile in ["mf", "mflua", "mfluajit", "tex", "aleph", "etex", "pdftex", "ptex", "eptex", "euptex", "uptex", "xetex"]:
            with open(srcdir + "/web2c/coerce.h", "r") as i:
                with open(basefile + "coerce.h", "a+") as o:
                    for line in i:
                        o.write(line)
    except Exception as e:
        print(e, file=sys.stderr)
        if output and os.path.exists(output):
            os.unlink(output)
        for o in output_files:
            if os.path.exists(o):
                os.unlink(o)
        sys.exit(1)


def cat(files):
    for file in files:
        if option_verbose:
            print("open: " + file)
        with open(file, "r") as f:
            for line in f:
                yield line


def run(args, input):
    if option_verbose:
        print("run: " + str(args))
    return subprocess.run(args, check=True, input="".join(input), encoding="utf-8", stdout=subprocess.PIPE).stdout.splitlines(True)


def cvtbib_sed(lines):
    lines = sed_match_append_line_2(lines, r'#include "cpascal\.h"',
                                    '#include <setjmp.h>\n',
                                    'jmp_buf jmp9998, jmp32; int lab31=0;\n')
    lines = sed_match_append_line_2(lines, r'#include "u*ptexdir/kanji\.h"',
                                    '#include <setjmp.h>\n',
                                    'jmp_buf jmp9998, jmp32; int lab31=0;\n')
    lines = sed_sub(lines, r'goto lab31 ; *', '{lab31=1; return;}')
    lines = sed_sub(lines, r'goto lab32', 'longjmp(jmp32,1)')
    lines = sed_sub_g(lines, r'goto lab9998', 'longjmp(jmp9998,1)')
    lines = sed_sub(lines, r'lab31:', '')
    lines = sed_sub(lines, r'lab32:', '')
    lines = sed_sub(lines, r'hack0 \(\) ;', 'if(setjmp(jmp9998)==1) goto lab9998;')
    lines = sed_sub(lines, r'hack1 \(\) ;', 'if(setjmp(jmp32)==0)for(;;)')
    lines = sed_sub(lines, r'hack2 \(\)', 'break')
    lines = sed_sub_after(lines, r'^void mainbody', r'while \( true', 'while (lab31==0')
    return lines


def cvtmf1_sed(lines):
    # TODO: cvtmf1.sed
    for line in lines:
        yield line


def cvtmf2_sed(lines):
    # TODO: cvtmf2.sed
    for line in lines:
        yield line


def sed_sub(lines, pattern, replace):
    re_pattern = re.compile(pattern, re.ASCII)
    for line in lines:
        line = re_pattern.sub(replace, line, 1)
        yield line


def sed_sub_g(lines, pattern, replace):
    re_pattern = re.compile(pattern, re.ASCII)
    for line in lines:
        line = re_pattern.sub(replace, line)
        yield line


def sed_sub_after(lines, pattern_1, pattern_2, replace):
    re_pattern_1 = re.compile(pattern_1, re.ASCII)
    re_pattern_2 = re.compile(pattern_2, re.ASCII)
    found = False
    for line in lines:
        if re_pattern_1.match(line):
            found = True
        if found:
            line = re_pattern_2.sub(replace, line)
        yield line


def sed_match_append_line_2(lines, pattern, append_1, append_2):
    re_pattern = re.compile(pattern, re.ASCII)
    for line in lines:
        if re_pattern.match(line):
            yield line
            yield append_1
            yield append_2
            continue
        yield line


if __name__ == "__main__":
    main()
