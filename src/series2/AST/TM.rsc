module series2::AST::TM

import Prelude;
import lang::java::m3::AST;

import series2::Util;
import series2::AST::Util;
import series2::AST::Normalizer;

data TM = tm(loc id);

anno rel[loc src, node tree]       TM@subtrees;
anno rel[loc src, list[node] seq]  TM@seqtrees;
anno rel[node hash, loc src]	   TM@hashes;
anno rel[list[node] hash, loc src] TM@seqhashes;  
anno rel[loc parent, loc child]    TM@treecontainment;
anno set[loc seq]                  TM@sequences;

public TM emptyTM(loc id){
	model = tm(id);

	model@subtrees = {};
	model@seqtrees = {};
	model@hashes = {};
	model@seqhashes = {};
	model@treecontainment = {};
	model@sequences = {};
	
	return model;
}

//Creates a tree model via breadth first pass over tree.
public TM initTreeModel(loc parent, set[Declaration] ASTs){
	model = createTreeModel(parent, ASTs);
	print("Resolving subsequences.\n");
	model = addSubSequences(model);
	clearHashCache();
	return model;
}

private TM createTreeModel(loc parent, set[value] nodes) = (emptyTM(parent) | compose(it, createTreeModel(parent, n)) | n <- nodes);
private TM createTreeModel(loc parent, list[value] nodes) = (emptyTM(parent) | compose(it, createTreeModel(parent, n)) | n <- nodes);
private TM createTreeModel(loc parent, value n){
	model = emptyTM(parent);
	
	switch(n){
		case d:Declaration _ : {
			decl = toType(d);
			if(decl@src?){
				model@subtrees += {<decl@src, decl>};
				model@hashes += {<normalizeLeaves(decl), decl@src>};
				model@treecontainment += {<parent,decl@src>};
				if(isSequence(decl)){
					model@sequences += decl@src;
				}
				return compose(model, createTreeModel(decl@src, getChildren(decl)));
			} else {
				fail; //Fall trough to node case;
			}
		}
		case s:Statement _ : {
			stmnt = toType(s);
			if(stmnt@src?){
				model@subtrees += {<stmnt@src, stmnt>};
				model@hashes += {<normalizeLeaves(stmnt), stmnt@src>};
				model@treecontainment += {<parent,stmnt@src>};
				if(isSequence(stmnt)){
					model@sequences += stmnt@src;
				}
				return compose(model, createTreeModel(stmnt@src, getChildren(stmnt)));
			} else {
				fail;
			}
		}
		case n:node _ :{
			nod = toType(n);
			return compose(model, createTreeModel(parent, getChildren(nod)));
		}
	}
	
	return model;
}

private TM addSubSequences(TM model){
	locToHashMap = toMapUnique(invert(model@hashes));
	locToSubTree = toMapUnique(model@subtrees);
	
	for(parent <- (model@sequences), seq <- getSequenceChildLocs(toType(locToSubTree[parent]))){
		for(subSeq <- subSequences(seq), size(subSeq) > 1){
			ssLoc = combineLocs(subSeq);
			model@seqtrees += {<ssLoc,[locToSubTree[s] | s <- subSeq]>};
			model@treecontainment += {<parent,ssLoc>};
			model@treecontainment += {<ssLoc,b> | b <- subSeq} + {<ssLoc,combineLocs(bs)> | bs <- subSequences(subSeq), combineLocs(bs) != ssLoc};
			model@seqhashes += <[locToHashMap[s] | s <- subSeq], ssLoc>; 
		}
	}
	
	return model;
}

private TM compose(TM original, TM new){
	original@subtrees += new@subtrees;
	original@hashes += new@hashes;
	original@treecontainment += new@treecontainment;
	original@sequences += new@sequences;
	original@seqhashes += new@seqhashes;
	original@seqtrees += new@seqtrees;
	
	return original;
}
