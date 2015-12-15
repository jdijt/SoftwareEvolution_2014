module series2::utils::File

import Prelude;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

data LineAction = 
	delWhole() 
	| delFrom(int colStart)
	| delUpTo(int colEnd)
	| delSegment(int colStart, int colEnd)
	; 

public loc locToFile(loc l) = |file:///| + l.path;

public set[int] getLocLines(set[loc] locs){ 
	result = ({} | it + {i | i <- [l.begin.line..l.end.line+1]} | l <- locs);
	return result;
}

//Returns a compilationUnit -> lines map for all compilation units.
//Just Code!
public map[loc,set[int]] getCodeLinesPerFile(M3 project){
	containment_T = project@containment+;
	return (locToFile(file) : getCodeLinesInFile(file, project@documentation[file+containment_T[file]]) | file <- files(project));
}

public set[int] getCodeLinesInFile(loc f, set[loc] commentLocs){
	lineActions = getCommentLineActions(commentLocs);
	line = 1;
	lines = {};
	
	for(l <- readFileLines(f)){
		if(line in lineActions){
			visit(lineActions[line]){
				case delWhole() : l = right("", size(l)," ");
				//Fill up space in front / behind / between non comment sections. 
				//To maintain loc alignment
				case delFrom(c) : l = left(l[..c],size(l)," ");
				case delUpTo(c) : l = right(l[(c+1)..], size(l));
				case delSegment(s,e) : l = left(l[..s],size(l[..e+1]))+l[e+1..];
			}
		}
		//println(l);
		if(trim(l) != ""){
			lines += {line};
		}
			
		line += 1;
	}
	
	return lines;
}

//Turns the location of comments in a file into a set of actions per line.
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

//Test Code:
public test bool getCLA_empty() = getCommentLineActions({}) == ();
public test bool getCLA_singleline() = getCommentLineActions({|project://series1/src/util/Metric|(0,0,<50,2>,<50,10>)}) == (50:{delSegment(2,10)});
public test bool getCLA_multiline() = getCommentLineActions({|project://series1/src/util/Metric|(0,0,<50,2>,<52,10>)}) == (50:{delFrom(2)}, 51:{delWhole()}, 52:{delUpTo(10)});
 
public test bool fileToCuTest1() = locToFile(|unknown:///|).scheme == "file";
public test bool fileToCuTest2(loc other) = locToFile(other).path == other.path;

public test bool getLocLinesTest(int startline, int diff){
	startline = abs(startline) % 1000;
	diff = max(1,abs(diff) % 1000);
	l = |file://foobar|(0,10,<startline,0>,<startline+diff,0>);
	return getLocLines({l}) == toSet([startline..startline+diff+1]);
}

//Following tests use: |project://testProject| M3.
public test bool testGetCodeLinesPerFile(){
	pr = createM3FromEclipseProject(|project://testProject|);
	return size(getCodeLinesPerFile(pr)) == size(files(pr));
}
public test bool testGetCodeLinesInFile(){
	pr = createM3FromEclipseProject(|project://testProject|);
	//get testClass loc:
	fileLoc = getOneFrom({l | l <- files(pr), l.file == "TestClass.java"});
	codeLines = getCodeLinesInFile(fileLoc, pr@documentation[fileLoc+(pr@containment+)[fileLoc]]);
	return size(codeLines) == 14
		&& size({1,8,14,16,17,18} & codeLines) == 6; //Spot checking
}