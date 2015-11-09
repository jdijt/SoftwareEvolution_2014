module localUtils::LocalUtils

public map[&A, &B <: num] filterValuesByRange(map[&A, &B <: num] vals, &B <: num lower, &B <: num upper) = (k: vals[k] | k <- vals, vals[k] >= lower, vals[k] <= upper);

public &T <: num sumMapValues(map[&A, &T <: num] values) = (0 | it + values[k] | k <- values);