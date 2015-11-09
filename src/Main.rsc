module Main

import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import metrics::Unit;
import metrics::Volume;
import metrics::Metric;

map[str,loc] projects = ("smallsql" : |project://smallsql0.21_src|
						,"hsqldb" :   |project://hsqldb-2.3.1|
						);

public void main(){
	for(p <- projects){
		println("
				'########################### Calculating metrics for <p>");
		
		metrics = getProjectMetrics(createM3FromEclipseProject(projects[p]), createAstsFromEclipseProject(project[p]));
		printMetrics(metrics);
	}
}

public void printMetrics(map[str,Metric] metrics){
	for(m <- metrics){
		println("
				'###### <m>:");
		println(formatMetric(metrics[m]));
	}
}

public map[str,Metric] getProjectMetrics(M3 projectModel, set[Declaration] projectASTs){
	
	metrics = ("Volume" : countProjectLOC(projectModel));
	metrics += unitMetrics(projectASTs);
	
	return metrics;
} 
