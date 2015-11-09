module metrics::Volume

import IO;
import List;
import Set;
import String;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::Metric;
//Lines of code LOC
//Man years  MY

private str ignoreBlockComments(str lines){
	return innermost visit(lines){
		case /\/\*.*?\*\//s => "" 		// many comment lines 
	}
}

private str ignoreSingleLineComment(/^<code:.*>\/\/.*?$/) = code;
private default str ignoreSingleLineComment(str input) = input;

private list[str] ignoreEmptyLines(list[str] lines) = [ x | x <- lines, x != "", /^\s+$/ !:= x];	


private list[str] cleanCode(str lines){
	tmp = ignoreBlockComments(lines);
	return ignoreEmptyLines([ignoreSingleLineComment(l) | l <- split("\n", tmp)]);
}

private int countLOC(loc file){					// LOC in files
	file = readFile(file);
	cleanLines = cleanCode(file);
	return size(cleanLines);
}

public Metric countProjectLOC(M3 project){
	locs = sum([countLOC(x) | x <- files(project) ]);
	
	if(locs > 1310000){
		return simpleMetric(sc(-2), locs);
	} else if(locs > 655000){
		return simpleMetric(sc(-1), locs);
	} else if(locs > 246000){
		return simpleMetric(sc(0), locs);
	} else if(locs > 66000){
		return simpleMetric(sc(1), locs);
	} else {
		return simpleMetric(sc(2), locs);
	}
}
