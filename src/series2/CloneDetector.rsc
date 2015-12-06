module series2::CloneDetector


import List;
import ListRelation;
import Node;
import IO;
import lang::java::m3::AST;

import series2::AST::Normalizer;

//Parameters:
int weightThreshold = 5; //minimal number of nodes in a tree.
real similarity = 0.8;

public rel[loc,loc] detectClones(set[Declaration] decls){
	subtrees = getSubTrees(decls);
	buckets = hashTrees(subtrees);
	
	return getBasicClones(buckets, subtrees);
}

public rel[loc,loc] getBasicClones(lrel[node,node] buckets, map[loc,node] subtrees){
	clones = {};
	
	for(hash <- domain(buckets)){
		<curHead, curTail> = pop(buckets[{hash}]);
		while(size(curTail) > 0){
			for(other <- curTail){
				clones = addNewClone(getSrc(curHead), getSrc(other), clones, subtrees);
			}
			<curHead,curTail> = pop(curTail);
		}
	}
	
	return clones;
}

public rel[loc,loc] addNewClone(loc n1, loc n2, rel[loc,loc] existingClones, map[loc,node] subtrees){
	removeTrees = getSubTrees({subtrees[n1]}) + getSubTrees({subtrees[n2]});
	containedClones = {};
	
	for(key <- removeTrees){
		src = getSrc(removeTrees[key]);
		for(other <- existingClones[src]){
			containedClones += <src, other>;
		}
	}
	
	existingClones -= containedClones;
	existingClones += {<n1,n2>, <n2,n1>};
	
	print("Removing: <containedClones>\n");
	print("Adding: <n1>, <n2>\n\n\n");
	
	return existingClones;
}

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

public int size(node t) = ( 0 | it + 1 | /node _ := t);
public loc getSrc(Declaration d) = d@src;
public loc getSrc(Statement s) = s@src;
public lrel[node,node] hashTrees(map[loc,node] trees) = [<normalizeLeaves(trees[n]), trees[n]> | n <- trees, size(trees[n]) > weightThreshold];


