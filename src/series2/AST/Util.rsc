module series2::AST::Util

import IO;
import Prelude;
import lang::java::m3::AST;


public Declaration toType(Declaration d) = d;
public Statement toType(Statement s) = s;
public node toType(node n) = n;

public int size(node t) = ( 0 | it + 1 | /node _ := t);

public loc getSrc(Declaration d){
	try return d@src;
	catch: {
		print("<getName(d)>\n");
		return |file:///foo|;
	}
}
public loc getSrc(Statement s){
	try return s@src;
	catch: return |file:///foo|;
}
public loc getSrc(value v){
	return |file:///foo|;
}


public bool isSequence(\compilationUnit(_,_)) = true;
public bool isSequence(\compilationUnit(_,_,_)) = true;
public bool isSequence(\enum(_,_,_,_)) = true;
public bool isSequence(\class(_,_,_,_)) = true;
public bool isSequence(\class(_)) = true;
//Not interested in sequences of parameters.
//public bool isSequence(\method(_,_,_,_,_)) = true;
//public bool isSequence(\method(_,_,_,_)) = true;
//public bool isSequence(\constructor(_,_,_,_,_)) = true;
public bool isSequence(\annotationType(_,_)) = true;

public bool isSequence(\block(_)) = true;
public bool isSequence(\switch(_,_)) = true;
public bool isSequence(\try(_,_)) = true;
public bool isSequence(\try(_,_,_)) = true;

public default bool isSequence(value v) = false;

public set[list[loc]] getSequenceChildLocs(\compilationUnit(is,dd)) = {[c@src | c <- is],[c@src | c <- dd]};
public set[list[loc]] getSequenceChildLocs(\compilationUnit(_,is,dd)) = {[c@src | c <- is],[c@src | c <- dd]};
public set[list[loc]] getSequenceChildLocs(\enum(_,_,cs,ds)) = {[c@src | c <- cs],[c@src | c <- ds]};
public set[list[loc]] getSequenceChildLocs(\class(_,_,_,ds)) = {[c@src | c <- ds]};
public set[list[loc]] getSequenceChildLocs(\class(ds)) = {[c@src | c <- ds]};
public set[list[loc]] getSequenceChildLocs(\annotationType(_,ds)) = {[c@src | c <- ds]};

public set[list[loc]] getSequenceChildLocs(\block(s)) = {[c@src | c <- s]};
public set[list[loc]] getSequenceChildLocs(\switch(_,s)) = {[c@src | c <- s]};
public set[list[loc]] getSequenceChildLocs(\try(_,s)) = {[c@src | c <- s]};
public set[list[loc]] getSequenceChildLocs(\try(_,s,_)) = {[c@src | c <- s]};


