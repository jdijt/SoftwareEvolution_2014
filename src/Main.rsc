module Main

import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import metrics::Unit;
import metrics::Volume;
import metrics::Volume2;
import metrics::Metric;

list[tuple[str,loc]] projects = [<"smallsql", |project://smallsql0.21_src|>
								,<"hsqldb",   |project://hsqldb-2.3.1|>
								];


public void main() = printMetrics([<p[0], getProjectMetrics(p[1])> | p <- projects]);


public void printMetrics(list[tuple[str,list[tuple[str,Metric]]]] projects){
	for(p <- projects){
		println("
				'########################### Metrics for <p[0]>");
		for(m <-p[1]){
			println("
					'###### <m[0]>:");
			println(formatMetric(m[1]));
		}
	}
}

public list[tuple[str,Metric]] getProjectMetrics(loc project){
	projectModel = createM3FromEclipseProject(project);
	projectASTs = createAstsFromEclipseProject(project, false); //Resolving bindings causes stackoverflows, don't do this ;).
	
	//volume = countProjectLOC(projectModel);
	volume2 = countProjectLOC2(projectModel);
	<unitSize, unitComplexity> = unitMetrics(projectASTs);
	
	return [
		//<"Volume",volume>
		<"Volume",volume2>
		,<"Unit Size",unitSize>
		,<"Unit Complexity",unitComplexity>
		];
} 
