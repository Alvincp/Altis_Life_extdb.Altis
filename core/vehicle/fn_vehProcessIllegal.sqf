/*
	File: fn_vehProcessIllegal.sqf
	Author: Komodo re-using "Mining" and "Process" scripts.

	Description:
	Processes resources inside the Zamak lab. Will only work for illegal resources.
	Here I assume that transformation doesn't increases the weight taken by items to simplify code.
*/

private["_vehicle","_zone","_weight","_vInv","_items","_space","_itemInfo","_itemIndex","_value","_oldItem","_oldItemName","_newItem","_objectsInVehicle","_playersInVehicle","_upp","_itemIndex","_ui","_progress","_pgText","_progress","_cP","_smoke"];
_vehicle = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;

//-------- Section to check if process is feasible.
if(isNull _vehicle) exitWith {}; //Null was passed?
if(!isNil {_vehicle getVariable "process"}) exitWith {hint localize "Ce laboratoire est déjà occupé, laisse-le finir!";}; //process is already in progress..
closeDialog 0; //Close the interaction menu.
life_action_inUse = true; //Lock out the interaction menu for a bit..

_weight = [_vehicle] call life_fnc_vehicleWeight;
if((_weight select 1) == 0) exitWith {hint "Ce véhicule est vide."; life_action_inUse = false;};

//Number of players in the Lab. Should be 2 or more.
_objectsInVehicle = attachedObjects _vehicle;
_playersInVehicle = "Man" countType _objectsInVehicle;
//if (_playersInVehicle < 2) exitWith {hint "Il faut deux laborantins à bord minimum."; life_action_inUse = false;};
if (fuel _vehicle < 0.50) exitWith {hint "Il n'y a pas assez d'essence pour permettre au labo de fonctionner.";};

//Getting Trunk content
_vInv = _vehicle getVariable ["Trunk",[[],0]];
_items = _vInv select 0;
_space = _vInv select 1;

//--------- Get the resource to be transformed in vehicle invetory. Each time a process is launched, only one type is process if there is several.
_itemInfo = switch(true) do {
	case (["kitmeth",_items] call fnc_index > -1): {["kitmeth","poudrehydroxyde",2500,"Traitement de la Meth","Poudre Hydroxyde Sodium",["kitmeth",_items] call fnc_index]};
	case (["poudrehydroxyde",_items] call fnc_index > -1): {["poudrehydroxyde","crystalmeth",3000,"Traitement de la Poudre Hydroxyde","Cristal de Meth",["poudrehydroxyde",_items] call fnc_index]};
	case (["crystalmeth",_items] call fnc_index > -1): {["crystalmeth","crystalmethpur",3500,"Purification Cristal de Meth","Cristal de Meth Pur",["crystalmeth",_items] call fnc_index]};
	case (["heroinu",_items] call fnc_index > -1): {["heroinu","heroinp",1720,"Traitement de l'Héroïne","Héroïne",["heroinu",_items] call fnc_index]};
	case (["cannabis",_items] call fnc_index > -1): {["cannabis","marijuana",500,"Traitement de la Marijuana","Feuille de Cannabis",["cannabis",_items] call fnc_index]};
	case (["cocaine",_items] call fnc_index > -1): {["cocaine","cocainep",1500,"Traitement de la Cocaïne","Feuille de Coca",["cocaine",_items] call fnc_index]};
	default {[]};
};

if(count _itemInfo == 0) exitWith {hint "Ce laboratoire ne peut traiter les objets présents dans le véhicule."; life_action_inUse = false;};
_vehicle setVariable ["process",true,true]; //Lock the device
//[_vehicle,"life_fnc_soundDevice",true,false] spawn life_fnc_MP; //Broadcast the 'process' sound of the device for nearby units. Komodo: We'll find a sound for the zamak lab later.
life_action_inUse = false; //Unlock it since it's going to do it's own thing...

//Setup vars.
_oldItem = _itemInfo select 0;
_oldItemName = _itemInfo select 4;
_newItem = _itemInfo select 1;
_upp = _itemInfo select 3;
_itemIndex = _itemInfo select 5;
_weightDiff = ([_oldItem] call life_fnc_itemWeight) - ([_newItem] call life_fnc_itemWeight);

//Setup our progress bar.
disableSerialization;
5 cutRsc ["life_progress","PLAIN"];
_ui = uiNameSpace getVariable "life_progress";
_progress = _ui displayCtrl 38201;
_pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["%2 (1%1)...","%",_upp];
_progress progressSetPosition 0.01;
_cP = 0.01;

hint "Les laborantins sont en action, attention aux fumées nocives!";

while{true} do
	{
		if(!alive _vehicle OR isNull _vehicle) exitWith {d};
		if(isEngineOn _vehicle) exitWith {hint "Allumer le moteur a arrêté le travail en cours.";};
		_objectsInVehicle = attachedObjects _vehicle;
		_playersInVehicle = "Man" countType _objectsInVehicle;
		if (_playersInVehicle < 2) exitWith {hint "Il faut deux laborantins à bord minimum. Les pauses toilettes sont interdites.";};

		sleep  0.6;
		_cP = _cP + 0.01;
		_progress progressSetPosition _cP;
		_pgText ctrlSetText format["%3 (%1%2)...",round(_cP * 100),"%",_upp];
		if(_cP >= 1) exitWith {};
		if(!alive player) exitWith {};
		if((_vehicle distance player ) > 10) exitWith{(hint "Tu es trop loin du laboratoire")};
	};
5 cutText ["","PLAIN"];


//All selected item are transformed. so we simply change the name of the item in the Trunk variable.
_value = _items select _itemIndex select 1;
_items set[_itemIndex,[_newItem,_value]];
_vehicle setVariable["Trunk",[_items,_space - (_weightDiff * _value)],true];

//Locality checks... & fuel.
if(local _vehicle) then {
	_vehicle setFuel (fuel _vehicle)-0.5;
} else {
	[[_vehicle,(fuel _vehicle)-0.5],"life_fnc_setFuel",_vehicle,false] spawn life_fnc_MP;
};
//Might need to delete this smoke at another time in case script ends before end.
_vehicle setVariable["process",nil,true];
