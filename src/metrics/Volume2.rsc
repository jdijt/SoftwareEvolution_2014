module metrics::Volume2

import IO;
import Set;
import String;
import Relation;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::Metric;

data LineAction = 
	delWhole() 
	| delFrom(int colStart)
	| delUpTo(int colEnd)
	| delSegment(int colStart, int colEnd)
	; 

public int countFileLoc(list[str] lines, map[int,set[LineAction]] lineActions){
	line = 1;
	locs = 0;
	
	for(l <- lines){
		if(line in lineActions){
			visit(lineActions[line]){
				case delWhole() : l = "";
				case delFrom(c) : l = l[..c];
				//Fill up space in front / between non comment sections. 
				//To maintain column alignment in case multiple comment sections on one line.
				case delUpTo(c) : l = right(l[(c+1)..], size(l));
				case delSegment(s,e) : l = left(l[..s],size(l[..e+1]))+l[e+1..];
			}
		}
		
		if(trim(l) != ""){ //ignore whitespace-only lines.
			locs += 1;
		}
		line += 1;
	}
	
	return locs;
} 


public map[int,set[LineAction]] getCommentLineActions(set[loc] commentLocs){
	commentLines = {};
	for(l <- commentLocs){
		//Single line;
		if(l.begin.line == l.end.line){
			commentLines += <l.begin.line, delSegment(l.begin.column, l.end.column)>;
		} else { //Multiline:
			commentLines += <l.begin.line, delFrom(l.begin.column)>;
			commentLines += <l.end.line, delUpTo(l.end.column)>;
			commentLines += {<line, delWhole()> | line <- [l.begin.line+1..l.end.line]};
		}
	}
	
	return toMap(commentLines);
}

public int getTotalLoc(M3 project){
	totalLoc = 0;
	containment_T = project@containment+;
	
	for(f <- files(project)){
		totalLoc += countFileLoc(readFileLines(f), getCommentLineActions(project@documentation[f+containment_T[f]]));
	}
	
	return totalLoc;
}

public Metric countProjectLOC2(M3 project){
	locs = getTotalLoc(project);
	
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
