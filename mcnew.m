%-----------------------------------------------------------------------------%
%
%  mcnew - Make a new stub mercury main() program.
%
% My first 'real' Mercury written as an apprentice piece to start getting
% some real experience cutting code and getting real flying time.
%
% Change History
% ==============
% 19 Nov 2021 -- revamped with everything I've learned in the last few months!
%                * Hopefully more idiomatic code.
%                * Use of custom command type.
%                * Improved content of main().
%                * Makefile tweaks (-E added)
%
%-----------------------------------------------------------------------------%
:- module mcnew.
:- interface.
:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module list.
:- import_module maybe.
:- import_module string.
:- import_module time.

%-----------------------------------------------------------------------------%

    % MAIN entry point.
    % This small utility is designed to help make it easier to start using
    % the Melbourne Mercury Compiler by providing a quick way to generate a
    % stub program and a Makefile if needed.
    %
main(!IO) :-
    set_options(Action, !IO),
    (
        Action = stub(Name, Author),
        create_stub(Name, Author, !IO)
    ;
        Action = makefile(Name),
        create_makefile(Name, !IO)
    ;
        Action = usage,
        show_usage(!IO)
    ).

%-----------------------------------------------------------------------------%

    % Set processing options.
    % Extract a command and a name, an an optional author name to use
    % Command will contain the appropriate command line  action and data
    % to use to complete it.
    %
:- type options
    --->    stub(string, string)    % we want to create a program stub
    ;       makefile(string)        % we want to create a Makefile
    ;       usage.                  % confused, show the usage details!

:- pred set_options(options::out, io::di, io::uo) is det.

set_options(Command, !IO) :-
    io.command_line_arguments(Args, !IO),
    ( if Args = [Cmd, Name] then
        get_environment_var("MCNEW_AUTHOR", Ares, !IO),
        (  Ares = yes(Author)
        ;  Ares = no, Author = ""
        ),
        Command = set_command(Cmd, Name, Author)
    else if Args = [Cmd, Name, Auth ] then
        Command = set_command(Cmd, Name, Auth)
    else
        Command = usage
    ).


:- func set_command(string::in, string::in, string::in)
    = (options::out) is det.

set_command(Cmd, Name, Author) = Command :-
    OpCode = string.to_lower(Cmd),
    ( if OpCode = "stub" then
        Command = stub(Name, Author)
    else if OpCode = "makefile" then
        Command = makefile(Name)
    else
        Command = usage
    ).

%---------------------------------------------------------------------------%

    % Creates a stub.
    % Name is the name of the module to create the stub for.
    % Author contains the initial author name.
    % !IO is the world state.
    %
:- pred create_stub(string::in, string::in, io::di, io::uo) is det.
create_stub(Name, Author, !IO) :-
    % when did this monumental thing happen ?
    time.time(TNow, !IO),
    io.format("\
%%-----------------------------------------------------------------------------%%
%%
%% File: %s.m
%% Main author: %s
%% Date: %s%%
%%
%% Start...
%%
%%-----------------------------------------------------------------------------%%
:- module %s.

:- interface.
:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module list.
:- import_module string.

main(!IO) :-
    %% ...your great code goes here!
    io.format(""Mercury demands focus!\n"", [], !IO).


%%----------------------------------------------------------------------------%%
:- end_module %s.
%%----------------------------------------------------------------------------%%

", [    s(Name), s(Author),
        s(time.asctime(time.gmtime(TNow))),
        s(Name), s(Name)
   ], !IO).

%---------------------------------------------------------------------------%

    % Create simple Makefile.
    % Name is the name of the module to create the stub for.
    % !IO is the world state.
    % This will write to stdout a simple makefile that enables one to create
    % the beginnings of a more complex project over time.
    %
:- pred create_makefile(string::in, io::di, io::uo) is det.

create_makefile(Name, !IO) :-
    io.format("\
BIN=%s
DEPS=%s.m
FILES=$(patsubst %%.m,%%,$(DEPS))
GENEXT=d,o,mh,err,c,c_date,mh,mih
GRADE=hlc.gc
# this one links to the extras folder in case you need it.
# but note that you may need to change the /usr/local/MERCURY-ROOT/..
# FLAGS=--ml posix --mld /usr/local/mercury-rotd-2021-04-15/extras/lib/mercury -s $(GRADE) -O4 -E
FLAGS=-s $(GRADE) -O4 -E

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
	rm -fv $(BIN)
",  [s(Name), s(Name)],
    !IO).

%----------------------------------------------------------------------------%

    % Show Usage
    % Shows the basic program usage information.
    %
:- pred show_usage(io::di, io::uo) is det.

show_usage(!IO) :-
       io.format("\
usage :- mcnew CMD NAME
\tCMD   one of `stub` or `makefile`
\tNAME  the module name minus the .m suffix.

eg. mcnew stub foo > foo.m
    mcnew stub foo author > foo.m
    mcnew makefile foo > Makefile

If you don't supply an author, the program will use the value
of the environment variable MCNEW_AUTHOR, defaulting to the
empty string if that isn't present either.

", [], !IO).
