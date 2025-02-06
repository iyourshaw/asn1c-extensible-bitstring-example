%% Generated by the Erlang ASN.1 PER (unaligned) compiler. Version: 5.3.1
%% Purpose: Encoding and decoding of the types in FruitModuleV1.

-module('FruitModuleV1').
-moduledoc false.
-compile(nowarn_unused_vars).
-dialyzer(no_improper_lists).
-dialyzer(no_match).
-include("FruitModuleV1.hrl").
-asn1_info([{vsn,'5.3.1'},
            {module,'FruitModuleV1'},
            {options,[{i,"./src"},uper,verbose,{i,"./asn"},{outdir,"./src"},{i,"."}]}]).

-export([encoding_rule/0,maps/0,bit_string_format/0,
         legacy_erlang_types/0]).
-export(['dialyzer-suppressions'/1]).
-export([
enc_FruitSalad/1,
enc_Fruits/1
]).

-export([
dec_FruitSalad/1,
dec_Fruits/1
]).

-export([info/0]).

-export([encode/2,decode/2]).

encoding_rule() -> uper.

maps() -> false.

bit_string_format() -> bitstring.

legacy_erlang_types() -> false.

encode(Type, Data) ->
try complete(encode_disp(Type, Data)) of
  Bytes ->
    {ok,Bytes}
  catch
    Class:Exception:Stk when Class =:= error; Class =:= exit ->
      case Exception of
        {error,{asn1,Reason}} ->
          {error,{asn1,{Reason,Stk}}};
        Reason ->
         {error,{asn1,{Reason,Stk}}}
      end
end.


decode(Type, Data) ->
try
   {Result,_Rest} = decode_disp(Type, Data),
   {ok,Result}
  catch
    Class:Exception:Stk when Class =:= error; Class =:= exit ->
      case Exception of
        {error,{asn1,Reason}} ->
          {error,{asn1,{Reason,Stk}}};
        Reason ->
         {error,{asn1,{Reason,Stk}}}
      end
end.

encode_disp('FruitSalad', Data) -> enc_FruitSalad(Data);
encode_disp('Fruits', Data) -> enc_Fruits(Data);
encode_disp(Type, _Data) -> exit({error,{asn1,{undefined_type,Type}}}).

decode_disp('FruitSalad', Data) -> dec_FruitSalad(Data);
decode_disp('Fruits', Data) -> dec_Fruits(Data);
decode_disp(Type, _Data) -> exit({error,{asn1,{undefined_type,Type}}}).

info() ->
   case ?MODULE:module_info(attributes) of
     Attributes when is_list(Attributes) ->
       case lists:keyfind(asn1_info, 1, Attributes) of
         {_,Info} when is_list(Info) ->
           Info;
         _ ->
           []
       end;
     _ ->
       []
   end.
enc_FruitSalad(Val) ->
[begin
%% attribute fruits(1) with type BIT STRING
Enc1@element = element(2, Val),
Enc2@bs = try bit_string_name2pos_1(Enc1@element) of
Enc2@positions ->
bitstring_from_positions(Enc2@positions, 4)
catch throw:invalid ->
adjust_trailing_zeroes(Enc1@element, 4)
end,
Enc2@bits = bit_size(Enc2@bs),
if Enc2@bits =:= 4 ->
[<<0:1>>|Enc2@bs];
Enc2@bits < 128 ->
[<<1:1,Enc2@bits:8>>|Enc2@bs];
Enc2@bits < 16384 ->
[<<1:1,2:2,Enc2@bits:14>>|Enc2@bs];
true ->
[<<1:1>>|encode_fragmented(Enc2@bs, 1)]
end
end|begin
%% attribute servingSize(2) with type INTEGER
Enc3@element = element(3, Val),
if Enc3@element bsr 8 =:= 0 ->
[Enc3@element];
true ->
exit({error,{asn1,{illegal_integer,Enc3@element}}})
end
end].


dec_FruitSalad(Bytes) ->

%% attribute fruits(1) with type BIT STRING
{Term1,Bytes1} = begin
{V1@V0,V1@Buf1} = case Bytes of
<<0:1,V1@V3:4/binary-unit:1,V1@Buf4/bitstring>> ->
{V1@V3,V1@Buf4};
<<1:1,V1@Buf2/bitstring>> ->
{V1@V3,V1@Buf4} = case V1@Buf2 of
<<0:1,V1@V6:7,V1@V8:V1@V6/binary-unit:1,V1@Buf9/bitstring>> ->
{V1@V8,V1@Buf9};
<<1:1,0:1,V1@V7:14,V1@V9:V1@V7/binary-unit:1,V1@Buf10/bitstring>> ->
{V1@V9,V1@Buf10};
<<1:1,1:1,V1@V7:6,V1@Buf8/bitstring>> ->
{V1@V9,V1@Buf10}  = decode_fragmented(V1@V7, V1@Buf8, 1),
{V1@V9,V1@Buf10}
end,
{V1@V3,V1@Buf4}
end,
{V1@V11,V1@Buf12}  = {decode_named_bit_string(V1@V0, [{apple,0},{orange,1},{grape,2},{banana,3}]),V1@Buf1},
{V1@V11,V1@Buf12}
end,

