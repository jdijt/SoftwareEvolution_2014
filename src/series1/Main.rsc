module series1::Main

import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import series1::util::File;
import series1::util::AST;
import series1::util::Metric;
import series1::metrics::Volume2;
import series1::metrics::UnitSize;
import series1::metrics::UnitComplexity;
import series1::metrics::Duplicate2;



public void main(M3 project){
	<vol,uSize,uComp,dup> = getCodeMetrics(project);
	analys = aggMetric("Analysability", avg([vol.score, dup.score, uSize.score]));
	change = aggMetric("Changeability", avg([uComp.score, dup.score]));
	testab = aggMetric("Testability", avg([uComp.score, uSize.score]));
	maint =  aggMetric("Maintainability", avg([analys.score, change.score, testab.score]));
	
	printMetrics([vol,uSize,uComp,dup,analys,change,testab,maint]);
}


public void printMetrics(list[Metric] metrics){
	println("########################### Metrics:");
	for(m <- metrics){
		println(formatMetric(m));
	}
}

public tuple[Metric, Metric, Metric, Metric] getCodeMetrics(M3 projectModel){
	projectASTs = createAstsFromEclipseProject(projectModel.id, false); //Resolving bindings causes stackoverflows, don't do this ;).
	
	projectFiles = getCleanedProjectFileLines(projectModel);
	unitASTs = getUnitASTs(projectASTs);
	
	volume = countFileLOC(projectFiles);
	sizes = unitSizes(unitASTs);
	complexities = unitComplexities(unitASTs);
	duplicateLines = getDuplicateLineCount(projectFiles);


	//Now, for scores:
	return 
		<volumeToMetric(volume)
		,unitSizesToMetric(sizes)
		,unitComplexitiesToMetric(complexities, sizes)
		,duplicatelinesToMetric(duplicateLines,volume)
		>;
} 

