module util::Metric

import List;
import String;
import Relation;
import util::Math;

data Score = sc(int score);

data Metric = simpleMetric(str name, Score score, num val) 
			| unitMetric(str name, Score score, RiskProfile rp)
			| aggMetric(str name, Score score)
			;
			

data RiskProfile = riskProfile(real veryHigh, real high, real medium, real low);

public Score avg([]) = sc(0);
public Score avg([Score s]) = s;
public default Score avg(list[Score] scores) = sc(round(toReal((0 | it + s.score | s <- scores))/size(scores)));

public str formatScore(sc(-2)) = "--";
public str formatScore(sc(-1)) = "-";
public str formatScore(sc(0)) = "o";
public str formatScore(sc(1)) = "+";
public str formatScore(sc(2)) = "++";
public str formatScore(sc(i)) = "unknown score: <i>";

public str formatMetric(simpleMetric(name, score, int val)) = 
	"###### <name>
	'Score: <formatScore(score)>
	'Value: <val>
	'";
public str formatMetric(simpleMetric(name, score, real val)) = 
	"###### <name>
	'Score: <formatScore(score)>
	'Value: <round(val)>%
	'";

public str formatMetric(unitMetric(name, score, rp)) = 
	"###### <name>
	'Score: <formatScore(score)>
	'## Risk Profile:  
	'  <formatRiskProfile(rp)>
	'";
	
public str formatMetric(aggMetric(name, score)) = 
	"###### <name>
	'Score: <formatScore(score)>
	'";
		
public str formatRiskProfile(riskProfile(vh, h, m, l)) =
	"Very High: <round(vh)>%
	'High:      <round(h)>%
	'Medium:    <round(m)>%
	'Low:       <round(l)>%";


public Metric volumeToMetric(int locs){
	if(locs > 1310000){
		return simpleMetric("Volume", sc(-2), locs);
	} else if(locs > 655000){
		return simpleMetric("Volume", sc(-1), locs);
	} else if(locs > 246000){
		return simpleMetric("Volume", sc(0), locs);
	} else if(locs > 66000){
		return simpleMetric("Volume", sc(1), locs);
	} else {
		return simpleMetric("Volume", sc(2), locs);
	}
}

public Metric duplicatelinesToMetric(int dupLocs, int locs){
	dupPerc = toReal(dupLocs)/locs * 100;
	
	if(dupPerc > 20){
		return simpleMetric("Duplication", sc(-2), dupPerc);
	} else if(dupPerc > 10){
		return simpleMetric("Duplication", sc(-1), dupPerc);
	} else if(dupPerc > 5){
		return simpleMetric("Duplication", sc(0), dupPerc);
	} else if(dupPerc > 3){
		return simpleMetric("Duplication", sc(1), dupPerc);
	} else {
		return simpleMetric("Duplication", sc(2), dupPerc);
	}
}

public Metric unitSizesToMetric(rel[loc,int] sizes){
	totalUnitLoc = sum([size | <_,size> <- sizes]);
	
	//Risk profile for sizes:
	sizeRisks = riskProfile(
		toReal(sum([0]+[i | <_,i> <- rangeX(sizes, {n | n <- [0..101]})]))/totalUnitLoc * 100   //very high
		,toReal(sum([0]+[i | <_,i> <- rangeR(sizes, {n | n <- [51..101]})]))/totalUnitLoc * 100 //high
		,toReal(sum([0]+[i | <_,i> <- rangeR(sizes, {n | n <- [21..51]})]))/totalUnitLoc * 100  //medium
		,toReal(sum([0]+[i | <_,i> <- rangeR(sizes, {n | n <- [0..21]})]))/totalUnitLoc * 100   //low
		);
	
	return unitMetric("Unit Size", rpToTotalScore(sizeRisks),sizeRisks);
}

