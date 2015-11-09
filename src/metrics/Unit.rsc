module metrics::Unit

import List;
import Map;
import util::Math;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;

import metrics::Metric;
import metrics::UnitComplexity;
import metrics::UnitSize;
import localUtils::LocalUtils;


public map[str, Metric] unitMetrics(set[Declaration] projectASTs){
	unitASTs = getUnitASTs(projectASTs);
	skipped = 0;
	
	sizes = unitSizes(unitASTs);
	complexities = unitComplexities(unitASTs);
	
	//Used as upper bounds for filterByRange.
	totalUnitLoc = (0 | it + sizes[n] | n <- sizes);
	totalComplexity = (0 | it + complexities[n] | n <- complexities);
	
	//Risk profile for sizes:
	sizeRisks = riskProfile(
		toReal(sumMapValues(filterValuesByRange(sizes, 101,totalUnitLoc)))/totalUnitLoc * 100  //very high
		,toReal(sumMapValues(filterValuesByRange(sizes, 51,100)))/totalUnitLoc * 100           //high
		,toReal(sumMapValues(filterValuesByRange(sizes, 21,50)))/totalUnitLoc * 100            //medium
		,toReal(sumMapValues(filterValuesByRange(sizes, 0,20)))/totalUnitLoc * 100             //low
		);
	
	//Risk profile for complexities:
	complexityRisks = riskProfile(
		toReal((0 | it + sizes[l] | l <- filterValuesByRange(complexities, 51,totalComplexity)))/totalUnitLoc * 100 //very high
		,toReal((0 | it + sizes[l] | l <- filterValuesByRange(complexities, 21,50)))/totalUnitLoc * 100             //high
		,toReal((0 | it + sizes[l] | l <- filterValuesByRange(complexities, 11,20)))/totalUnitLoc * 100             //medium
		,toReal((0 | it + sizes[l] | l <- filterValuesByRange(complexities, 0,10)))/totalUnitLoc * 100              //low
		);
		
	return (
		"Unit Size" : unitMetric(rpToTotalScore(sizeRisks), skipped, sizeRisks)
		,"Unit Complexity" : unitMetric(rpToTotalScore(complexityRisks), skipped, complexityRisks)
		);
}

public map[loc,Declaration] getUnitASTs(set[Declaration] projectASTs){
	unitASTs = ();
	
	//Only extract methods with an implementation or if they are constructors.
	visit(projectASTs){
		case m: \method(_,_,_,_,_): unitASTs[m@src] = m;
		case c: \constructor(_,_,_,_): unitASTs[c@src] = c;
	}
	
	return unitASTs;
}