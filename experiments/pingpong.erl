%%% @author Pankaj More <pankajm@pankaj_y9402>
%%% @copyright (C) 2014, Pankaj More
%%% @doc
%%%
%%% @end
%%% Created :  5 Feb 2014 by Pankaj More <pankajm@pankaj_y9402>

-module('pingpong').
-compile(export_all).
-import(timer,[sleep/1]).


start(N) ->
    Server = spawn(?MODULE,server,[]),
    _ = spawn(?MODULE,client,[Server,N,0]).

server() ->
    receive
        upgrade ->
            compile:file(?MODULE),
%%            sys:suspend(?MODULE),
            code:purge(?MODULE),
            code:load_file(?MODULE),
%%            sys:resume(?MODULE),
            ?MODULE:server();
        {ping,Cid} ->
            sleep(1000),
%%            io:format("New version Running!~n"),
%%            io:format("Received a PING!~n"),
            Cid ! pong,
%%            io:format("Sent        a PONG!~n"),
            server()
    end.

client(_,0,C) ->
    io:format("DONE!~n"),
    io:format("Received ~p PONGS!~n",[C]);
client(Server,5,C) ->
    io:format("Sending an upgrade message!~n"),
    Server ! upgrade,
    From = self(),
    Server ! {ping,From},
    io:format("Sent          a PING!~n"),
    receive
        pong ->
            io:format("Received a PONG!~n"),
            client(Server,5-1,C+1)
    end;
client(Server,N,C) ->
    sleep(1000),
    From = self(),
    Server ! {ping,From},
    io:format("Sent          a PING!~n"),
    receive
        pong ->
            io:format("Received a PONG!~n"),
            client(Server,N-1,C+1)
    end.
