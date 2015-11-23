module series1::util::AST

import lang::java::m3::AST;

public rel[loc,Declaration] getUnitASTs(set[Declaration] projectASTs){
	unitASTs = {};
	
	//Only extract methods with an implementation or if they are constructors.
	visit(projectASTs){
		case m: \method(_,_,_,_,_): unitASTs += <m@src, m>;
		case c: \constructor(_,_,_,_): unitASTs += <c@src, c>;
	}
	
	return unitASTs;
}