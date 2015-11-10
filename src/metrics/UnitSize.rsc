module metrics::UnitSize

import lang::java::m3::AST;

//Counting statements for unit size.
public rel[loc,int] unitSizes(rel[loc,Declaration] units) = {<l, ( 0 | it + 1 | /Statement _ := ast)> | <l,ast> <- units};