%% attribute servingSize(2) with type INTEGER
{Term2,Bytes2} = begin
<<V2@V0:8,V2@Buf1/bitstring>> = Bytes1,
{V2@V0,V2@Buf1}
end,
Res1 = {'FruitSalad',Term1,Term2},
{Res1,Bytes2}.

enc_Fruits(Val) ->
Enc1@bs = try bit_string_name2pos_1(Val) of
Enc1@positions ->
bitstring_from_positions(Enc1@positions, 4)
catch throw:invalid ->
adjust_trailing_zeroes(Val, 4)
end,
Enc1@bits = bit_size(Enc1@bs),
if Enc1@bits =:= 4 ->
[<<0:1>>|Enc1@bs];
Enc1@bits < 128 ->
[<<1:1,Enc1@bits:8>>|Enc1@bs];
Enc1@bits < 16384 ->
[<<1:1,2:2,Enc1@bits:14>>|Enc1@bs];
true ->
[<<1:1>>|encode_fragmented(Enc1@bs, 1)]
end.


dec_Fruits(Bytes) ->
begin
{V1@V0,V1@Buf1} = case Bytes of
<<0:1,V1@V3:4/binary-unit:1,V1@Buf4/bitstring>> ->
{V1@V3,V1@Buf4};
<<1:1,V1@Buf2/bitstring>> ->
{V1@V3,V1@Buf4} = case V1@Buf2 of
<<0:1,V1@V6:7,V1@V8:V1@V6/binary-unit:1,V1@Buf9/bitstring>> ->
{V1@V8,V1@Buf9};
<<1:1,0:1,V1@V7:14,V1@V9:V1@V7/binary-unit:1,V1@Buf10/bitstring>> ->
{V1@V9,V1@Buf10};
<<1:1,1:1,V1@V7:6,V1@Buf8/bitstring>> ->
{V1@V9,V1@Buf10}  = decode_fragmented(V1@V7, V1@Buf8, 1),
{V1@V9,V1@Buf10}
end,
{V1@V3,V1@Buf4}
end,
{V1@V11,V1@Buf12}  = {decode_named_bit_string(V1@V0, [{apple,0},{orange,1},{grape,2},{banana,3}]),V1@Buf1},
{V1@V11,V1@Buf12}
end.


%%%
%%% Run-time functions.
%%%

'dialyzer-suppressions'(Arg) ->
    complete(element(1, Arg)),
    ok.

bit_string_name2pos_1([apple | T]) ->
    [0 | bit_string_name2pos_1(T)];
bit_string_name2pos_1([orange | T]) ->
    [1 | bit_string_name2pos_1(T)];
bit_string_name2pos_1([grape | T]) ->
    [2 | bit_string_name2pos_1(T)];
bit_string_name2pos_1([banana | T]) ->
    [3 | bit_string_name2pos_1(T)];
bit_string_name2pos_1([{bit, Pos} | T]) when is_integer(Pos) ->
    [Pos | bit_string_name2pos_1(T)];
bit_string_name2pos_1([]) ->
    [];
bit_string_name2pos_1(_) ->
    throw(invalid).

adjust_trailing_zeroes(Bs0, Lb) ->
    case bit_size(Bs0) of
        Sz when Sz < Lb ->
            <<Bs0:Sz/bits,0:(Lb - Sz)>>;
        Lb ->
            Bs0;
        _ ->
            <<_:Lb/bits,Tail/bits>> = Bs0,
            Sz = Lb + bit_size(bs_drop_trailing_zeroes(Tail)),
            <<Bs:Sz/bits,_/bits>> = Bs0,
            Bs
    end.

bitstring_from_positions(L0, Lb) ->
    L1 = lists:sort(L0),
    L = diff(L1, -1, Lb - 1),
    << 
      <<B:(N + 0)>> ||
          {B, N} <- L
    >>.

bs_drop_trailing_zeroes(Bs) ->
    bs_drop_trailing_zeroes(Bs, bit_size(Bs)).

bs_drop_trailing_zeroes(Bs, 0) ->
    Bs;
