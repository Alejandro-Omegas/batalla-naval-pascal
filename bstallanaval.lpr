program bstallanaval;

uses
  crt, SysUtils;

const
  Rows = 10;
  Cols = 10;

type
  Tboard = array[1..Rows, 1..Cols] of Char;
  Tplayer = record
    name: String;
    score: Integer;
    boats: Integer;
    boatBoard: Tboard; //where the player's boats are
    fireBoard: Tboard; //places where the player fired on the opponent's board
  end;

var
  //Players
  pCpu: Tplayer;
  pPlayer: Tplayer;
  //misc
  turn: Boolean; //false=CPU, true=Player
  exitFlag: Boolean; //exit flag
  y, x: Integer;
  isRow: Boolean; //flag to signal the proc prompt if it is row or not (col): true=row, false=col
  bot: Boolean; //to turn on/off the bot to play for you

//** Initialize data structures
procedure initialize(
  var pCpu: Tplayer; var pPlayer: Tplayer; //var passes by reference
  cpuBoats: Integer; playerBoats: Integer; //number of boats to assign to each player
  var turn: Boolean; var exitFlag: Boolean);
var
  y, x: Integer;
begin
  //clamping total of boats if they are more than the board can hold
  if cpuBoats > Rows*Cols then
     cpuBoats := Rows*Cols
  else if cpuBoats < 1 then
     cpuBoats := 1;

  if playerBoats > Rows*Cols then
     playerBoats := Rows*Cols
  else if playerBoats < 1 then
     playerBoats := 1;

  pCpu.name:= 'CPU';
  pPlayer.name := 'Player';
  pCpu.score:= 0;
  pCpu.boats:= cpuBoats;
  pPlayer.score:= 0;
  pPlayer.boats:= playerBoats;

  turn := Random(2) <> 0;  // <> 0 to convert to true-false
  exitFlag := false;

  //fill all boards with water
  for y := 1 to Rows do
  begin
    for x := 1 to Cols do
    begin
        pCpu.boatBoard[y, x] := ' ';
        pCpu.fireBoard[y, x] := ' ';
        pPlayer.boatBoard[y, x] := ' ';
        pPlayer.fireBoard[y, x] := ' ';
    end;
  end;

  //populate with boats
  while(cpuBoats > 0) do
  begin
    y := Random(Rows) + 1;
    x := Random(Cols) + 1;

    if pCpu.boatBoard[y, x] = ' ' then
    begin
      pCpu.boatBoard[y, x] := 'O';
      cpuBoats := cpuBoats - 1;
    end;
  end;

  while(playerBoats > 0) do
  begin
    y := Random(Rows) + 1;
    x := Random(Cols) + 1;

    if pPlayer.boatBoard[y, x] = ' ' then
    begin
      pPlayer.boatBoard[y, x] := 'O';
      playerBoats := playerBoats - 1;
    end;
  end;
end;

//** USED by: printBoard
procedure drawSingleBoard(board: Tboard);
var
  y, x: Integer;
begin
  //header
  Write('    ');
  for x := 1 to Cols do
  begin
    if x < 10 then
      Write(' ', x,' ')
    else
      Write(' ', x);
  end;
  Writeln();

  Write('    ');
  for x := 1 to Cols do
    Write('___');
  Writeln();

  //Body
  for y := 1 to Rows do
  begin
    if y < 10 then
      Write(' ', y, ' |')
    else
      Write(' ', y, '|');
    for x:= 1 to Cols do
    begin
      Write(' ', board[y, x], ' ');
    end;
    Writeln('| ', y);
  end;

  //Foot line
  Write('    ');
  for x := 1 to Cols do
  begin
    Write('---');
    //if x < 10 then
    //  Write('-', x,'-')
    //else
    //  Write('-', x);
  end;
  Writeln();
end;

//** Draws both boards (a player's fire board and boat board, stacked over each other)
procedure printBoard(player: Tplayer; oppScore: Integer);
begin
  Writeln('Your score: ', player.score);
  Writeln('Your score: ', player.score, ' - CPU score: ', oppScore);  //player score duplicated because the console eats the firls line of string for some reason

  drawSingleBoard(player.fireBoard);
  Writeln();
  drawSingleBoard(player.boatBoard);
end;

//** Prompts coordinate input
procedure promptCoord(var coord: Integer; var exitFlag: Boolean; isRow: Boolean);
var
  input: String;
  errorCode: Integer;
