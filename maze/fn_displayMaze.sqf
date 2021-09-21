params["_mazePassageX", "_mazePassageY", "_seed", "_mazeMarker", "_preGen"];
if(isNil {_mazePassageX} || isNil {_mazePassageY} || isNil {_seed} || isNil {_mazeMarker}) exitWith {};
if(isNil {_preGen}) then {
	_preGen = false;
};
if(!_preGen) then {
	[_mazePassageX, _mazePassageY, _seed] call maze_fnc_generateMaze;
};

//Maze WorldSpace Vars
_mazePosition = getPos _mazeMarker;
_mazeSize = _mazePassageX * _mazePassageY;

//Maze Asset Vars
_mazeWallObject = "Land_BasaltWall_01_8m_F";
_wallWidth = 4;
_wallLength = 8;

_bt = systemTime;

//[_mazePassageX, _mazePassageY, _seed] remoteExecCall ["maze_fnc_generateMaze", 2];

_et = systemTime;
hint format["%1", ((_et select 5) - (_bt select 5))];
array_2D_find = {
	params["_i", "_j"];
	_return = (mazeGenArray select _j) select _i;
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
		_current = [_j, _i] call array_2D_find;
		if(([_current, 1] call BIS_fnc_bitwiseAND) == 0 && (!(_mazePassageX/2 == _j) || !(_i == 0))) then {
			[_j, (-1 * _i), 0] call maze_wall; 
		};
	};
	for "_j" from 0 to _mazePassageX -1 do {
		_current = [_j, _i] call array_2D_find;
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
