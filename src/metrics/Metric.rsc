module metrics::Metric

import List;
import util::Math;

data Score = sc(int score);

data Metric = simpleMetric(Score score, num val) | unitMetric(Score score, RiskProfile rp);

data RiskProfile = riskProfile(real veryHigh, real high, real medium, real low);

public Score avg([]) = sc(0);
public Score avg(list[Score] scores) = sc(round(toReal((0 | it + s.score | s <- scores))/size(scores)));

public str formatScore(sc(-2)) = "--";
public str formatScore(sc(-1)) = "-";
public str formatScore(sc(0)) = "o";
public str formatScore(sc(1)) = "+";
public str formatScore(sc(2)) = "++";
public str formatScore(sc(i)) = "unknown score: <i>";

public str formatMetric(simpleMetric(score, val)) = 
	"Score: <formatScore(score)>
	'Value: <val>";

public str formatMetric(unitMetric(score, rp)) = 
	"Score: <formatScore(score)>
	'<formatRiskProfile(rp)>";
											
public str formatRiskProfile(riskProfile(vh, h, m, l)) =
	"## Risk Profile:    
	'  Very High: <round(vh)>%
	'  High:      <round(h)>%
	'  Medium:    <round(m)>%
	'  Low:       <round(l)>%";


public Score rpToTotalScore(RiskProfile rp){
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