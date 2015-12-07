module series2::AST::Util

import lang::java::m3::AST;


public Declaration valueToDecl(Declaration d) = d;
public Statement valueToStmnt(Statement s) = s;
public node valueToNode(node n) = n;

public loc getSrc(Declaration d){
	try return d@src;
	catch: return |unknown://|;
}
public loc getSrc(Statement s){
	try return s@src;
	catch: return |unknown://|;
}
public loc getSrc(value v){
	return |unknown://|;
}
