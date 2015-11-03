module metrics::UnitComplexity

import lang::java::m3::AST;

str unitComplexityResult(map[loc,Declaration] units){
	return "TODO!";
}


int cyclomaticComplexity(Declaration unit){
	nodes = 0;
	edges = 0;
	
	visit(unit){
		case \if(_,_):{
			nodes = nodes + 1;
			edges = edges + 2;
		}
		case \if(_,_,_):{
			nodes = nodes + 1;
			edges = edges + 2;
		}
		case \case(_):{
			nodes = nodes + 1;
			edges = edges + 2;
		}
		case \while(_,_):{
			nodes = nodes + 1;
			edges = edges + 2;
		}
		case \for(_,_,_):{
			nodes = nodes + 1;
			edges = edges + 2;
		}
	}
}