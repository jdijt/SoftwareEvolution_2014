module series2::utils::Util

import Prelude;
import util::Math;

public list[list[&T]] subSequencesR([],_,_) = [[]];
public list[list[&T]] subSequencesR(_,_,0) = [[]];
public list[list[&T]] subSequencesR([a], 1, _) = [[a]];
public list[list[&T]] subSequencesR(list[&T] a, int minimum, int limit){
	if(minimum > limit || size(a) < minimum){
		return [[]];
	} else {
		return for(sSize <- [minimum..min(size(a)+1, limit+1)], startIdx <- [0..(size(a)-sSize)+1]){
			append a[startIdx..startIdx+sSize];
		}
	}
}


public loc combineLocs([]) = |unknown:///|;
public loc combineLocs([a]) = a;
public loc combineLocs(list[loc] l){
	try {
		a = l[0];
		b = l[size(l)-1];
		a.length = (b.offset - a.offset) + b.length;
		a.end = b.end;
		return a;
	}
	catch: return |unknown:///|;
}


public test bool testSubSeqR1(int a, int b) = subSequencesR([],a,b) == [[]];
public test bool testSubSeqR2(list[int] as, b) = subSequencesR(as,b,0) == [[]];
public test bool testSubSeqR3(list[int] inp) = subSequencesR(inp,size(inp+1),0) == [[]];
public test bool testSubSeqR4(list[int] inp, int limit) = subSequencesR(inp, size(inp)+1, limit) == [[]];
public test bool testSubSeqR5() = subSequencesR([1,1,1], 2, 1) == [[]];
public test bool testSubSeqR6(list[int] inp) {
	s = size(inp);
	if(s == 0){
		return subSequencesR(inp,1,2) == [[]];
	} else {
		return size(subSequencesR(inp, s, s)) == 1;
	}
}

public test bool testCombineLocs1() = combineLocs([]) == |unknown:///|;
public test bool testCombineLocs2(loc i) = combineLocs([i]) == i;
public test bool testCombineLocs3(list[loc] inbetween, int offset) {
	a =  |project://series1/src/series2/utils/Util.rsc|(1472,343,<47,0>,<56,1>);
	b = a;
	b.offset = a.offset+abs(offset);
	newLoc = combineLocs([a, *inbetween, b]);
	return newLoc.offset == a.offset
		   && (abs(offset) == 0 || newLoc.length > a.length)
	       && newLoc.path == a.path
	       && newLoc.end == a.end;
}
