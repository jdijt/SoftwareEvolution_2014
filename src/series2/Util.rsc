module series2::Util

import Prelude;
import util::Math;

public list[list[&T]] subSequencesR([],_,_) = [[]];
public list[list[&T]] subSequencesR(_,0,_) = [[]];
public list[list[&T]] subSequencesR(list[&T] a, 1, _) = [[a]];
public list[list[&T]] subSequencesR(list[&T] a, int minimum, int limit){
	if(minimum > limit || size(a) < minimum){
		return [[]];
	} else {
		return for(sSize <- [minimum..min(size(a)+1, limit+1)], startIdx <- [0..(size(a)-sSize)+1]){
			append a[startIdx..startIdx+sSize];
		}
	}
}

public bool isStrictlyContainedIn([],_) = true;
public bool isStrictlyContainedIn([*a],[]) = false;
public bool isStrictlyContainedIn([*a],[a]) = false;
public bool isStrictlyContainedIn([*a],[*_,a,*_]) = true;
public bool isStrictlyContainedIn([*_],[*_]) = false;


public loc combineLocs([]) = |unknown:///|;
public loc combineLocs([a]) = a;
public loc combineLocs(list[loc] l){
	a = l[0];
	b = l[size(l)-1];
	a.length = (b.offset - a.offset) + b.length;
	a.end = b.end;
	return a;
}
