module series2::Main

import Prelude;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import series2::utils::File;
import series2::CloneDetector;

public void main(M3 project, set[Declaration] projectASTs){
	cloneClasses = detectClones(project,projectASTs);
	
	cleanedFiles = getCleanedProjectFiles(project);
	clonesToCu = toMap({<fileToCompilationUnit(l),l> | l <- range(cloneClasses)});
	
	fileData = { [fLoc,
				  countLoc(cleanedFiles[fLoc]),
				  sum([countLoc(cleanedFiles[fLoc][cLoc.offset..cLoc.offset+cLoc.length])| cLoc <- clonesToCu[fLoc]])] | fLoc <- domain(cleanedFiles)&domain(clonesToCu) };
	cloneMap = toMap(cloneClasses);
	classSet = {cloneMap[c] | c <- cloneMap}; 
				  
	iprintln(fileData);
	iprintln(classSet);
	
}

