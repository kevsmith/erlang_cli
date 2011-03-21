-module(cli).

-export([main/1]).

main([]) ->
    help();

main(Args) ->
    Options = args_to_proplist(Args, []),
    start_dist_erlang(Options),
    io:format("Waiting 60 seconds before dying. Trying pinging me from another node!~n"),
    timer:sleep(60000).

%% Internal functions
help() ->
    io:format("-sname    NodeName or -name NodeName@HostOrIp~n"),
    io:format("-cookie  Cookie~n").

args_to_proplist([], Accum) ->
    Accum;
args_to_proplist([Name, Value|T], Accum) ->
    args_to_proplist(T, [{clean_option(Name), Value}|Accum]);
args_to_proplist([Name|T], Accum) ->
    args_to_proplist(T, [clean_option(Name)|Accum]).

clean_option([$-|T]) ->
    clean_option(T);
clean_option(Opt) ->
    Opt.

start_dist_erlang(Options) ->
    Cookie = proplists:get_value("cookie", Options, "cosb"),
    Name = get_nodename(Options),
    net_kernel:start(Name),
    [Node|_] = Name,
    erlang:set_cookie(Node, list_to_atom(Cookie)).

get_nodename(Options) ->
    case proplists:get_value("sname", Options) of
        undefined ->
            case proplists:get_value("name", Options) of
                undefined ->
                    throw({error, missing_nodename});
                Name ->
                    [list_to_atom(Name)]
            end;
        Name ->
            [list_to_atom(Name), shortnames]
    end.
