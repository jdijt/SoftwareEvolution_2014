module metrics::UnitComplexity

import List;
import lang::java::m3::AST;

public rel[loc,int] unitComplexities(rel[loc,Declaration] units) = {<l, cyclomaticComplexity(ast)> | <l,ast> <- units};

//CC equals: edges - nodes + 2 in the control flow graph.
//See: http://www.literateprogramming.com/mccabe.pdf

//This implementation assumes the given unit has a CC of 1, i.e. it looks like this O --> O --> O --> O, or, simplified: O --> O.
//The cc for a method like that is 1 (n - (n+1) + 2 == 1), because it always has 1 more node than it has edges.
//Every branching statement extends this graph with 2 edges and 1 node, thus increasing the CC by 1.
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
		case \for(_,_,_,_): cc += 1;
		//foreach: paths: execute loop body, or skip and continue (on empty list);
		case \foreach(_,_,_): cc += 1;
		//the catches are the actual branching statement, so count 1 branch per catch.
		case \try(_,[*C]): cc += size(C);
		case \try(_,[*C],_): cc += size(C);
		//Infix operators (see mccabe pg 315);
		case \infix(_,"&&",_): cc += 1;
		case \infix(_,"||",_): cc += 1;
		//asserts:
		case \assert(_): cc += 1;
		case \assert(_,_): cc += 1;
	}
	
	return cc;
}

////Some testdata:
private Declaration abstractMethod = \method(\int(), "testMethod", [], []);
private Declaration emptyMethod	   = \method(\int(), "testMethod", [], [], \empty());
private Declaration simpleMethod   = \method(\int(), "testMethod", [], [], \block([\empty() | i <- [0..19]]));
private Declaration complexMethod   = \method(\int(), "testMethod", [], []
									 ,\block([
									 	\if(\infix(\booleanLiteral(true),"&&",\booleanLiteral(true)), \empty())           //3
									 	,\if(\infix(\booleanLiteral(true),"||",\booleanLiteral(true)), \empty(),\empty()) //5
									 	,\try(\empty(),[\catch(\parameter(\int(),"",0),\empty()) | i <- [0..10]])         //15
									  	,\while(\booleanLiteral(true), \empty())                                          //16
									  	,\do(\empty(),\booleanLiteral(true))                                              //17
									  	,\case(\booleanLiteral(true))                                                     //18
									  	,\for([],\null(),[],\empty())                                                     //19
									  	,\for([],[],\empty())                                                             //20
									  	,\foreach(\parameter(\int(),"",0),\null(),\empty())                               //21
									  	,\expressionStatement(\conditional(\null(),\null(),\null()))                      //22
									 ]));

//some tests for unitComplexities:
public test bool testUnitComplexities_emptyRel() = unitComplexities({}) == {};
public test bool testUnitComplexities_nonEmpty() = unitComplexities({<|project://foo|,emptyMethod>}) == {<|project://foo|,1>};

//some tests for cyclomaticComplexity:
public test bool testCycloComp_abstract() = cyclomaticComplexity(abstractMethod) == 1;
public test bool testCycloComp_empty() = cyclomaticComplexity(emptyMethod) == 1;
public test bool testCycloComp_simple() = cyclomaticComplexity(simpleMethod) == 1;
public test bool testCycloComp_complex() = cyclomaticComplexity(complexMethod) == 22;
