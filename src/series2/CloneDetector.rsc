module series2::CloneDetector

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;

import series2::Util;
import series2::AST::TM;
import series2::AST::Util;
import series2::AST::Normalizer;

//Parameters:
private int weightThreshold = 10; //minimal number of nodes in a tree.

public rel[loc,loc] detectClones(M3 projectModel, set[Declaration] decls){
	print("Parsing trees...\n");
	treemodel = initTreeModel(projectModel.id, decls);
	print("Generated <size(treemodel@subtrees)> subtrees.\n");
	
	return detectClones(treemodel);
}
	
public rel[loc,loc] detectClones(TM treemodel){
	print("Creating buckets...\n");
	filteredHashes = {h | h <- domain(treemodel@hashes), size(h) >= weightThreshold};
	filteredBuckets = domainR(treemodel@hashes, filteredHashes);
	print("<size(range(filteredBuckets))> subtrees split over <size(domain(filteredBuckets))> buckets after filtering.\n");
	
	treeChildren = treemodel@treecontainment+;
	treeParents = invert(treemodel@treecontainment)+;
	
	print("Finding Clones...\n");
	clones = getBasicClones(filteredBuckets, treeChildren, treeParents);
	print("Found <size(clones)> clones before merging sequences.");
	
	print("Merging sequences...\n");
	clones = getSequenceClones(clones, treemodel, treeChildren, treeParents);
	print("Reduced number of clones to: <size(clones)>\n");
	
	return clones;
}

public rel[loc,loc] getBasicClones(rel[node,loc] buckets, rel[loc,loc] parentToChild, rel[loc,loc] childToParent){
	clones = {};
	
	for(hash <- domain(buckets)){
		<curHead, curTail> = takeOneFrom(buckets[hash]);
		while(size(curTail) > 0){
			for(other <- curTail){
				clones = addNewClone(curHead, other, clones, parentToChild, childToParent);
			}
			<curHead,curTail> = takeOneFrom(curTail);
		}
	}
	
	return clones;
}

public rel[loc,loc] getSequenceClones(rel[loc,loc] clones, TM treemodel, rel[loc,loc] parentToChild, rel[loc,loc] childToParent){
	
	for(hash <- domain(treemodel@seqhashes)){
		<curHead,curTail> = takeOneFrom(treemodel@seqhashes[hash]);
		
		while(size(curTail) > 0){
			for(other <- curTail){
				clones = clones = addNewClone(curHead, other, clones, parentToChild, childToParent);
			}
			<curHead,curTail> = takeOneFrom(curTail);
		}
	}
	
	return clones;
}

public rel[loc,loc] addNewClone(loc n1, loc n2, rel[loc,loc] existingClones, rel[loc,loc] parentToChild, rel[loc,loc] childToParent){
	//Is this a subclone of an already known one?
	n1Parents = childToParent[n1];
	n2Parents = childToParent[n2];
	if((0 | it + 1 |  b <- existingClones[n1Parents], b in n2Parents) > 0){
		return existingClones;
	}
	
	//Nope: remove subtree clones and add
	childPairs = ({} | it + {<a,b>,<b,a>} | <a,b> <- domainR(existingClones, parentToChild[n1]), b in parentToChild[n2]);
	existingClones -= childPairs;
	existingClones += {<n1,n2>, <n2,n1>};
	
	return existingClones;
}