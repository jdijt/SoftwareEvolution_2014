module series2::AST::MT

import IO;
import lang::java::m3::AST;

data MT = mt(loc id);

anno rel[loc src, node tree]    MT@subtrees;
anno rel[loc parent, loc child] MT@treecontainment;
anno rel[loc left, loc right]   MT@clones;

public MT emptyMT(loc id){
	model = mt(projectModel.id);

	model@subtrees = {};
	model@treecontainment = {};
	
	return model;
}

public MT createTreeModel(M3 projectModel, Set[Declaration] compunits){
	model = emptyMT(projectModel.id);
	
	for(dec <- compunits){
		compose(model,generateSubTrees(model.Id, dec));
	}
	
	return model;
}


private MT compose(MT original, MT new){
	original@subtrees =        original@subtrees + new@subtrees;
	original@treecontainment = original@treecontainment + new@treecontainment;
}
private MT compose(MT original, MT new1, MT new2) = compose(compose(original, new1), new2);
private MT compose(MT original, MT new1, MT new2, MT new3) = compose(compose(compose(original, new1), new2), new3);
private MT compose(MT original, MT new1, MT new2, MT new3, MT new4) = compose(compose(compose(compose(original, new1), new2), new3), new4);

private MT generateSubTrees(loc parent, Declaration d){
	
}