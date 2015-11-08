module metrics::Metric

import util::Math;

data Metric = simpleMetric(str score) | complexMetric(str score, RiskProfile rp);

data RiskProfile = riskProfile(real veryHigh, real high, real medium, real low);


str formatMetric(simpleMetric(score)) = "Score: <score>";
str formatMetric(complexMetric(score,rp)) = "Score: <score>
											'Risk Profile:
											'<formatRiskProfile(rp)>";
											
str formatRiskProfile(riskProfile(vh, h, m, l)) =	"Very High: <round(vh)>%
													'High:      <round(h)>%
													'Medium:    <round(m)>%
													'Low:       <round(l)>%";


str rpToTotalScore(RiskProfile rp){
	if(rp.veryHigh > 5 || rp.high > 15 || rp.medium > 50){
		return "--";
	} else if(rp.veryHigh > 0 || rp.high > 10 || rp.medium > 40){
		return "-";
	} else if( rp.high > 5 || rp.medium > 30 ) {
		return "o";
	} else if( rp.high > 0 || rp.medium > 25 ) {
		return "+";
	} else {
		return "++";
	}
}