module series2::AST::TM

import Prelude;
import lang::java::m3::AST;

import series2::cfg;
import series2::Util;
import series2::AST::Util;
import series2::AST::Normalizer;



public list[int] seqLenghts = [];

data TM = tm(loc id);
 
anno rel[loc src, node tree]            	TM@subtrees;
anno rel[node hash, loc src]	         	TM@hashes;
anno rel[loc parent, loc child]          	TM@treecontainment;
anno rel[loc src, lrel[node h, loc l] seq]  TM@seqhashes;

public TM emptyTM(loc id){
	model = tm(id);

	model@subtrees = {};
	model@hashes = {};
	model@treecontainment = {};
	model@seqhashes = {};
	
	return model;
}

//Creates a tree model via breadth first pass over tree.
public TM initTreeModel(loc parent, set[Declaration] ASTs){
	model = createTreeModel(parent, ASTs);
	clearHashCache();
	return model;
}

private TM createTreeModel(loc parent, set[value] nodes) = (emptyTM(parent) | compose(it, createTreeModel(parent, n)) | n <-nodes);
private TM createTreeModel(loc parent, list[value] nodes) = (emptyTM(parent) | compose(it, createTreeModel(parent, n)) | n <- nodes);
private TM createTreeModel(loc parent, node n){
	model = emptyTM(parent);
	
	switch(n){
		case d:Declaration _ : {
			Declaration decl = toDeclaration(d);
			if(decl@src?){
				hash = normalizeLeaves(decl);
				if(treeSize(hash) >= weightThreshold){
					model@subtrees += {<decl@src, decl>};
					model@hashes += {<hash, decl@src>};
					model@treecontainment += {<parent,decl@src>};
					if(isSequence(decl)){
						for( sq <- getSequenceChildren(decl), size(sq) >= minSequenceLength, subsq <- subSequencesR(seq,6,6)){
							model@treecontainment += {<parent,combineLocs(subsq)>};
							model@seqhashes += {<decl@src,[<normalizeLeaves(s), s@src> | s<-subsq]>};
							model@subtrees += {<s@src, s> | s <- subsq};
						}
					}
					return compose(model, createTreeModel(decl@src, getChildren(decl)));
				} else {
					return model;
				}
			} else {
				fail; //Fall trough to node case;
			}
		}
		case s:Statement _ : {
			Statement stmnt = toStatement(s);
			if(stmnt@src?){
				hash = normalizeLeaves(stmnt);
				if(treeSize(hash) >= weightThreshold){
					model@subtrees += {<stmnt@src, stmnt>};
					model@hashes += {<hash, stmnt@src>};
					model@treecontainment += {<parent,stmnt@src>};
					if(isSequence(stmnt)){
						for( sq <- getSequenceChildren(stmnt), size(sq) >= minSequenceLength, subsq <- subSequencesR(seq,6,6)){
							model@treecontainment += {<parent,combineLocs(subsq)>};
							model@seqhashes += {<stmnt@src,[<normalizeLeaves(st), st@src> | st <- subsq]>};
							model@subtrees += {<st@src, st> | st <- subsq};
						}
					}
					return compose(model, createTreeModel(stmnt@src, getChildren(stmnt)));
				} else {
					return model;
				}
			} else {
				fail;
			}
		}
		case n:node _ :{
			nod = toNode(n);
			return compose(model, createTreeModel(parent, getChildren(nod)));
		}
	}
	
	return model;
}
private TM createTreeModel(loc parent, value v) = emptyTM(parent);


private TM compose(TM original, TM new){
	original@subtrees += new@subtrees;
	original@hashes += new@hashes;
	original@treecontainment += new@treecontainment;
	original@seqhashes += new@seqhashes;
	
	return original;
}