public Metric unitComplexitiesToMetric(rel[loc,int] complexities, rel[loc,int] sizes){
	totalUnitLoc = sum([size | <_,size> <- sizes]);
	
	complexityRisks = riskProfile(
		toReal(sum([0]+[i | <_,i> <- domainR(sizes, domain(rangeX(complexities, {n | n <- [0..51]})))])) / totalUnitLoc * 100   //very high
		,toReal(sum([0]+[i | <_,i> <- domainR(sizes, domain(rangeR(complexities, {n | n <- [21..51]})))])) / totalUnitLoc * 100 //high
		,toReal(sum([0]+[i | <_,i> <- domainR(sizes, domain(rangeR(complexities, {n | n <- [11..21]})))])) / totalUnitLoc * 100 //medium
		,toReal(sum([0]+[i | <_,i> <- domainR(sizes, domain(rangeR(complexities, {n | n <- [1..11]})))])) / totalUnitLoc * 100  //low
		);
		
	
	return unitMetric("Unit Complexity", rpToTotalScore(complexityRisks),complexityRisks);
}

private Score rpToTotalScore(RiskProfile rp){
	if(rp.veryHigh > 5 || rp.high > 15 || rp.medium > 50){
		return sc(-2);
	} else if(rp.veryHigh > 0 || rp.high > 10 || rp.medium > 40){
		return sc(-1);
	} else if( rp.high > 5 || rp.medium > 30 ) {
		return sc(0);
	} else if( rp.high > 0 || rp.medium > 25 ) {
		return sc(1);
	} else {
		return sc(2);
	}
}



//Test functions:

public test bool testAvg1() = avg([]) == sc(0);
public test bool testAvg2() = avg([sc(0)]) == sc(0);
public test bool testAvg3() = avg([sc(i) | i <- [-2,-1,0,1,2]]) == sc(0);

public test bool testFormatSc1() = [formatScore(sc(i)) | i <- [-2,-1,0,1,2]] == ["--","-","o","+","++"];
public test bool testFormatSc2() = formatScore(sc(1337)) == "unknown score: 1337";

//Check basic components of output.
public test bool testFormatMetric1(){
	result = formatMetric(simpleMetric(sc(0),0));
	return startsWith(result, "Score: ") &&  contains(result, "Value: 0");
}
public test bool testFormatMetric2(){
	result = formatMetric(unitMetric(sc(0),riskProfile(0.0,0.0,0.0,0.0)));
	return startsWith(result, "Score: ") &&  contains(result, "## Risk Profile:");
}
//Check for size, rounding and order.
public test bool testFormatRiskProfile(){
	resultLines = split("\n",formatRiskProfile(riskProfile(0.4,1.4,2.4,3.4)));
	
	result = size(resultLines) == 4;
	result = result && resultLines[0] == "Very High: 0%";
	result = result && resultLines[1] == "High:      1%";
	result = result && resultLines[2] == "Medium:    2%";
	result = result && resultLines[3] == "Low:       3%";
	
	return result;
}


public test bool testRpTotal1() = rpToTotalScore(riskProfile(0.0,0.0,25.0,75.0)) == sc(2);

public test bool testRpTotal2() = rpToTotalScore(riskProfile(0.0,0.0,26.0,74.0)) == sc(1);
public test bool testRpTotal3() = rpToTotalScore(riskProfile(0.0,0.1,24.9,75.0)) == sc(1);
public test bool testRpTotal4() = rpToTotalScore(riskProfile(0.0,5.0,30.0,65.0)) == sc(1);

public test bool testRpTotal5() = rpToTotalScore(riskProfile(0.0,5.1,29.9,65.0)) == sc(0);
public test bool testRpTotal6() = rpToTotalScore(riskProfile(0.0,4.0,31.0,65.0)) == sc(0);
public test bool testRpTotal7() = rpToTotalScore(riskProfile(0.0,10.0,40.0,40.0)) == sc(0);

public test bool testRpTotal8() = rpToTotalScore(riskProfile(1.0,9.0,40.0,40.0)) == sc(-1);
public test bool testRpTotal9() = rpToTotalScore(riskProfile(0.0,11.0,39.0,40.0)) == sc(-1);
public test bool testRpTotal10() = rpToTotalScore(riskProfile(0.0,9.0,41.0,40.0)) == sc(-1);
public test bool testRpTotal11() = rpToTotalScore(riskProfile(5.0,15.0,50.0,30.0)) == sc(-1);

public test bool testRpTotal12() = rpToTotalScore(riskProfile(6.0,14.0,50.0,30.0)) == sc(-2);
public test bool testRpTotal13() = rpToTotalScore(riskProfile(4.0,16.0,50.0,30.0)) == sc(-2);
public test bool testRpTotal14() = rpToTotalScore(riskProfile(5.0,14.0,51.0,30.0)) == sc(-2);
