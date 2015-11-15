module metrics::Duplicate2

import IO;
import List;
import util::Math;

public int getDuplicateLineCount(map[loc,list[str]] fileLines){
	sliceCount = ( () | it + get6LineSlicesInFile(fileLines[file]) | file <- fileLines);
	dupLines = 0;
	
	for(f <- fileLines){
		lines = fileLines[f];
		lastMatch = -1;
		
		for(lineIdx <- [0..size(lines)-5]){
			curSlice = lines[lineIdx..lineIdx+6];
			
			sliceCount[curSlice] += 1;
			
			if(sliceCount[curSlice] > 1){ //we have seen you before mr. Slice..
				//Overlap correction: Reduce number of matched lines if last match less than 6 lines apart from current match.
				dupLines += 6 - max(0, 6 - (lineIdx - lastMatch));		
				lastMatch = lineIdx;
			}
		}
	}
	
	return dupLines;
}


public map[list[str],int] get6LineSlicesInFile(list[str] fileLines) = (fileLines[i..i+6] : 0 | i <- [0..size(fileLines)-5]);