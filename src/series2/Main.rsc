module series2::Main

import Prelude;
import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import series2::utils::File;
import series2::CloneDetector;

public void main(M3 project, set[Declaration] projectASTs){
	cloneClasses = detectClones(project,projectASTs);
	
	codeLines = getCodeLinesPerFile(project);
	clonesToCu = toMap({<locToFile(l),l> | l <- range(cloneClasses)});
	
	fileData = { <fLoc,
				  size(codeLines[fLoc]),
				  size((fLoc in clonesToCu? getLocLines(clonesToCu[fLoc]) : {}) & codeLines[fLoc])>  | fLoc <- codeLines };
	cloneMap = toMap(cloneClasses);
	classSet = {cloneMap[c] | c <- cloneMap}; 
	
	cloneToParent = {<f.parent, f.file, clonelines> | <f,_,clonelines> <- fileData};
	
	//find common prefix:
	testLoc = getOneFrom(cloneToParent)[0];
	while(cloneToParent[testLoc] != {}){
		testLoc = testLoc.parent;
	}
	println(testLoc);
	
	writeFile(|file:///home/jasper/Development/UVA/rascal-workspace/series1/src/visualization/fileLineData.json|,linesPerFileToJSON(fileData));
	writeFile(|file:///home/jasper/Development/UVA/rascal-workspace/series1/src/visualization/fileHierData.json|,clonesToHierarchy(testLoc, cloneToParent));
}


public str linesPerFileToJSON(rel[loc,int,int] fileData){
	return "[<intercalate(",",[fileDataToJSON(f) | f <- fileData])>]";
}
public str fileDataToJSON(<floc,lines,clones>){
	return "{\"FileName\":\"<floc.file>\", \"lines\": <lines>, \"clones\": <clones>}";
}

public str clonesToHierarchy(curDir, parentToClone){
	dirs = [];
	try {
		dirs = [clonesToHierarchy(c, parentToClone) | c <- curDir.ls, !contains(c.file,".")];
		dirs = [s | s <- dirs, !isEmpty(s)];
	}
	catch: dirs = [];
	
	fs = [<name,clones> | <name,clones> <- parentToClone[curDir], clones > 0];
	if(size(fs) > 0 || size(dirs) > 0){
		return "{\"name\": \"<curDir.file>\",
		       '\"children\": [
		       '	<intercalate(",\n", ["{\"name\": \"<name>\", \"size\": <clones>}" | <name,clones> <- fs ])>
		       '	<size(fs) != 0 && size(dirs) > 0? "," : "">
		       '    <intercalate(",\n", [s | s <- dirs, !isEmpty(s)])>
		       ']}";
    } else {
    	return "";
	}
}
