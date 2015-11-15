module metrics::Duplicate2

import IO;
import List;
import util::Math;

public int getDuplicateLineCount(map[loc,list[str]] fileLines){
	sliceCount = ( () | it + get6LineSlicesInFile(fileLines[file]) | file <- fileLines);
	dupLines = 0;
	
	for(f <- fileLines){
		lines = fileLines[f];
		lineCount = size(lines);
		lastMatch = -1;
		
		if(lineCount < 6){
			continue;
		}
		
		for(lineIdx <- [0..lineCount-5]){
			curSlice = lines[lineIdx..lineIdx+6];
			
			sliceCount[curSlice] += 1;
			
			if(sliceCount[curSlice] > 1){ //we have seen you before mr. Slice..
				//Overlap correction: Reduce number of matched lines if last match less than 6 lines apart from current match.
				overlap = 0;
				if(lastMatch > -1){
					overlap = max(0, 6 - (lineIdx - lastMatch));
				}
				dupLines += 6 - overlap; 		
				lastMatch = lineIdx;
			}
		}
	}
	
	return dupLines;
}

public map[list[str],int] get6LineSlicesInFile(list[str] fileLines){
	if(size(fileLines) < 6){
		return ();
	} else {
		return (fileLines[i..i+6] : 0 | i <- [0..size(fileLines)-5]);
	}
}
//TestCode
public test bool getSlicesTest_empty() = get6LineSlicesInFile([]) == ();
public test bool getSlicesTest_5lines() = get6LineSlicesInFile(["1","2","3","4","5"]) == ();
public test bool getSlicesTest_6lines() = get6LineSlicesInFile(["1","2","3","4","5","6"]) == (["1","2","3","4","5","6"]:0);
public test bool getSlicesTest_7lines() = get6LineSlicesInFile(["1","2","3","4","5","6","7"]) == (["1","2","3","4","5","6"]:0,["2","3","4","5","6","7"]:0);

//Testdata for dupLineCount:
private loc loc1 = |project://series1/src/metrics/Duplicate2.rsc|;
private loc loc2 = |project://series1/src/metrics/UnitSize.rsc|;
private list[str] file1 = ["1","2","3","4","5","6","7"];
private list[str] file2 = ["a","b","c","d","e","f","g"];

public test bool getDuplicateLineCount_empty() = getDuplicateLineCount(()) == 0;
public test bool getDuplicateLineCount_eqFiles() = getDuplicateLineCount((loc1:file1, loc2:file1)) == 7;
public test bool getDuplicateLineCount_neqFiles() = getDuplicateLineCount((loc1:file1, loc2:file2)) == 0;
public test bool getDuplicateLineCount_dupInFile() = getDuplicateLineCount((loc1:file1+file2+file1)) == 7;