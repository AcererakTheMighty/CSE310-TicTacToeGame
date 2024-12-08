-module(tic_tac_toe).
-export([start/0]).

%%% Entry point for the game
start() ->
    io:format("Welcome to Tic-Tac-Toe!~n"),
    play_game([["_", "_", "_"], ["_", "_", "_"], ["_", "_", "_"]], x).

%%% Display the game board
display_board(Board) ->
    lists:foreach(fun(Row) -> 
        io:format("~s~n", [string:join(Row, " ")])
    end, Board).

%%% Play the game recursively
play_game(Board, Player) ->
    display_board(Board),
    case check_winner(Board) of
        none ->
            io:format("Player ~p's turn. Enter row and column (0-2, separated by space):~n", [Player]),
            Input = io:get_line(""),
            case parse_input(Input) of
                {Row, Col} when valid_move(Board, Row, Col) ->
                    UpdatedBoard = make_move(Board, Row, Col, Player),
                    NextPlayer = switch_player(Player),
                    play_game(UpdatedBoard, NextPlayer);
                _ ->
                    io:format("Invalid move. Try again.~n"),
                    play_game(Board, Player)
            end;
        Winner when Winner =:= x; Winner =:= o ->
            io:format("Player ~p wins!~n", [Winner]),
            display_board(Board);
        draw ->
            io:format("It's a draw!~n"),
            display_board(Board)
    end.

%%% Parse input into row and column
parse_input(Input) ->
    case string:split(string:strip(Input), " ") of
        [RowStr, ColStr] ->
            case {string:to_integer(RowStr), string:to_integer(ColStr)} of
                {ok, Row}, {ok, Col} -> {Row, Col};
                _ -> invalid
            end;
        _ -> invalid
    end.

%%% Check if a move is valid
valid_move(Board, Row, Col) when Row >= 0, Row < 3, Col >= 0, Col < 3 ->
    lists:nth(Row + 1, Board) |> lists:nth(Col + 1) == "_";
valid_move(_, _, _) -> false.

%%% Make a move on the board
make_move(Board, Row, Col, Player) ->
    lists:mapfoldl(fun update_row/2, {Row, Col, Player}, Board).

update_row(CurrentRow, {Row, Col, Player}) when Row =:= 0 ->
    {lists:mapfoldl(fun update_col/2, {Col, Player}, CurrentRow), {Row - 1, Col, Player}};
update_row(CurrentRow, {Row, Col, Player}) ->
    {CurrentRow, {Row - 1, Col, Player}}.

update_col(_, {Col, Player}) when Col =:= 0 -> {Player, {Col - 1, Player}};
update_col(CurrentCell, {Col, Player}) -> {CurrentCell, {Col - 1, Player}}.

%%% Switch to the other player
switch_player(x) -> o;
switch_player(o) -> x.

%%% Check the game winner
check_winner(Board) ->
    Winner = case check_lines(Board) of
        none -> check_lines(transpose(Board));
        Result -> Result
    end,
    case Winner of
        none -> check_draw(Board);
        _ -> Winner
    end.

check_lines([]) -> none;
check_lines([Row | Rest]) ->
    case is_winning_row(Row) of
        true -> lists:nth(1, Row);
        false -> check_lines(Rest)
    end.

is_winning_row([A, A, A]) when A =/= "_" -> true;
is_winning_row(_) -> false.

transpose(Board) ->
    lists:mapfoldl(fun(_, Cols) -> 
        {lists:map(fun(Row) -> hd(Row) end, Cols), lists:map(fun(Row) -> tl(Row) end, Cols)} 
    end, Board).

check_draw(Board) ->
    AllFilled = lists:all(fun(Row) -> lists:all(fun(Cell) -> Cell =/= "_" end, Row) end, Board),
    if AllFilled -> draw; true -> none end.
