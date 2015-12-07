module series2::AST::MT

import Prelude;
import lang::java::m3::AST;

import series2::AST::Util;

data MT = mt(loc id);

anno rel[loc src, node tree]    MT@subtrees;
anno rel[loc parent, loc child] MT@treecontainment;
anno rel[loc left, loc right]   MT@clones;

public MT emptyMT(loc id){
	model = mt(id);

	model@subtrees = {};
	model@treecontainment = {};
	
	return model;
}

//Creates a tree model via breadth first pass over tree.
public MT createTreeModel(loc parent, set[value] nodes) = (emptyMT(parent) | compose(it, createTreeModel(parent, n)) | n <- nodes);
public MT createTreeModel(loc parent, list[value] nodes) = (emptyMT(parent) | compose(it, createTreeModel(parent, n)) | n <- nodes);
public MT createTreeModel(loc parent, value n){
	model = emptyMT(parent);

	top-down-break visit(n){
		case d:Declaration _ : {
			try {
				decl = valueToDecl(d);
						
				model@subtrees += {<decl@src, decl>};
				model@treecontainment += {<parent,decl@src>};
				return compose(model, createTreeModel(decl@src, getChildren(decl)));
			}
			catch: fail; //Fall trough to node case;
		}
		case s:Statement _ : {
			try {
				stmnt = valueToStmnt(s);
				print("Stmnt: <getName(stmnt)>\n");
				
				model@subtrees += {<stmnt@src, stmnt>};
				model@treecontainment += {<parent,stmnt@src>};
				return compose(model, createTreeModel(stmnt@src, getChildren(stmnt)));
			}
			catch: fail; //Fall trough to node case;
		}
		case n:node _ :{
			nod = valueToNode(n);
			print("Other: <getName(nod)>\n");

			return compose(model, createTreeModel(parent, getChildren(nod)));
		}
	}
	
	return model;
}


private MT compose(MT original, MT new){
	original@subtrees += new@subtrees;
	original@treecontainment += new@treecontainment;
	
	return original;
}
