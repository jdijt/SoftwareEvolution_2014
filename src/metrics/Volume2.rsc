module metrics::Volume2

import List;

public int countFileLOC(map[loc,list[str]] fileLines) = sum([0] +[size(fileLines[file]) | file <- fileLines]);


//testcode:
private loc loc1 = |project://series1/src/metrics/Duplicate2.rsc|;
private loc loc2 = |project://series1/src/metrics/UnitSize.rsc|;

public test bool countFileLoc_empty() = countFileLOC(()) == 0;
public test bool countFileLoc_single() = countFileLOC((loc1:["<i>"| i <- [0..20]])) == 20;
public test bool countFileLoc_mult() = countFileLOC((loc1:["<i>"| i <- [0..20]],loc2:["<i>"| i <- [0..20]])) == 40;