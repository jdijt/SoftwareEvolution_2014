module Main

import IO;
import metrics::UnitSize;
import metrics::UnitComplexity;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

map[str,loc] projects = ("smallsql" : |project://smallsql0.21_src|
						//,"hsqldb" :   |project://hsqldb-2.3.1| //For now we pretend hsqldb does not exist.
						);

void main(){
	for(p <- projects){
		println("Calculating metrics for <p>");
		metrics = getProjectMetrics(projects[p]);
		for(m <- metrics){
			println("<m>:");
			println("<metrics[m]>\n\n");
		}
	}
}

map[str,str] getProjectMetrics(loc proj){
	projectModel = createM3FromEclipseProject(proj);
	
	//get AST for each method for the method-specific metrics.
	methodASTs = (l : getMethodASTEclipse(l, model = projectModel) | l <- methods(projectModel));
	
	metrics = ("Unit Complexity" : unitComplexityResult(methodASTs)
			  ,"Unit Size":        unitSizesResult(methodASTs)
			  );
	
	return metrics;
}