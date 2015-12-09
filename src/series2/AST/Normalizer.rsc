module series2::AST::Normalizer

import Prelude;
import lang::java::m3::AST;

private map[loc, Declaration] knownDecls = ();
private map[loc, Statement] knownStatements = ();

public &T<:node normalizeLeaves(&T<:node n){
	//Check if we have seen this node before:
	switch(n){
		case d:Declaration _ :{
			try {
				if(d@src in knownDecls){
					return knownDecls[d@src];
				}
			}
			catch: fail;
		}
		case s:Statement _ :{
			try {
				if(s@src in knownStatements){
					return knownStatements[s@src];
				}
			}
			catch: fail;
		}
	}
	
	return visit(n){
	//Declarations get cached by src, following lack this annotation, so we don't cache them.
		case v:\variables(_,_) => delAnnotations(v)
		case p:\package(_) => delAnnotations(p)
		case p:\package(_,_) => delAnnotations(p)
		case d:Declaration _ => replaceNode(d)
	
	//Statements get cached by src as well:
		case s:Statement _ => replaceNode(s)
		
	//Expressions with names:
    	case \fieldAccess(_, e, _) => \fieldAccess(false, e, "")
		case \fieldAccess(_, _) => \fieldAccess(false, "")
		case \methodCall(_, _, a) => \methodCall(false, "", a)
		case \methodCall(_, _, _, a) => \methodCall(false,"", a)
		case \variable(_, e) => \variable("", e)
		case \variable(_, e, i) => \variable("", e, i)
		//Literals, all replaced with the same literal (\null()) (this is why \null is not a case here).
		case \characterLiteral(_) => \null()
		case \number(_) => \null()
		case \booleanLiteral(_) => \null()
		case \stringLiteral(_) => \null()
		//Names/identifiers: all replaced with a simpleName("").
		case \qualifiedName(_,_) => \simpleName("")
		case \simpleName(_) => \simpleName("")
		case \this() => \simpleName("")
		case \this(_) => \simpleName("")
		case \super() => \simpleName("")
		//Annotations:
		case \markerAnnotation(_) => \markerAnnotation("")
		case \normalAnnotation(_, e) => \normalAnnotation("", e)
		case \singleMemberAnnotation(_, e) => \singleMemberAnnotation("", e)
		case \memberValuePair(_, e) => \memberValuePair("", e)
    	
	//Types:
		case \qualifiedType(_,e) => simpleType(\simpleName(""))
		case \simpleType(e) => simpleType(\simpleName(""))
		case wildcard() => simpleType(\simpleName(""))
		case \int() => simpleType(\simpleName(""))
	    case short() => simpleType(\simpleName(""))
	    case long() => simpleType(\simpleName(""))
	    case float() => simpleType(\simpleName(""))
	    case double() => simpleType(\simpleName(""))
	    case char() => simpleType(\simpleName(""))
	    case string() => simpleType(\simpleName(""))
	    case byte() => simpleType(\simpleName(""))
	    case \void() => simpleType(\simpleName(""))
	    case \boolean() => simpleType(\simpleName(""))
    
    	//Catch all, no annotations on cleaned trees.
    	case n:node _ => delAnnotations(n)
	}
}

public void clearHashCache(){
	knownDecls = ();
	knownStmnts = ();
}

private Declaration replaceNode(Declaration decl){
	knownDecls[decl@src] = top-down-break visit(decl){
		case \enum(_, i, c, b) => \enum("", i, c, b)
		case \enumConstant(_, a, c) => \enumConstant("", a, c)
		case \enumConstant(_, a) => \enumConstant("", a)
		case \class(_, e, i, b) => \class("", e, i, b)
		case \interface(_, e, i, b) => \interface("", e, i, b)
		case \method(t, _, p, e, i) => \method(t, "", p, e, i)
    	case \method(t, _, p, e) => \method(t, "", p, e)
    	case \constructor(_, p, e, i) => \constructor("",p,e,i)
    	case \import(_) => \import("")
    	case \package(_) => \package("")
    	case \package(_,_) => \package("") //Normalize complex package names to one node.
    	case \typeParameter(_, e) => \typeParameter("", e)
    	case \annotationType(_, b) => \annotationType("", b)
    	case \annotationTypeMember(t, "") => \annotationTypeMember(t,"")
    	case \annotationTypeMember(t, _, e) => \annotationTypeMember(t, "", e)
    	case \parameter(t, _, i) => \parameter(t, "", i)
    	case \vararg(t, _) => \vararg(t, "")
	    	
    	case d:Declaration _ => delAnnotations(d)
	}
	
	return knownDecls[decl@src];
}


private Statement replaceNode(Statement stmnt){
	knownStatements[stmnt@src] = top-down-break visit(stmnt){
		case \break(_) => \break()
		case \continue(_) => \continue()
		case \label(_, s) => \label("", s)
			
		case s:Statement _ => delAnnotations(s)
	}
	
	return knownStatements[stmnt@src];
}

//Basic case:
public test bool normalizeTypeTest1() = normalizeLeaves(qualifiedType(\int(), \null())) == simpleType(\simpleName(""));
//Should be left partially alone:
public test bool normalizeTypeTest2() = normalizeLeaves(arrayType(\int())) == arrayType(simpleType(\simpleName("")));
public test bool normalizeTypeTest3() = normalizeLeaves(parameterizedType(\int())) == parameterizedType(\simpleType(\simpleName("")));
public test bool normalizeTypeTest4() = normalizeLeaves(unionType([\int()])) == unionType([simpleType(\simpleName(""))]);


