#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable

-mode(compile).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Macros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(PREFIX, $1,$2,$3,$4).
-define(PREFIX_LEN, 4).

-define(KEY_SCHEME, "X").

-define(KEY_MODULE, "ovn_profile_keys").

% DCCX_PATTERN Decoded
% Layout of Re-translated CORE key file: GBCRX.TXT

% BIN (6)
-define(BIN, "^(\\d{6}|_     )").
% PVS-METHOD (8) & FLG1 (10)
-define(PVS_FLG, ".{18}").
% AWK*-IND *2 (2), IWK*-IND *2 (2), AKEK-IND (1), IKEK-IND (1), DUMMY (2), FILLER (8)
-define(AWK_IWK_AKEK_IKEK_IND, "(.)(.)(.)(.).{12}").
% IWK-1 (16), IWK-1B (16), IWK-2 (16), IWK-2B (16)
-define(IWK, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% AWK-1 (16), AWK-1B (16), AWK-2 (16), AWK-2B (16)
-define(AWK, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% PVS *6*2 (16 each * 12), ATALIA *14 (varied, total 61), FL1 (8), FL2 (16), OLKE *9 (varied, total 84), IVAL *7 (varied, total 12), IBM *2 (16 *2)
-define(PVS_ATALIA_FL_OLKE_IVAL_IBM, ".{405}").
% CVV (CVK): CVV-KEY-A-1 (16), CVV-KEY-A-2 (16), CVV-KEY-B-1 (16), CVV-KEY-B-2 (16)
-define(CVV_KEY, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% FILLER (96), PVKI-OFFSET-TRK1 (2), PVV-OFFSET-TRK1 (2), PVKI-OFFSET-TRK2 (2), PVV-OFFSET-TRK2 (2)
-define(PVKI_PVV, ".{104}").
% CVV2 (C2K): C2K-KEY-A-1 (16), C2K-KEY-B-1 (16), C2K-KEY-A-2 (16), C2K-KEY-B-2 (16)
-define(C2K_KEY, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% FILLER (92)
-define(FILLER, ".{92}").
% CAV1A (16), CAV1B (16), CAV2A (16), CAV2B (16)
-define(CAV, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% CAA1A (16), CAA1B (16), CAA2A (16), CAA2B (16)
-define(CAA, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% SREC *5 *4 times (varied, total 47*4)
-define(SREC, ".{188}").
% CVV (CVK) Key Expansion: CVVA & CVVB *5 (16 each *2*5)
-define(CVV, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% CVV2 (C2K) Key expansion: CVV2A & CVV2B *5 (16 each *2*5)
-define(CVV2, "([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})([0-9A-F]{16})").
% Visa Mobile Remote Auth Keys (16 *4), GCAS Chip Capable Card Embossing Global Key (16 *10 + 8 *2 + 127)
-define(VMRAK_GCAS, ".*$").

% Putting together DCCX_PATTERN...
-define(DCCX_PATTERN, ?BIN++?PVS_FLG++?AWK_IWK_AKEK_IKEK_IND++?IWK++?AWK++?PVS_ATALIA_FL_OLKE_IVAL_IBM
        ++?CVV_KEY++?PVKI_PVV++?C2K_KEY++?FILLER++?CAV++?CAA++?SREC++?CVV++?CVV2++?VMRAK_GCAS).

-define(DCCY_PATTERN, "^(\\d{6}|_     )([0-9]{2}).*$").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main(["-config", Config, "-test"]) -> test(Config);
main(["-config", Config, "-cache", Cache, "-DCCX", DCCX, "-DCCY", DCCY, "-dir", Dir, "-time", Time, "-err", Log]) -> do(Config, Cache, DCCX, DCCY, Dir, Time, Log);
main(_) -> log("Usage:
  hsm_key_import.erl -config <hsm.config> -test
  hsm_key_import.erl -config <hsm.config> -cache <cache_file> -DCCX <input_keys> -dir <profile_dir> -time <profile_timestamp> -err <error_log>

Example:
  ./hsm_key_import.erl -config dev.hsm.config -cache hsm.key.cache -DCCX DCCX.txt -DCCY DCCY.txt -dir . -time 1123456780 -err err.log
").

do(Config, CacheFile, DCCX, DCCY, Dir, Time, ErrorLog) ->
  {ok, Cfg} = file:consult(Config),
  load_config(Cfg),

  Cache = load_cache(CacheFile),

  DCCXkeys = load_keys(DCCX, ?DCCX_PATTERN, fun match_DCCX/6),
  DCCYkeys = load_keys(DCCY, ?DCCY_PATTERN, fun match_DCCY/6),
  CoreKeys = DCCXkeys ++ DCCYkeys,

  CachedKeys = maps:with(CoreKeys, Cache),
  MissingKeys = missing_keys(Cache, CoreKeys),

  log("Found ~p tanslated keys in cache...~n", maps:size(CachedKeys) ),
  log("Keys to be tanslated: ~p...~n", length(MissingKeys) ),

  TranslatedKeys =
    case MissingKeys of
      [] -> [];
      _ ->
        setup_tunnel(),
        ping_hsm(),
        {OutKeys, BadKeys} = translate_keys(MissingKeys, [], []),
        log_errors(BadKeys, ErrorLog),
        BadKeys = [],
        OutKeys
    end,

  AllKeys = TranslatedKeys ++ maps:to_list(CachedKeys),

  SortedKeys = lists:sort(AllKeys),

  write_erl(SortedKeys, Dir, Time),
  compile_beam(Dir, Time),

  write_cache(CacheFile, SortedKeys).

test(Config) ->
  {ok, Cfg} = file:consult(Config),
  load_config(Cfg),
  setup_tunnel(),
  ping_hsm(),
  Command = "A6402" ++ get(zcmk) ++ "X90AD6DF1840305FDF77EA9255E6494AFX",
  Result = send_command(Command),
  "A700X3C24052AA72BDD4E4A51A35A849D36D2EB0466" = binary_to_list(Result),
  log("Success~n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setup_tunnel() ->
  case get(tunnel) of
    undefined -> ok;
    Cmd ->
      log("Opening SSH tunnel...~n" ),
      os:cmd(Cmd),
      timer:sleep(get(tunnel_delay))
  end.

ping_hsm() ->
  application:ensure_all_started(ssl),

  SSL_options = get(ssl_options),
  HSM_HOST = get(host),
  HSM_PORT = get(port),
  Transport = get(transport),
  Options = [binary, {packet, 0}, {active, false}, {nodelay, true} | SSL_options],
  log("Connecting to HSM...~n"),
  {ok, Socket} = Transport:connect(HSM_HOST, HSM_PORT, Options, 2000),
  put(socket, Socket),
  log("...connected to HSM~n"),
  log("Pinging HSM~n"),
  "B300" = binary_to_list(send_command("B20000")),
  log("...HSM responded to ping~n").

load_keys(DCC_file, Pattern, Matcher) ->
  {ok, Regexp} = re:compile(Pattern),
  {ok, Device} = file:open(DCC_file, read),
  log("Parsing file: ~p ...~n", DCC_file),
  {GoodKeys, []} = parse_line(Device, Regexp, Matcher, [], []),
  log("...file parsed, extracted ~p keys~n", length(GoodKeys) ),
  file:close(Device),
  GoodKeys.

% Build list of good keys
% Format: {[ {BIN,iwk/awk,SubIndex,Key}...], bad_keys()}
parse_line(Device, Regexp, Matcher, GoodKeys, BadKeys) ->
  case io:get_line(Device, "") of
    eof ->
      {GoodKeys,BadKeys};
    {error, Err} ->
      log("Error: unable to read file: ~p~n", Err),
      exit(1);
    Line->
      case re:run(Line, Regexp) of
        nomatch -> parse_line(Device, Regexp, Matcher, GoodKeys, [Line | BadKeys]);
        {match, Captured} -> Matcher(Device, Regexp, Line, Captured, GoodKeys, BadKeys)
      end
  end.

match_DCCX(Device, Regexp, Line, [_All, BIN,
    AWK1_IND, AWK2_IND, IWK1_IND, IWK2_IND,
    IWK1A, IWK1B, IWK2A, IWK2B, AWK1A, AWK1B, AWK2A, AWK2B,
    CVK1A, CVK1B, CVK2A, CVK2B, C2K1A, C2K1B, C2K2A, C2K2B,
    CAV1A, CAV1B, CAV2A, CAV2B, CAA1A, CAA1B, CAA2A, CAA2B,
    CVK3A, CVK3B, CVK4A, CVK4B, CVK5A, CVK5B, CVK6A, CVK6B, CVK7A, CVK7B,
    C2K3A, C2K3B, C2K4A, C2K4B, C2K5A, C2K5B, C2K6A, C2K6B, C2K7A, C2K7B],
     GoodKeys, BadKeys) ->
  GoodKeys2  = append_key(GoodKeys,   Line, BIN, IWK1_IND, IWK1A, IWK1B, iwk, "1" ),
  GoodKeys3  = append_key(GoodKeys2,  Line, BIN, IWK2_IND, IWK2A, IWK2B, iwk, "2" ),
  GoodKeys4  = append_key(GoodKeys3,  Line, BIN, AWK1_IND, AWK1A, AWK1B, awk, "1" ),
  GoodKeys5  = append_key(GoodKeys4,  Line, BIN, AWK2_IND, AWK2A, AWK2B, awk, "2" ),
  GoodKeys6  = append_key(GoodKeys5,  Line, BIN, "D",      CVK1A, CVK2A, cvk, "1" ), %%%%%%%% shuffled entries
  GoodKeys7  = append_key(GoodKeys6,  Line, BIN, "D",      CVK1B, CVK2B, cvk, "2" ), %%%%%%%% shuffled entries
  GoodKeys8  = append_key(GoodKeys7,  Line, BIN, "D",      C2K1A, C2K1B, c2k, "1" ),
  GoodKeys9  = append_key(GoodKeys8,  Line, BIN, "D",      C2K2A, C2K2B, c2k, "2" ),
  GoodKeys10 = append_key(GoodKeys9,  Line, BIN, "D",      CAV1A, CAV1B, cav, "1" ),
  GoodKeys11 = append_key(GoodKeys10, Line, BIN, "D",      CAV2A, CAV2B, cav, "2" ),
  GoodKeys12 = append_key(GoodKeys11, Line, BIN, "D",      CAA1A, CAA1B, caa, "1" ),
  GoodKeys13 = append_key(GoodKeys12, Line, BIN, "D",      CAA2A, CAA2B, caa, "2" ),
  GoodKeys14 = append_key(GoodKeys13, Line, BIN, "D",      CVK3A, CVK3B, cvk, "3" ),
  GoodKeys15 = append_key(GoodKeys14, Line, BIN, "D",      CVK4A, CVK4B, cvk, "4" ),
  GoodKeys16 = append_key(GoodKeys15, Line, BIN, "D",      CVK5A, CVK5B, cvk, "5" ),
  GoodKeys17 = append_key(GoodKeys16, Line, BIN, "D",      CVK6A, CVK6B, cvk, "6" ),
  GoodKeys18 = append_key(GoodKeys17, Line, BIN, "D",      CVK7A, CVK7B, cvk, "7" ),
  GoodKeys19 = append_key(GoodKeys18, Line, BIN, "D",      C2K3A, C2K3B, c2k, "3" ),
  GoodKeys20 = append_key(GoodKeys19, Line, BIN, "D",      C2K4A, C2K4B, c2k, "4" ),
  GoodKeys21 = append_key(GoodKeys20, Line, BIN, "D",      C2K5A, C2K5B, c2k, "5" ),
  GoodKeys22 = append_key(GoodKeys21, Line, BIN, "D",      C2K6A, C2K6B, c2k, "6" ),
  GoodKeys23 = append_key(GoodKeys22, Line, BIN, "D",      C2K7A, C2K7B, c2k, "7" ),
  parse_line(Device, Regexp, fun match_DCCX/6, GoodKeys23, BadKeys).

match_DCCY(Device, Regexp, Line, [_All, {BIN_start, BIN_len}, {Count_start, Count_len}], GoodKeys, BadKeys) ->
  Count = list_to_integer(string:substr(Line, Count_start+1, Count_len)),
  BIN = string:substr(Line, BIN_start+1, BIN_len),
  LineTail = string:substr(Line, 9),
  loop_MDK(Device, Regexp, LineTail, Count, BIN, GoodKeys, BadKeys).

loop_MDK(Device, Regexp, _, 0, _, GoodKeys, BadKeys) ->
  parse_line(Device, Regexp, fun match_DCCY/6, GoodKeys, BadKeys);
loop_MDK(Device, Regexp, Line, N, BIN, GoodKeys, BadKeys) ->
  SubIndex = string:substr(Line, 9, 3),
  KeyLengthIndication = string:substr(Line, 1, 2),
  GoodKeys2 = append_key(GoodKeys, Line, BIN, KeyLengthIndication, {11, 16}, {27, 16}, mdk, SubIndex ),
  LineTail = string:substr(Line, 51),
  loop_MDK(Device, Regexp, LineTail, N-1, BIN, GoodKeys2, BadKeys).

% Discriminate between single and double-length keys, also normalize BIN
append_key(List, Line, {BIN_start, BIN_len}, IND, KEYA, KEYB, KeyType, SubIndex) ->
  BIN = string:substr(Line, BIN_start+1, BIN_len),
  append_key(List, Line, BIN, IND, KEYA, KEYB, KeyType, SubIndex);

append_key(List, Line, BIN, {IND_start, IND_len}, KEYA, KEYB, KeyType, SubIndex) ->
  KeyLengthIndication = string:substr(Line, IND_start+1, IND_len),
  append_key(List, Line, BIN, KeyLengthIndication, KEYA, KEYB, KeyType, SubIndex);

append_key(List, Line, BIN, KeyLengthIndication, KEYA, KEYB, KeyType, SubIndex) ->
  case KeyLengthIndication of
    "D"  -> append_key(List, Line, BIN, KEYA, KEYB, KeyType, SubIndex); % double-length key
    "NY" -> append_key(List, Line, BIN, KEYA, KEYB, KeyType, SubIndex); % double-length key
    "S"  -> append_key(List, Line, BIN, KEYA, KEYA, KeyType, SubIndex); % single-length key
    "YN" -> append_key(List, Line, BIN, KEYA, KEYA, KeyType, SubIndex); % single-length key
    _ -> List
  end.

% Extract Key, append to list of good keys
append_key(List, Line, BIN, {KEYA_start, KEYA_len}, {KEYB_start, KEYB_len}, KeyType, SubIndex) ->
  Key = string:substr(Line, KEYA_start+1, KEYA_len) ++ string:substr(Line, KEYB_start+1, KEYB_len),
  case Key of
    "00000000000000000000000000000000" -> List;
    _ -> [{BIN, KeyType, SubIndex, Key} | List]
  end.

translate_keys( [], GoodKeys, BadKeys ) -> {GoodKeys, BadKeys};
translate_keys([{BIN, KeyType, SubIndex, Key} | Tail], GoodKeys, BadKeys) ->

  log("Importing ~s.~p[~s] key: ~p~n", BIN, KeyType, SubIndex, Key ),

  Translated = import_key(Key, KeyType),
  case Translated of
    {WrappedKey, KeyCheckValue} ->
      log("...key imported: ~p, check: ~p~n", WrappedKey, KeyCheckValue ),
      translate_keys(Tail, [{{BIN, KeyType, SubIndex, Key}, WrappedKey} | GoodKeys], BadKeys);
    BadResponse -> translate_keys(Tail, GoodKeys, [{BIN, KeyType, SubIndex, Key, BadResponse}|BadKeys])
  end.

import_key(Key, KeyType) ->
  ZCMK = get(zcmk),
  Command = lists:flatten([
    "A6",
    key_atom_to_type(KeyType),
    ZCMK,
    ?KEY_SCHEME,
    Key,
    ?KEY_SCHEME
  ]),

  Response = send_command(Command),
  case Response of
    <<"A700", ?KEY_SCHEME, WrappedKey:32/binary, KeyCheckValue:6/binary>> ->
      {binary_to_list(WrappedKey), binary_to_list(KeyCheckValue)};
    _ -> Response
  end.

write_erl(Keys, Dir, Version) ->

  log("Writing key profile module...~n" ),

  {ok, Device} = file:open(Dir++"/"++?KEY_MODULE ++ ".erl", write),
  io:format(Device, "-module(~s).

-export([get_key/4]).

-spec get_key(any(), atom(), integer(), integer()) -> string() | error.

get_key(Context, KeyType, Index, SubIndex) ->
  Module = get__module_(Context),
  Module:get_key(KeyType, Index, SubIndex).

get__module_(Context) when is_tuple(Context) ->
  case ovn_context:get_profile_version(Context) of
    Version when is_list(Version) -> get__module_(Version)
  end;

get__module_(Version) when is_list(Version) ->
  list_to_atom(\"~s_\" ++ Version).
", [?KEY_MODULE, ?KEY_MODULE]),
  file:close(Device),

  Module = ?KEY_MODULE ++ "_" ++ Version,
  {ok, Device2} = file:open( Dir++"/"++Module ++".erl", write),
  io:format(Device2, "-module(~s).

-export([get_key/3]).

-spec get_key(atom(), integer(), integer()) -> string() | undefined.

", [Module]),

  lists:foreach(
    fun({{"403314", KeyType, "1", _Key}, Key}) ->
         io:format(Device2,"get_key(~p, ~s, ~s) -> ~p;~n",[KeyType, "403314", "10" ,Key]);
       ({{"403314", KeyType, "2", _Key}, Key}) ->
         io:format(Device2,"get_key(~p, ~s, ~s) -> ~p;~n",[KeyType, "403314", "11" ,Key]);
      ({{BIN, KeyType, SubIndex, _Key}, Key}) ->
      io:format(Device2,"get_key(~p, ~s, ~s) -> ~p;~n",[KeyType, BIN, SubIndex ,Key])
    end, Keys),

  io:format(Device2,"get_key(_, _, _) -> undefined.~n",[]),
  file:close(Device2).

compile_beam(Dir, Version) ->
  log("Compiling key profile module...~n" ),
  Opts = [return_errors, warnings_as_errors],
  {ok, _1} = compile:noenv_file(Dir++"/"++?KEY_MODULE++".erl", Opts),
  {ok, _2} = compile:noenv_file(Dir++"/"++?KEY_MODULE ++ "_" ++ Version++".erl", Opts).

log_errors([], _) -> ok;
log_errors(BadKeys, Log) ->
  {ok, Device} = file:open( Log, [write,append]),
  lists:foreach(
    fun({BIN, KeyType, SubIndex, Key, Response}) ->
      {{Y, M, D}, {H, Mi, S}} = calendar:now_to_local_time(os:timestamp()),
      io:format(Device,
        "~b-~2..0b-~2..0b ~2..0b:~2..0b:~2..0b Unable to import ~s.~p[~s] key ~p, HSM response: ~p ~n",
        [Y, M, D, H, Mi, S, BIN, KeyType, SubIndex, Key, Response])
    end,
    BadKeys),
  file:close(Device).

% constants from HSM documentation
key_atom_to_type(iwk) -> "001";
key_atom_to_type(awk) -> "001";
key_atom_to_type(cvk) -> "402";
key_atom_to_type(c2k) -> "402";
key_atom_to_type(mdk) -> "109";
key_atom_to_type(cav) -> "402";
key_atom_to_type(caa) -> "402".

send_command(Command) ->
  Transport = get(transport),
  Socket = get(socket),

  Length = length(Command) + ?PREFIX_LEN,
  Output = list_to_binary([0, Length, ?PREFIX | Command]),

  ok = Transport:send(Socket, Output),

  io:format("HSM command: ~p~n",[Command]),

  {ok, Binary} = Transport:recv(Socket, 0, 2000),
  <<Header:6/binary, Response/binary>> = Binary,
  <<0, _, ?PREFIX>> = Header,

  log("...HSM response: ~p~n", binary_to_list(Response)),

  Response.

log(Msg) ->
  io:format(Msg, []).
log(Format, Arg1) ->
  io:format(Format, [Arg1]).
log(Format, Arg1, Arg2) ->
  io:format(Format, [Arg1, Arg2]).
log(Format, Arg1, Arg2, Arg3) ->
  io:format(Format, [Arg1, Arg2, Arg3]).
log(Format, Arg1, Arg2, Arg3, Arg4) ->
  io:format(Format, [Arg1, Arg2, Arg3, Arg4]).

load_config(Cfg) ->
  lists:foreach(fun({Key, Value }) -> put(Key, Value) end, Cfg).

load_cache(CacheFile) ->
  log("Loading key translation cache...~n" ),
  case file:consult(CacheFile) of
    {ok, Cache} -> maps:from_list(Cache);
    _ -> #{}
  end.

missing_keys(Cache, TheirKeys) ->
  CachedKeys = sets:from_list(maps:keys(Cache)),
  AllKeys = sets:from_list(TheirKeys),
  MissingKeys = sets:subtract(AllKeys, CachedKeys),
  sets:to_list(MissingKeys).

write_cache(CacheFile, Cache) ->
  log("Writing key translation cache...~n" ),
  {ok, Device} = file:open(CacheFile, write),
  lists:foreach( fun(X) -> io:format(Device, "~p.~n", [X]) end, Cache),
  file:close(Device).
