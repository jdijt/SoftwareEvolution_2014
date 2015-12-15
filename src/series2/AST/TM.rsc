module series2::AST::TM

import Prelude;
import lang::java::m3::AST;

import series2::cfg;
import series2::utils::Util;
import series2::AST::Util;
import series2::AST::Normalizer;



public list[int] seqLenghts = [];

data TM = tm(loc id);
 
anno rel[loc src, node tree]            	       TM@subtrees;
anno rel[node hash, loc src]	         	       TM@hashes;
anno rel[loc parent, loc child]          	       TM@treecontainment;
anno rel[loc src, tuple[list[node] h, list[loc] l] sseq] TM@seqhashes;

public TM emptyTM(loc id){
	model = tm(id);

	model@subtrees = {};
	model@hashes = {};
	model@treecontainment = {};
	model@seqhashes = {};
	
	return model;
}

//Creates a tree model via depth first pass over tree.
public TM initTreeModel(loc parent, set[Declaration] ASTs){
	model = createTreeModel(parent, ASTs);
	clearHashCache();
	return model;
}

private TM createTreeModel(loc parent, set[&T] nodes) = (emptyTM(parent) | compose(it, createTreeModel(parent, n)) | n <-nodes);
private TM createTreeModel(loc parent, list[&T] nodes) = (emptyTM(parent) | compose(it, createTreeModel(parent, n)) | n <- nodes);
private TM createTreeModel(loc parent, &T<:node n){
	model = emptyTM(parent);
	
	switch(n){
		case d:Declaration _ : {
			Declaration decl = toDeclaration(d);
			if(decl@src?){
				return compose(addSubTreeToModel(model, parent, decl@src, decl), createTreeModel(decl@src,getChildren(decl)));
			} else {
				fail; //Fall trough to node case;
			}
		}
		case s:Statement _ : {
			Statement stmnt = toStatement(s);
			if(stmnt@src?){
				return compose(addSubTreeToModel(model, parent, stmnt@src, stmnt), createTreeModel(stmnt@src, getChildren(stmnt)));
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

private TM addSubTreeToModel(TM model, loc parent, loc treeSrc, &T <: node subTree){
	hash = normalizeLeaves(subTree);
	tSize = treeSize(hash);
	if(tSize >= weightThreshold){
		model@subtrees += {<treeSrc, subTree>};
		model@hashes += {<hash, treeSrc>};
		model@treecontainment += {<parent,treeSrc>};
		if(isSequence(subTree)){
			model = addSequenceToModel(model, parent, treeSrc, subTree);
		}	
	}
	return model;
}

private TM addSequenceToModel(TM model, loc parent, loc treeSrc, &T <:node subTree){ 
	for(sq <- getSequenceChildren(subTree)
		, size(sq) >= minSequenceLength
		, treeSize(sq) >= minSequenceLength * weightThreshold
		, subsq <- subSequencesR(sq,minSequenceLength,minSequenceLength)){
		seqLoc = combineLocs([st@src | st<-subsq]);
		model@treecontainment += {<parent,seqLoc>};
		model@seqhashes += {<treeSrc,<[normalizeLeaves(s)|s<-subsq], [s@src | s <- subsq]>>};
		model@subtrees += {<s@src, s> | s <- subsq};
	}
	return model;	
}

private TM compose(TM original, TM new){
	original@subtrees += new@subtrees;
	original@hashes += new@hashes;
	original@treecontainment += new@treecontainment;
	original@seqhashes += new@seqhashes;
	
	return original;
}

public test bool testEmptyTMAnnotations(){
	//Check if all annotations initialized to empty set/list/wtvr:
	m = emptyTM(|unknown:///|);
	for(a <- range(getAnnotations(m))){
		if(a != {}){
			return false;
		}
	}
	return true;
}
public test bool testEmptyTMId(loc id) = emptyTM(id).id == id;

public test bool testComposeOwn(loc l, rel[loc,Statement] st, rel[Statement,loc] h, rel[loc,loc] tc, rel[loc,tuple[list[node],list[loc]]] sh){
	m = emptyTM(l);
	m@subtrees = st;
	m@hashes = h;
	m@treecontainment = tc;
	m@seqhashes = sh;
	
	return m == compose(m,m);
} 
public test bool testComposeOrigLoc(loc a, loc b) = compose(emptyTM(a),emptyTM(b)).id == a;

public test bool testAddSequenceToModel(loc parent, loc treeSrc, list[Statement] seq){
	parentStmnt = \block(seq);
	//Set config to friendly for easyer testing:
	om = emptyTM(parent);
	m = addSequenceToModel(om, parent, treeSrc, parentStmnt);
	//Check adding:
	result = size(m@treecontainment) >= size(om@treecontainment);
	result = result && size(m@seqhashes) >= size(om@seqhashes);
	result = result && size(m@subtrees) >= size(om@subtrees);
	
	return result;
}

public test bool testAddSubTreeToModel(loc parent, loc treeSrc, Statement tree){
	om = emptyTM(parent);
	m = addSubTreeToModel(om, parent, treeSrc, tree);
		
	result = size(m@subtrees) >= size(om@subtrees);
	result = result && size(m@hashes) >= size(om@hashes);
	result = result && size(m@treecontainment) >= size(om@treecontainment);	

	return result;
}