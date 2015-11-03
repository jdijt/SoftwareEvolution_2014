module Main

import IO;
import metrics::UnitSize;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

map[str,loc] projects = ("smallsql" : |project://smallsql0.21_src|
						//,"hsqldb" :   |project://hsqldb-2.3.1|
						);

void main(){
	for(p <- projects){
		println("Calculating metrics for <p>");
		metrics = getProjectMetrics(projects[p]);
		for(m <- metrics){
			println("<m>:");
			println("<metrics[m]>");
		}
	}
}

map[str,str] getProjectMetrics(loc proj){
	projectModel = createM3FromEclipseProject(proj);
	
	metrics = (
		"Unit Size": unitSizesResult(projectModel)
	);
	
	return metrics;
}