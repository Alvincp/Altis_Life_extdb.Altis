cutText ["+ 600000 $", "PLAIN"];
life_liquide = life_liquide + 600000;
[[format["%1 s'est donné 600K",name player]],"TON_fnc_writeLog",false,false] spawn life_fnc_MP;