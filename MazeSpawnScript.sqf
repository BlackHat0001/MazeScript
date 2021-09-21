//Maze Generation Vars 
_mazePassageX = 20; 
_mazePassageY = 20; 
_mazeSize = _mazePassageX * _mazePassageY; 
_seed = 123124235134; 
 
//Maze WorldSpace Vars 
_mazePassageDiameter = 3; 
_mazePosition = position player; 
 
//Maze Asset Vars 
_mazeWallObject = "Land_BasaltWall_01_8m_F"; 
_wallWidth = 4; 
_wallLength = 8; 
 
_xPos = _mazePassageX; 
_yPos = _mazePassageY; 
 
xPg = _xPos; 
yPg = _yPos; 
_maze = []; 
_dirArray = [[1 , 0, -1], [2, 0, 1], [4, 1, 0], [8, -1, 0]]; 
 
for "_i" from 0 to (_yPos) -1 do {  
 _maze append [[]];  
 for "_j" from 0 to (_xPos) -1 do {  
 (_maze select _i) append [0];  
 };  
}; 
 
shuffleArray = { 
 for "_i" from 0 to (count _this) -1 do { 
  _swap = floor (_seed random (count _this)); 
  _temp = _this select _swap; 
  _this set [_swap, (_this select _i)]; 
  _this set [_i, _temp]; 
 }; 
 _this 
}; 
 
dir_opposite = { 
 params["_bit"]; 
 _returnVar = 1; 
 if(_bit == 1) then { 
  _returnVar = 2; 
 }; 
 if(_bit == 2) then { 
  _returnVar = 1; 
 }; 
 if(_bit == 4) then { 
  _returnVar = 8; 
 }; 
 if(_bit == 8) then { 
  _returnVar = 4; 
 }; 
 _returnVar 
}; 
array_2D_find = { 
 params["_i", "_j", "_array"]; 
 _return = 0; 
 if((_i>=xPg || _j>=yPg) || (_i<0 || _j<0)) then { 
  _return = 0; 
 } else { 
  _return = (_array select _j) select _i; 
 }; 
 _return 
}; 
 
array_2D_set = { 
 params["_i", "_j", "_array", "_data"]; 
 _bitwiseResult = [([_i, _j, _array] call array_2D_find), _data] call BIS_fnc_bitwiseOR; 
 (_array select _j) set [_i, _bitwiseResult]; 
 _array 
}; 
 
generateMaze = { 
 params["_cx", "_cy", "_maze", "_dirArray", "_xPos", "_yPos"]; 
 _dirs = (_dirArray call shuffleArray); 
 { 
  _nx = _cx + (_x select 1); 
  _ny = _cy + (_x select 2); 
  if(((_nx >= 0) && (_nx < _xPos)) && ((_ny >= 0) && (_ny < _yPos)) && ([_nx, _ny, _maze] call array_2D_find == 0)) then { 
   _array = [_cx, _cy, _maze, (_x select 0)] call array_2D_set; 
   _array = [_nx, _ny, _maze, ([_x select 0] call dir_opposite)] call array_2D_set; 
   [_nx, _ny, _maze, _dirArray, _xPos, _yPos] call generateMaze; 
  }; 
 } forEach _dirs; 
}; 
 
[0, 0, _maze, _dirArray, _xPos, _yPos] call generateMaze; 
 
_mazeData = _maze; 
 
array_2D_find_2 = { 
 params["_i", "_j", "_array"]; 
 _return = (_array select _j) select _i; 
 _return 
}; 
 
maze_wall = { 
 params["_i", "_j", "_dir"]; 
 _i = _i + 1; 
 _j = _j + 1; 
 _xWallPos = (_wallLength * _i) + (_mazePosition select 0); 
 _yWallPos = (_wallLength * _j) + (_mazePosition select 1); 
 _wallPos = [0, 0]; 
 if(_dir == 90) then { 
  _wallPos = [_xWallPos, _yWallPos - (0.5 * _wallWidth), 0]; 
 } else { 
  _wallPos = [_xWallPos + (0.5 * _wallLength), _yWallPos, 0]; 
 }; 
 _wallCurrent = _mazeWallObject createVehicle _wallPos; 
 _wallCurrent enableSimulation false; 
 _wallCurrent setPos _wallPos; 
 _wallCurrent setDir _dir; 
}; 
 
if(_wallWidth > _wallLength) then { 
 _wallLengthNew = _wallLength; 
 _wallLength = _wallWidth; 
 _wallWidth = _wallLengthNew; 
}; 
for "_i" from 0 to _mazePassageY -1 do { 
 for "_j" from 0 to _mazePassageX -1 do { 
  _current = [_j, _i, _mazeData] call array_2D_find_2; 
  if(([_current, 1] call BIS_fnc_bitwiseAND) == 0 && (!(_mazePassageX/2 == _j) || !(_i == 0))) then { 
   [_j, (-1 * _i), 0] call maze_wall;  
  }; 
 }; 
 for "_j" from 0 to _mazePassageX -1 do { 
  _current = [_j, _i, _mazeData] call array_2D_find_2; 
  if(([_current, 8] call BIS_fnc_bitwiseAND) == 0) then { 
   [_j, (-1 * _i), 90] call maze_wall; 
  }; 
 }; 
 [_mazePassageY, (-1 * _i), 90] call maze_wall; 
}; 
 
for "_i" from 0 to _mazePassageX -1 do { 
 if(!(_mazePassageX/2 == _i)) then { 
  [_i, -1 * (_mazePassageY), 0] call maze_wall; 
 }; 
}; 
