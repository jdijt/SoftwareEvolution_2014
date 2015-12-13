module series2::AST::Util

import IO;
import Prelude;
import util::Math;
import lang::java::m3::AST;


public Declaration toDeclaration(Declaration d) = d;
public Statement toStatement(Statement s) = s;
public node toNode(node n) = n;

public int treeSize(value t) = ( 0 | it + 1 | /node _ := t);

public loc getSrc(Declaration d) = d@src?|unknown:///|;
public loc getSrc(Statement s) = s@src?|unknown:///|;
public loc getSrc(value v) =  |unknown:///|;


public bool isSequence(Declaration decl){
	switch(decl){
		case \compilationUnit(_,_): return true;
		case \compilationUnit(_,_,_): return true;
		case \enum(_,_,_,_): return true;
		case \class(_,_,_,_): return true;
		case \class(_): return true;
		case \annotationType(_,_): return true;
	}
	return false;
}
public bool isSequence(Statement stmnt){
	switch(stmnt){
		case \block(_): return true;
		case \switch(_,_): return true;
		case \try(_,_): return true;
		case \try(_,_,_): return true;
	}
	return false;
}
public default bool isSequence(value v) = false;


public set[list[Declaration]] getSequenceChildren(Declaration d){
	switch(d){
		case \compilationUnit(is,dd): return {is,dd};
		case \compilationUnit(_,is,dd): return {is,dd};
		case \enum(_,_,cs,ds): return {cs,ds};
		case \class(_,_,_,ds): return {ds};
		case \class(ds): return {ds};
		case \annotationType(_,ds): return {ds};
	}
	return {};
}	
public set[list[Statement]] getSequenceChildren(Statement stmnt){
	switch (stmnt){
		case \try(_,s,_): return {s};
		case \block(s): return {s};
		case \switch(_,s): return {s};
		case \try(_,s): return {s};
	}
	return {};
}


public real compareTrees(&T hash, &T left, &T right){
	leftId = getIdentifiers(left);
	leftTyp = getTypes(left);
	rightId = getIdentifiers(right);
	rightTyp = getTypes(right);
	
	common = toReal(size(leftId & rightId) + size(leftTyp & rightTyp) + treeSize(hash));
	lnotr = toReal(size(leftId - rightId) + size(leftTyp - rightTyp));
	rnotl = toReal(size(rightId - leftId) + size(rightTyp - leftTyp));
	
	
	if(common == 0){
		println("<left><right>");
	}
	println("result: <((2.0*common)/(2.0*common+lnotr+rnotl))>");
	return ((2.0*common)/(2.0*common+lnotr+rnotl));
}

public set[str] getIdentifiers(&T ast) = {s | /s:str _ := ast};
public set[Type] getTypes(&T ast) = {t | /t:Type _ := ast};