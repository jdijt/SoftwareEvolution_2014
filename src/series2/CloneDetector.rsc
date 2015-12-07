module series2::CloneDetector

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;

import series2::AST::MT;
import series2::AST::Util;
import series2::AST::Normalizer;

//Parameters:
private int weightThreshold = 16; //minimal number of nodes in a tree.

public rel[loc,loc] detectClones(M3 projectModel, set[Declaration] decls){
	treemodel = createTreeModel(projectModel.id, decls);
	buckets = hashTrees(treemodel@subtrees);
	
	treeChildren = treemodel@treecontainment+;
	treeParents = invert(treemodel@treecontainment)+;
	
	return getBasicClones(buckets, treeChildren, treeParents);
}

public rel[loc,loc] getBasicClones(lrel[node,node] buckets, rel[loc,loc] parentToChild, rel[loc,loc] childToParent){
	clones = {};
	
	for(hash <- domain(buckets)){
		<curHead, curTail> = pop(buckets[{hash}]);
		while(size(curTail) > 0){
			for(other <- curTail){
				clones = addNewClone(getSrc(curHead), getSrc(other), clones, parentToChild, childToParent);
			}
			<curHead,curTail> = pop(curTail);
		}
	}
	
	return clones;
}

public rel[loc,loc] addNewClone(loc n1, loc n2, rel[loc,loc] existingClones, rel[loc,loc] parentToChild, rel[loc,loc] childToParent){
	//Is this a subclone of an already known one?
	parentPairs = {<a, b> | a <- childToParent[n1], b <- childToParent[n2]};
	if(size(existingClones & parentPairs) > 0){
		return existingClones;
	}
	
	//Nope: remove subtree clones and an
	childPairs = {<a,b> | a <- parentToChild[n1], b <- parentToChild[n2]};
	childPairs += invert(childPairs);
	
	existingClones -= childPairs;
	existingClones += {<n1,n2>, <n2,n1>};
	
	
	return existingClones;
}


public int size(node t) = ( 0 | it + 1 | /node _ := t);
public lrel[node,node] hashTrees(rel[loc,node] trees) = [<normalizeLeaves(t), t> | <_,t> <- trees, size(t) > weightThreshold];


