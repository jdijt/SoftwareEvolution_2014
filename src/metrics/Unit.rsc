module metrics::Unit

import List;
import Set;
import Relation;
import util::Math;
import lang::java::m3::Core;
import lang::java::m3::AST;

import metrics::Metric;
import metrics::UnitComplexity;
import metrics::UnitSize;


public tuple[Metric,Metric] unitMetrics(set[Declaration] projectASTs){
	unitASTs = getUnitASTs(projectASTs);
	
	sizes = unitSizes(unitASTs);
	complexities = unitComplexities(unitASTs);
	
	//convert sizes & complexities to count number of units with given size / cc
	totalUnitLoc = sum([size | <_,size> <- sizes]);
	
	//Risk profile for sizes:
	sizeRisks = riskProfile(
		toReal(sum([i | <_,i> <- rangeX(sizes, {n | n <- [0..101]})]))/totalUnitLoc * 100   //very high
		,toReal(sum([i | <_,i> <- rangeR(sizes, {n | n <- [51..101]})]))/totalUnitLoc * 100 //high
		,toReal(sum([i | <_,i> <- rangeR(sizes, {n | n <- [21..51]})]))/totalUnitLoc * 100  //medium
		,toReal(sum([i | <_,i> <- rangeR(sizes, {n | n <- [0..21]})]))/totalUnitLoc * 100   //low
		);
	
	//Risk profile for complexities:
	complexityRisks = riskProfile(
		toReal(sum([i | <_,i> <- domainR(sizes, domain(rangeX(complexities, {n | n <- [0..51]})))])) / totalUnitLoc * 100   //very high
		,toReal(sum([i | <_,i> <- domainR(sizes, domain(rangeR(complexities, {n | n <- [21..51]})))])) / totalUnitLoc * 100 //high
		,toReal(sum([i | <_,i> <- domainR(sizes, domain(rangeR(complexities, {n | n <- [11..21]})))])) / totalUnitLoc * 100 //medium
		,toReal(sum([i | <_,i> <- domainR(sizes, domain(rangeR(complexities, {n | n <- [1..11]})))])) / totalUnitLoc * 100  //low
		);
		
	return <
		unitMetric(rpToTotalScore(sizeRisks), sizeRisks)
		, unitMetric(rpToTotalScore(complexityRisks), complexityRisks)
		>;
}

public rel[loc,Declaration] getUnitASTs(set[Declaration] projectASTs){
	unitASTs = {};
	
	//Only extract methods with an implementation or if they are constructors.
	visit(projectASTs){
		case m: \method(_,_,_,_,_): unitASTs += <m@src, m>;
		case c: \constructor(_,_,_,_): unitASTs += <c@src, c>;
	}
	
	return unitASTs;
}