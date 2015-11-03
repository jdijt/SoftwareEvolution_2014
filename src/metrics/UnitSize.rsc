module metrics::UnitSize

import Map;
import Set;
import IO;
import util::Math;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;


str unitSizesResult(M3 model) {
	sizes = unitSizes(model);
	
	//Some statistics:
	totalSize = (0 | it + sizes[l] | l <- sizes);
	maxSize = (0 | max(it, s) | s <- range(sizes));
	minSize = (maxSize | min(it, s) | s <- range(sizes));
	avgSize = totalSize / size(methods(model));
	
	//Threshold values are not given for unit Size in the SIG paper, using the values from unit Complexity for now.
	lowRiskUnits =      unitsByThreshHolds(sizes, 0, 20);
	mediumRiskUnits =   unitsByThreshHolds(sizes, 21, 50);
	highRiskUnits =     unitsByThreshHolds(sizes, 51, 100);
	veryHighRiskUnits = unitsByThreshHolds(sizes, 101, maxSize);
	
	lowRiskLocPerc =      (0.0 | it + sizes[l] | l <- lowRiskUnits) / totalSize * 100;
	mediumRiskLocPerc =   (0.0 | it + sizes[l] | l <- mediumRiskUnits) / totalSize * 100;
	highRiskLocPerc =     (0.0 | it + sizes[l] | l <- highRiskUnits) / totalSize * 100;
	veryHighRiskLocPerc = (0.0 | it + sizes[l] | l <- veryHighRiskUnits) / totalSize * 100;
		
	
	
	return 
	"Total lloc in Units: <totalSize>
	'Average Unit Size: <avgSize>
	'Largest Unit: <maxSize>
	'Smallest Unit: <minSize>
	'
	'Risk Profile:
	' Very High Risk: <veryHighRiskLocPerc>%
	' High Risk: <highRiskLocPerc>%
	' Medium Risk: <mediumRiskLocPerc>%
	' Low Risk: <lowRiskLocPerc>%
	'
	'Final score: <totalScore( mediumRiskLocPerc, highRiskLocPerc, veryHighRiskLocPerc) >
	'";
}

str totalScore(real medium, real high, real veryHigh){
	if(veryHigh > 5 || high > 15 || medium > 50){
		return "--";
	} else if(veryHigh > 0 || high > 10 || medium > 40){
		return "-";
	} else if( high > 5 || medium > 30 ) {
		return "o";
	} else if( high > 0 || medium > 25 ) {
		return "+";
	} else {
		return "++";
	}
}

map[loc,int] unitsByThreshHolds(map[loc,int] sizes, int lower, int upper) = (l : sizes[l] | l <- sizes, sizes[l] <= upper, sizes[l] >= lower); 

//Match all non whitespace lines.
map[loc,int] unitSizes(M3 model) = ( l : ( 0 | it + 1 | /\n/ := readFile(l)) | l <- methods(model));