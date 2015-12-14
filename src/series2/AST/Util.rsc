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

//Count tree difference, assumes common structure (i.e.: equal normalized tree).
/*public real treeDistance(list[node] lns, list[node] rns){
	leftNodes = sort([<getName(n), intercalate("", sort(getNodeValues(n)))> | /n:node _ := lns]);
	rightNodes = sort([<getName(n), intercalate("", sort(getNodeValues(n)))> | /n:node _ := rns]);
	
	common = 0.0;
	lnotr = 0.0;
	rnotl = 0.0;
	
	<lh,lrest> = pop(leftNodes);
	<rh,rrest> = pop(rightNodes);
	while(size(lrest) != 0 && size(rrest) != 0){
		if(lh == rh){
			common += 1;
			<lh,lrest> = pop(lrest);
			<rh,rrest> = pop(rrest);
		} else if(lh > rh){
			rnotl += 1;
			<rh,rrest> = pop(rrest);
		} else if(rh > lh){
			lnotr += 1;
			<lh,lrest> = pop(lrest);
		}
	}
	lnotr += size(lrest);
	rnotl += size(rrest);
	
	return (2*common)/(2*common + lnotr + rnotl);
} */


public real treeSimilarity(&T <:node left, &T <:node right) = treeSimilarity([left],[right]);
public real treeSimilarity(list[&T <:node] left, list[&T <:node] right){
	lEnum = ([] | it + enumerateTree(t) | t <- left);
	rEnum = ([] | it + enumerateTree(t) | t <- right);
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
	totalSize = toReal(lSize + rSize);
	return (totalSize - arr[lSize-1][rSize-1]) / totalSize; 
}

//Enumerate a tree node-by-node in post-order. (left most lowest leaf first always).
public list[str] enumerateTree(&T <:node root){
	result = [];
	visit(root) {
		case node n: result += intercalate("",[typeOf(n),getName(n),getNodeValues(n)]);
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