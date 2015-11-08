module metrics::UnitSize

import lang::java::m3::AST;

//Counting statements for unit size.
map[loc,int] unitSizes(map[loc,Declaration] units) = (l : ( 0 | it + 1 | /Statement _ := units[l]) | l <- units);