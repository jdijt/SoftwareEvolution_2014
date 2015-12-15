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


/*public bool isSequence(Declaration decl){
	switch(decl){
		case \compilationUnit(_,_): return true;
		case \compilationUnit(_,_,_): return true;
		case \enum(_,_,_,_): return true;
		case \class(_,_,_,_): return true;
		case \class(_): return true;
		case \annotationType(_,_): return true;
	}
	return false;
}*/
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


/*public set[list[Declaration]] getSequenceChildren(Declaration d){
	switch(d){
		case \compilationUnit(is,dd): return {is,dd};
		case \compilationUnit(_,is,dd): return {is,dd};
		case \enum(_,_,cs,ds): return {cs,ds};
		case \class(_,_,_,ds): return {ds};
		case \class(ds): return {ds};
		case \annotationType(_,ds): return {ds};
	}
	return {};
}*/
public set[list[Statement]] getSequenceChildren(Statement stmnt){
	switch (stmnt){
		case \try(_,s,_): return {s};
		case \block(s): return {s};
		case \switch(_,s): return {s};
		case \try(_,s): return {s};
	}
	return {};
}
public default set[list[value]] getSequenceChildren(value v) = {[]};


public real treeSimilarity(&T <:node left, &T <:node right) = treeSimilarity([left],[right]);
public real treeSimilarity(list[&T <:node] left, list[&T <:node] right){
	lEnum = ([] | it + enumerateTree(t) | t <- left);
	rEnum = ([] | it + enumerateTree(t) | t <- right);
	lSize = size(lEnum);
	rSize = size(rEnum);
	dist = listDistance(lEnum, rEnum);
	
	totalSize = toReal(lSize + rSize);
	return (totalSize - dist) / totalSize;
}

public int listDistance(list[str] lEnum, list[str] rEnum){
	lSize = size(lEnum)+1;
	rSize = size(rEnum)+1;
	
	arr = [[0 | x <- [0..rSize]] | y <- [0..lSize]];
	
	for(i <- [1..lSize]){
		arr[i][0] = i;
	}
	for(i <- [0..rSize]){
		arr[0][i] = i;
	}
	for(r <- [1..rSize], l <- [1..lSize]){
		if(rEnum[r-1] == lEnum[l-1]){
			arr[l][r] = arr[l-1][r-1];
		} else {
			arr[l][r] = min([arr[l-1][r]+1, arr[l][r-1]+1, arr[l-1][r-1]+1]);
		} 
	}
	
	return arr[lSize-1][rSize-1];
}

//Enumerate a tree node-by-node in post-order. (left most lowest leaf first always).
public list[str] enumerateTree(&T <:node root){
	result = [];
	visit(root) {
		case node n: result += intercalate("",[getName(n),getNodeValues(n)]);
	}
	return result;
}

public list[value] getNodeValues(&T <:node nod){
	values = [];
	for(c <- getChildren(nod)){
		switch(c){
			case node n: continue;
			case list[node] ns: continue;
			case value v: values += v;
		}
	}
	return values;
}

public test bool testGetSrc(Statement s) = s@src? && getSrc(s) == s@src || getSrc(s) == |unknown:///|;
public test bool testGetSrc() = getSrc(\int()) == |unknown:///|;

public test bool testNodeValues1() = getNodeValues(\block([\break()])) == []; //no values,
public test bool testNodeValues2() = getNodeValues(\block([\break("foobar")])) == []; //values in child node.
public test bool testNodeValues3() = getNodeValues(\label("foo",\label("bar",\break()))) == ["foo"]; //just get parent node value.

//Only generates right for statement? Oh well..
//Tests both enumerateTree and testSize against each other, both should always take all nodes:
public test bool testEnumerateTree_treeSize(Statement t) = size(enumerateTree(t)) == treeSize(t);

//Test upper and lower bounds of listDistance:
//Upper: size of largest input list;
public test bool testListDistance1(list[str] a, list[str] b) = listDistance(a,b) <= max(size(a),size(b));
//Lower: 0 if equal.
public test bool testListDistance2(list[str] a) = listDistance(a,a) == 0;

//Upper bound: 1.0
public test bool testTreeSimilarity1(Statement a, Statement b) = treeSimilarity(a,b) <= 1.0;
//Equal: 1.
public test bool testTreeSimilarity2(Statement a) = treeSimilarity(a,a) == 1.0;
//Completely nonEqual:
public test bool testTreeSimilarity3(Statement a) = treeSimilarity([a],[]) == 0.0;

public test bool testGetSequenceChildren1(Statement s){
	if(getName(s) in {"block","try","switch"}){
		switch(getSequenceChildren(s)){
			case {[*Statement _]}: return true;
		}
		return false; 
	} else {
		return getSequenceChildren(s) == {};
	}
}
public test bool testGetSequenceChildren2(list[Statement] ls, Statement other){
	parents = {\block(ls), \try(other,ls,other), \try(other,ls), \switch(\null(),ls)};
	return getSequenceChildren(getOneFrom(parents)) == {ls};
}

public test bool testIsSequence(Statement s) = (getName(s) in {"block","try","switch"} && isSequence(s)) || !isSequence(s);