module metrics::UnitComplexity

import List;
import lang::java::m3::AST;

public map[loc,int] unitComplexities(map[loc,Declaration] units) = (l : cyclomaticComplexity(units[l]) | l <- units);

//CC equals: edges - nodes + 2.
//So CC can be calculated by measuring the number of branching nodes 
// & the amount of additional branches they create and then  adding 2.
//See: http://www.literateprogramming.com/mccabe.pdf
private int cyclomaticComplexity(Declaration unit){
	cc = 1; //Start at 1;
	
	visit(unit){
		//Simple if, paths: execute block or skip block.
		case \if(_,_): cc += 1;
		//if-with-else: paths: execute ifBlock or execute ElseBlock.
		case \if(_,_,_): cc += 1;
		//Ternary operator:
		case \conditional(_,_,_): cc += 1;
		//Case: paths: Execute case block, or skip.
		case \case(_): cc += 1;
		//While: paths: execute loop body, or skip and continue.
		case \while(_,_): cc += 1;
		//Do: paths: re-execute loop body, or continue;
		case \do(_,_): cc += 1;
		//for: paths: execute loop body, or skip and continue;
		case \for(_,_,_): cc += 1;
		//forEach: paths: execute loop body, or skip and continue (on empty list);
		case \forEach(_,_,_): cc += 1;
		//try: paths: body, and one for every catch block
		case \try(_,catches): cc += size(catches);
		case \try(_,catches,_): cc += size(catches);
		//assert: paths: continue, or throw exception.
		//Not counting these for now, as they do not include function complexity.
		//But rather, serve as a tool to manage this.
		//case \assert(_): cc += 1;
		//case \assert(_,_): cc += 1;
	}
	
	return cc;
}