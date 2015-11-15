module util::File

import IO;
import Set;
import String;
import lang::java::m3::Core;

data LineAction = 
	delWhole() 
	| delFrom(int colStart)
	| delUpTo(int colEnd)
	| delSegment(int colStart, int colEnd)
	; 

//Returns a compilationUnit -> lines map for all compilation units.
//Blank lines, trailing/leading whitespace & comments removed.
//Just Code!
public map[loc,list[str]] getCleanedProjectFileLines(M3 project){
	containment_T = project@containment+;
	return (file : getCleanedLinesFromFile(file, project@documentation[file+containment_T[file]]) | file <- files(project));
}

//Turns the location of comments in a file into a set of actions per line.
private list[str] getCleanedLinesFromFile(loc f, set[loc] commentLocs){
	lineActions = getCommentLineActions(commentLocs);
	line = 1;
	
	return for(l <- readFileLines(f)){
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

		l = trim(l);
		if(l != ""){ //ignore empty lines;
			append l;
		}
			
		line += 1;
	}
}
 
private map[int,set[LineAction]] getCommentLineActions(set[loc] commentLocs){
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