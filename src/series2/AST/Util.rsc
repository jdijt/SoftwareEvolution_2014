module series2::AST::Util

import IO;
import lang::java::m3::AST;

public int size(node t) = ( 0 | it + 1 | /node _ := t);


public map[loc,node] getSubTrees(set[node] trees){
	map[loc,node] subtrees = ();
	int skipped = 0;
	
	visit(trees) {
		case d:Declaration _ :{
			try subtrees[d@src] = d;
			catch: skipped += 1; //These tend to be \variables and \package declarations. 
		}
		case s:Statement _ : subtrees[s@src] = s;
		
	};
	
	print("getSubTrees:: Skipped <skipped> subtrees without @src annotation.\n");
	return subtrees;
}