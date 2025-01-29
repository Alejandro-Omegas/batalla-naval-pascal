program bstallanaval;

uses
  SysUtils;

const
  Rows = 10;
  Cols = 10;

type
  Tboard = array[1..Rows, 1..Cols] of Char;
  Tturn = (CPU, Player);
  Tplayer = record
    name: String;
    score: Integer;
    boats: Integer;
  end;

var
  //boards
  cpuBoard: Tboard;
  playerBoard: Tboard;
  //player records
  pCpu: Tplayer;
  pPlayer: Tplayer;
  //misc
  turn: Tturn;
  n: Boolean; //for turn index: 0=flase, any other=true
  exit: Boolean; //exit flag
  input: String; //raw input
  errorCode: Integer; //to validate input
  y, x: Integer; //user response

//** Initialize data structures
procedure initialize(
  var cpuBoard: Tboard; var playerBoard: Tboard;
  var pCpu: Tplayer; var pPlayer: Tplayer;
  cpuBoats: Integer; playerBoats: Integer;
  var turnIndex: Boolean; var exit: Boolean); //var pass by reference
var
  y, x: Integer;
begin
  pCpu.name:= 'CPU';
  pPlayer.name := 'Player';
  pCpu.score:= 0;
  pCpu.boats:= cpuBoats;
  pPlayer.score:= 0;
  pPlayer.boats:= playerBoats;

  turnIndex := Random(2) <> 0;  // <> 0 to convert to true-false
  exit := false;

  //fill both boards with water
  for y := 1 to Rows do
  begin
    for x := 1 to Cols do
    begin
        cpuBoard[y, x] := ' ';
        playerBoard[y, x] := ' ';
    end;
  end;

  //clamping total of boats if they are more than the board can hold
  if (cpuBoats > Rows*Cols) then
     cpuBoats := Rows*Cols;

  if(playerBoats > Rows*Cols) then
     playerBoats := Rows*Cols;

  //populate with boats
  while(cpuBoats > 0) do
  begin
    y := Random(Rows) + 1;
    x := Random(Cols) + 1;

    if(cpuBoard[y, x] = ' ') then
    begin
      cpuBoard[y, x] := 'O';
      cpuBoats := cpuBoats - 1;
    end;
  end;

  while(playerBoats > 0) do
  begin
    y := Random(Rows) + 1;
    x := Random(Cols) + 1;

    if(playerBoard[y, x] = ' ') then
    begin
      playerBoard[y, x] := 'O';
      playerBoats := playerBoats - 1;
    end;
  end;
end;

//** Draw board
procedure printBoard(board: Tboard; player: Tplayer);
var
  y, x: Integer;
begin
  //header
  Writeln(' ', player.name);
  Writeln(' Score: ', player.score);

  //header line
  Write(' +');
  for y := 1 to Rows do
    Write('---');
  Writeln('+');

  //Body
  for y := 1 to Rows do
  begin
    Write(' |');
    for x:= 1 to Cols do
    begin
      if(player.name = 'Player') then //only prints boat if it is the player's or...
      begin
        Write(' ', board[y, x], ' ');
      end
      else if(board[y, x] = 'X') then //...it is CPU's destroyed boats
      begin
        Write(' ', board[y, x], ' ');
      end
      else
      begin
        Write('   ');
      end;
    end;
    Writeln('|');
  end;

  //Foot line
  Write(' +');
  for y := 1 to Rows do
    Write('---');
  Writeln('+');
end;

//** Draw full boards
procedure prinfFullBoards(cpuBboard: Tboard; pCpu: Tplayer; playerBoard: Tboard; pPlayer: Tplayer);
begin
  printBoard(cpuBoard, pCpu);
  Writeln();
  printBoard(playerBoard, pPlayer);
end;

//** main
begin
  Randomize;

  initialize(cpuBoard, playerBoard, pCpu, pPlayer, 10, 10, n, exit);
  prinfFullBoards(cpuBoard, pCpu, playerBoard, pPlayer);

  while(not exit) do
  begin
    repeat
      Write('Enter row value (1-',Rows ,'), or ''exit'' >> ');
      Readln(input);

      Val(input, y, errorCode); //

      if(errorCode <> 0) then
      begin
        if(input = 'exit') then
        begin
          exit := true;
          errorCode := 0;
        end
        else
        begin
         Writeln('Invalid input. Try again >> ');
        end;
      end
      else
      begin
         if(y < 1) or (y > Rows) then
         begin
            Writeln('Value out of bonds. Try again >> ');
            errorCode := -1;
         end;
      end;
    until(errorCode = 0)



  end;

  //n := Random(2) <> 0;  // n <> 0 to convert to true-false
  //turn := Tturn(n);
  //Writeln(turn);
  end;

  //finish
  WriteLn();
  Write('Press Enter to exit...');
  ReadLn; // Waits for the user to press Enter
end.
