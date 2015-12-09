module series2::Util

import Prelude;

public list[list[&T]] subSequences([]) = [[]];
public list[list[&T]] subSequences([&T a]) = [[a]]; 
public list[list[&T]] subSequences(list[&T] a){
	return for(sSize <- [size(a)..1], startIdx <- [0..(size(a)-sSize)+1]){
		append a[startIdx..startIdx+sSize];
	}
}

public bool isContainedIn([],_) = true;
public bool isContainedIn([*a],[]) = false;
public bool isContainedIn([*a],[*_,a,*_]) = true;
public bool isContainedIn([*_],[*_]) = false;

public loc combineLocs([]) = |unknown:///|;
public loc combineLocs(list[loc] locs){
	newLoc = locs[0];
	prevEndOffset = newLoc.offset + newLoc.length;
	for(l <- locs){
		endOffset = l.offset+l.length;
		newLoc.length += (endOffset - prevEndOffset);
		newLoc.end = l.end;
		
		prevEndOffset = endOffset;
	}
	return newLoc;
}
