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



public str ignoreComments(str lines){
	return visit(lines){
		case /\/\*.*?\*\//s => "" 		// many comment lines 
		case /\/\/.*/		=> "" 		// comments like this one 
	}
}
public list[str] ignoreEmptyLines(str lines){
	r = split("\n", lines);							//to be sure the file is split in lines
	return [ x | x <- r, x != "", /^\s+$/ !:= x];	
}
public list[str] cleanCode(str lines){
	tmp = ignoreComments(lines);
	return ignoreEmptyLines(tmp);
}

public int countLOC(loc file){					// LOC in files
	file = readFile(file);
	cleanLOC = cleanCode(file);
	return size(cleanLOC);
}
public Metric countProjectLOC(M3 project){
	locs = sum([countLOC(x) | x <- files(project) ]);
	
	if(locs > 1310000){
		return simpleMetric("--");
	} else if(locs > 655000){
		return simpleMetric("-");
	} else if(locs > 246000){
		return simpleMetric("o");
	} else if(locs > 66000){
		return simpleMetric("+");
	} else {
		return simpleMetric("++");
	}
}
