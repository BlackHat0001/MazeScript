params["_xPos", "_yPos", "_seed"];
iter = 0;
mazeSeed = _seed;
xPg = _xPos;
yPg = _yPos;
mazeGenArray = [];
arrayHistory = [];
_dirArray = [[1 , 0, -1], [2, 0, 1], [4, 1, 0], [8, -1, 0]];

for "_i" from 0 to (_yPos) -1 do { 
 mazeGenArray append [[]]; 
 for "_j" from 0 to (_xPos) -1 do { 
	(mazeGenArray select _i) append [0]; 
 }; 
};

shuffleArray = {
	for "_i" from 0 to (count _this) -1 do {
		_swap = floor (mazeSeed random (count _this));
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
	params["_i", "_j"];
	_return = 0;
	if((_i>=xPg || _j>=yPg) || (_i<0 || _j<0)) then {
		_return = 0;
	} else {
		_return = (mazeGenArray select _j) select _i;
	};
	_return
};

array_2D_set = {
	params["_i", "_j", "_data"];
	_bitwiseResult = [([_i, _j] call array_2D_find), _data] call BIS_fnc_bitwiseOR;
	(mazeGenArray select _j) set [_i, _bitwiseResult];
};

generateMaze = {
	params["_cx", "_cy", "_dirArray", "_xPos", "_yPos"];
	_dirs = (_dirArray call shuffleArray);
	iter = iter + 1;
	{
		_nx = _cx + (_x select 1);
		_ny = _cy + (_x select 2);
		if(((_nx >= 0) && (_nx < _xPos)) && ((_ny >= 0) && (_ny < _yPos)) && ([_nx, _ny] call array_2D_find == 0)) then {
			[_cx, _cy, (_x select 0)] call array_2D_set;
			[_nx, _ny, ([_x select 0] call dir_opposite)] call array_2D_set;
			[_nx, _ny, _dirArray, _xPos, _yPos] call generateMaze;
		};
	} forEach _dirs;
};

[0, 0, _dirArray, _xPos, _yPos] call generateMaze;

mazeGenArray
//waitUntil { scriptDone _handle && iter == _xPos * _yPos };