bs_drop_trailing_zeroes(Bs0, Sz0) when Sz0 < 8 ->
    <<Byte:Sz0>> = Bs0,
    Sz = Sz0 - ntz(Byte),
    <<Bs:Sz/bits,_/bits>> = Bs0,
    Bs;
bs_drop_trailing_zeroes(Bs0, Sz0) ->
    Sz1 = Sz0 - 8,
    <<Bs1:Sz1/bits,Byte:8>> = Bs0,
    case ntz(Byte) of
        8 ->
            bs_drop_trailing_zeroes(Bs1, Sz1);
        Ntz ->
            Sz = Sz0 - Ntz,
            <<Bs:Sz/bits,_:Ntz/bits>> = Bs0,
            Bs
    end.

complete(InList) when is_list(InList) ->
    case list_to_bitstring(InList) of
        <<>> ->
            <<0>>;
        Res ->
            Sz = bit_size(Res),
            case Sz band 7 of
                0 ->
                    Res;
                Bits ->
                    <<Res:Sz/bitstring,0:(8 - Bits)>>
            end
    end;
complete(Bin) when is_binary(Bin) ->
    case Bin of
        <<>> ->
            <<0>>;
        _ ->
            Bin
    end;
complete(InList) when is_bitstring(InList) ->
    Sz = bit_size(InList),
    PadLen = 8 - Sz band 7,
    <<InList:Sz/bitstring,0:PadLen>>.

decode_fragmented(SegSz0, Buf0, Unit) ->
    SegSz = SegSz0 * Unit * 16384,
    <<Res:SegSz/bitstring,Buf/bitstring>> = Buf0,
    decode_fragmented_1(Buf, Unit, Res).

decode_fragmented_1(<<0:1,N:7,Buf0/bitstring>>, Unit, Res) ->
    Sz = N * Unit,
    <<S:Sz/bitstring,Buf/bitstring>> = Buf0,
    {<<Res/bitstring,S/bitstring>>, Buf};
decode_fragmented_1(<<1:1,0:1,N:14,Buf0/bitstring>>, Unit, Res) ->
    Sz = N * Unit,
    <<S:Sz/bitstring,Buf/bitstring>> = Buf0,
    {<<Res/bitstring,S/bitstring>>, Buf};
decode_fragmented_1(<<1:1,1:1,SegSz0:6,Buf0/bitstring>>, Unit, Res0) ->
    SegSz = SegSz0 * Unit * 16384,
    <<Frag:SegSz/bitstring,Buf/bitstring>> = Buf0,
    Res = <<Res0/bitstring,Frag/bitstring>>,
    decode_fragmented_1(Buf, Unit, Res).

decode_named_bit_string(Val, NNL) ->
    Bits =
        [ 
         B ||
             <<B:1>> <= Val
        ],
    decode_named_bit_string_1(0, Bits, NNL, []).

decode_named_bit_string_1(Pos, [0 | Bt], Names, Acc) ->
    decode_named_bit_string_1(Pos + 1, Bt, Names, Acc);
decode_named_bit_string_1(Pos, [1 | Bt], Names, Acc) ->
    case lists:keyfind(Pos, 2, Names) of
        {Name, _} ->
            decode_named_bit_string_1(Pos + 1, Bt, Names, [Name | Acc]);
        false ->
            decode_named_bit_string_1(Pos + 1,
                                      Bt, Names,
                                      [{bit, Pos} | Acc])
    end;
decode_named_bit_string_1(_Pos, [], _Names, Acc) ->
    lists:reverse(Acc).

diff([H | T], Prev, Last) ->
    [{1, H - Prev} | diff(T, H, Last)];
diff([], Prev, Last) when Last >= Prev ->
    [{0, Last - Prev}];
diff([], _, _) ->
    [].

encode_fragmented(Bin, Unit) ->
    encode_fragmented_1(Bin, Unit, 4).

encode_fragmented_1(Bin, Unit, N) ->
    SegSz = Unit * N * 16384,
    case Bin of
        <<B:SegSz/bitstring,T/bitstring>> ->
            [<<3:2,N:6>>, B | encode_fragmented_1(T, Unit, N)];
        _ when N > 1 ->
            encode_fragmented_1(Bin, Unit, N - 1);
        _ ->
            case bit_size(Bin) div Unit of
                Len when Len < 128 ->
                    [Len, Bin];
                Len when Len < 16384 ->
                    [<<2:2,Len:14>>, Bin]
            end
    end.

ntz(Byte) ->
    T = {8, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2,
         0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1, 0, 3, 0,
         1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1,
         0, 6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0,
         2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1, 0, 3,
         0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0,
         1, 0, 7, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1,
         0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1, 0,
         3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2,
         0, 1, 0, 6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0,
         1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1,
         0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0,
         2, 0, 1, 0},
    element(Byte + 1, T).
