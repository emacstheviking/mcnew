%--------------------------------------------------%
%--------------------------------------------------%
%
%  mcnew - Make a new stub mercury main() program.
%
% 
%--------------------------------------------------%
%--------------------------------------------------%
:- module mcnew.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.
:- implementation.
:- import_module list, string, time.

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    (
        Args = [Cmd, Name]
    ->
        (   if Cmd = "stub" then
                create_stub(Name, !IO)
            else if Cmd = "makefile" then
                create_makefile(Name, !IO)
            else
                io.format("Don't know how to do that.\n",[],!IO)
        )
    ;
        show_usage(!IO)
    ).


:- pred create_stub(string::in, io::di, io::uo) is det.
create_stub(Name, !IO) :-
    % when did this monumental thing happen ?
    time.time(TNow, !IO),
    io.format("\
%%---------------------------------------------------------------------------%%
%%---------------------------------------------------------------------------%%
%%
%% File: %s.m
%% Main authors: sjc
%% Date: %s%%
%%
%% Start...
%%
%%---------------------------------------------------------------------------%%
%%---------------------------------------------------------------------------%%
:- module %s.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.
:- implementation.
:- import_module list, string.

main(!IO) :-
    .\n",
    [
        s(Name),
        s(time.asctime(time.gmtime(TNow))),
        s(Name)
    ], !IO).


:- pred create_makefile(string::in, io::di, io::uo) is det.

create_makefile(Name, !IO) :-
    io.format("\
BIN=%s
DEPS=%s.m
FILES=$(patsubst %%.m,%%,$(DEPS))
GENEXT=d,o,mh,err,c,c_date,mh,mih
GRADE=hlc.gc
# this one links to the extras folder in case you need it.
# FLAGS=--ml posix --mld /usr/local/mercury-rotd-2021-04-15/extras/lib/mercury -s $(GRADE) -O4
FLAGS=-s $(GRADE) -O4

all:: $(BIN)

install:: $(BIN)
	mv -f -v $(BIN) $(HOME)/bin/

%%: %%.m $(DEPS)
	mmc $(FLAGS) --make $@

$(BIN): $(DEPS)
	mmc $(FLAGS) --make $(BIN)
	mv -fv $(BIN) $(BIN)

clean::
	rm -rf Mercury
	rm -fv $$(for x in $(FILES); do echo $$x.{$(GENEXT)}; done)
	rm -fv $(BIN)\n",
    [s(Name), s(Name)],
    !IO).


:- pred show_usage(io::di, io::uo) is det.

show_usage(!IO) :-
       io.format("usage :- mcnew CMD NAME
\tCMD   one of `stub` or `makefile`
\tNAME  the module name minus the .m suffix.
",
            [], !IO).
