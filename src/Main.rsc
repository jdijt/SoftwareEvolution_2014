module Main

import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::Unit;
import metrics::Volume;
import metrics::Duplicate;
import metrics::Metric;


map[str,loc] projects = ("smallsql" : |project://smallsql0.21_src|
						//,"hsqldb" :   |project://hsqldb-2.3.1| //For now we pretend hsqldb does not exist.
						);

public void main(){
	for(p <- projects){
		println("
				'###########################
				'Calculating metrics for <p>");
		
		metrics = getProjectMetrics(projects[p]);
		for(m <- metrics){
			println("
					'######
					'<m>:");
			println(formatMetric(metrics[m]));
		}
	}
}
private map[str,Metric] getProjectMetrics(loc proj){
	projectModel = createM3FromEclipseProject(proj);
	//get AST for each method for the method-specific metrics.
	methodASTs = (l : getMethodASTEclipse(l, model = projectModel) | l <- methods(projectModel));
	
	metrics = ("Volume" : countProjectLOC(projectModel));
	metrics += unitMetrics(methodASTs);
	
	return metrics;
} 

