module series2::Main


import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public rel[loc,Declaration] main(M3 project, set[Declaration] projectASTs){
	cuLocs = {};
	visit(projectASTs){
		case c:\compilationUnit(_,_): cuLocs += <c@src, c>;
		case c:\compilationUnit(_,_,_): cuLocs += <c@src, c>;
	}
	
	return cuLocs;
}