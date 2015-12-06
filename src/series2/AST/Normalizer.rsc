module series2::AST::Normalizer

import Node;
import lang::java::m3::AST;


public Declaration normalizeLeaves(Declaration decl){
	return top-down visit(decl){
		case e:Expression _ => normalizeLeaves(e)
		case s:Statement _ => normalizeLeaves(s)
		case t:Type	_ => normalizeLeaves(t)

		//Strip all names from declarations containing those:
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
    	//Catch all, clean 'hashed trees' up.
    	case d:Declaration _ => delAnnotations(d)
	}
}


public Expression normalizeLeaves(Expression exp){
	return top-down visit(exp){
		case t:Type	_ => normalizeLeaves(t)
		
		////Expressions with names in them:
		case \fieldAccess(_, e, _) => \fieldAccess(false, e, "")
		case \fieldAccess(_, _) => \fieldAccess(false, "")
		case \methodCall(_, _, a) => \methodCall(false, "", a)
		case \methodCall(_, _, _, a) => \methodCall(false,"", a)
		case \variable(_, e) => \variable("", e)
		case \variable(_, e, i) => \variable("", e, i)
		
		////Literals, all replaced with the same literal (\null()) (this is why \null is not a case here).
		case \characterLiteral(_) => \null()
		case \number(_) => \null()
		case \booleanLiteral(_) => \null()
		case \stringLiteral(_) => \null()
		
		////Names/identifiers: all replaced with a simpleName("").
		case \qualifiedName(_,_) => \simpleName("")
		case \simpleName(_) => \simpleName("")
		case \this() => \simpleName("")
		case \this(_) => \simpleName("")
		case \super() => \simpleName("")
		
		////Annotations:
		case \markerAnnotation(_) => \markerAnnotation("")
		case \normalAnnotation(_, e) => \normalAnnotation("", e)
		case \singleMemberAnnotation(_, e) => \singleMemberAnnotation("", e)
		case \memberValuePair(_, e) => \memberValuePair("", e)
		
		case e:Expression _ => delAnnotations(e)
	}
}

public Statement normalizeLeaves(Statement st){
	return top-down visit(st){
		case e:Expression _ => normalizeLeaves(e)
		
		case \break(_) => \break()
		case \continue(_) => \continue()
		case \label(_, s) => \label("", s)
		
		case s:Statement _ => delAnnotations(s)
	}
}

public Type normalizeLeaves(Type t){
	return top-down visit(t){
		// Non identifiers (e.g. "this is an array") are left alone.
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
	    
	    case t:Type _ => delAnnotations(t)
	}
}

//Basic case:
public test bool normalizeTypeTest1() = normalizeLeaves(qualifiedType(\int(), \null())) == simpleType(\simpleName(""));
//Should be left partially alone:
public test bool normalizeTypeTest2() = normalizeLeaves(arrayType(\int())) == arrayType(simpleType(\simpleName("")));
public test bool normalizeTypeTest3() = normalizeLeaves(parameterizedType(\int())) == parameterizedType(\simpleType(\simpleName("")));
public test bool normalizeTypeTest4() = normalizeLeaves(unionType([\int()])) == unionType([simpleType(\simpleName(""))]);


