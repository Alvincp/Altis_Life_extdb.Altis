/*
	Author: Bryan "Tonic" Boardwine

	Description:
	Notifies members that the gang has been disbanded.
*/
private["_group"];
_group = [_this,0,grpNull,[grpNull]] call BIS_fnc_param;
if(isNull _group) exitWith {}; //Fail horn please.

hint "Le chef a supprimé le gang.";

//New line for close dialog gang
if(!isNull (findDisplay 2620)) then {closedialog 2620};
[player] joinSilent (createGroup civilian);
if(count units _group == 0) then {
	deleteGroup _group;
};