begin
  repeat
    if(isRow) then
    begin
      Write('Enter row value (1-',Rows ,'), or ''exit'' >> ');
    end
    else
    begin
      Write('Enter column value (1-',Cols ,'), or ''exit'' >> ');
    end;

    Readln(input);

    Val(input, coord, errorCode); //checks if input is valid integer; if so, it stores it in coord and sets errorCode to 0

    if(errorCode <> 0) then
    begin
      if input = 'exit' then
      begin
        exitFlag := true;
        errorCode := 0; //so it can get out of the loop
      end
      else if input = 'bot' then
      begin
        bot := true; //turns on bot mode, though the player still has to enter a valid coord
      end
      else
      begin
       Writeln('Invalid input. Try again >> ');
      end;
    end
    else
    begin
       if coord < 1 then //clamping values if out of bounds
         coord := 1
       else if coord > Rows then
         coord := Rows;
    end;
  until(errorCode = 0)
end;

//** when firing. USED by: playLoop
procedure fireProc(var player, opponent: Tplayer; y, x: Integer);
begin
    Writeln(player.name, ' fired at coordenate ', y, ' ', x);
    Sleep(1000);

    if opponent.boatBoard[y][x] = ' ' then
    begin
      Writeln('Missed!');
      player.fireBoard[y][x] := '+';
      Sleep(2000);
    end
    else
    begin
      Writeln('Hit!');
      Sleep(2000);

      player.fireBoard[y][x] := 'X';
      opponent.boatBoard[y][x] := 'X';
      opponent.boats := opponent.boats - 1;
      player.score := player.score + 1;

      if opponent.boats <= 0 then
      begin
        exitFlag := true;

        ClrScr;
        if player.name = 'Player' then
          printBoard(player, opponent.score)
        else
          printBoard(opponent, player.score);

        Writeln(opponent.name, ' is out of boats!');
        Writeln(player.name, ' wins!');
      end;
    end;
end;

//** Process a single loop of gameplay
procedure playLoop(
  var pCpu: Tplayer; var pPlayer: Tplayer;
  var turn: Boolean; var exitFlag: Boolean);
var
  thinking: Integer; //to pause to simulate CPU ''thinking''
  y, x: Integer; //coordenates chosen
begin
  if turn then //CPU's turn
  begin
    thinking := Random(3000) + 2001; //2-5 seconds
    Writeln('CPU''s turn');
    Writeln('Thinking...');
    Sleep(thinking);

    while true do
    begin
      y := Random(Rows) + 1;
      x := Random(Cols) + 1;

      if pCpu.fireBoard[y][x] = ' ' then //only a spot not fired at yet is valid
        Break;
    end;

    fireProc(pCpu, pPlayer, y, x);
  end
  else //Player's turn
  begin
    Writeln('Player''s turn');

    if not bot then //bot turned off, so the player can input coords
    begin
      while true do
      begin
        promptCoord(y, exitFlag, true); //true is isRow var

        if exitFlag then
        begin
         Exit;
        end;

        promptCoord(x, exitFlag, false);

        if exitFlag then
        begin
         Exit;
        end;

        if pPlayer.fireBoard[y][x] = ' ' then //if it is a place not fired at yet
          Break
        else
        begin
          ClrScr;
          printBoard(pPlayer, pCpu.score);
          Writeln('Coordenates already entered. Try different coordenates...');
        end;
      end;
    end
    else //bot mode
    begin
      thinking := Random(3000) + 2001; //2-5 seconds
      Writeln('Thinking...');
      Sleep(thinking);

      while true do
      begin
        y := Random(Rows) + 1;
        x := Random(Cols) + 1;

        if pPlayer.fireBoard[y][x] = ' ' then //only a spot not fired at yet is valid
          Break;
      end;
    end;

    fireProc(pPlayer, pCpu, y, x);
  end;

  //changes turn
  if turn then
  begin
    turn := false
  end
  else
  begin
    turn := true
  end;

  //refresh screen
  ClrScr;
  printBoard(pPlayer, pCpu.score);
end;

//** main
begin
  Randomize;
  bot := false;

  initialize(pCpu, pPlayer, 3, 3, turn, exitFlag);
  printBoard(pPlayer, pCpu.score);

  //main process
  while(not exitFlag) do
  begin
    playLoop(pCpu, pPlayer, turn, exitFlag);
  end;

  //finish
  WriteLn();
  Write('Press Enter to exit...');
  ReadLn; // Waits for the user to press Enter
end.
