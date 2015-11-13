module metrics::Duplicate

import IO;
import Prelude;

list[str] listA = readFileLines(|file:///Users/Carla/workspace/series0/src/fruits.txt|);

public void main(){
	println("###########################");
	duplicateIndex = findDuplicates(listA);
	println("<duplicateIndex>");
	println("###########################");
}	

public int findDuplicates(list[str] listB) {
	int checkedN = size(listB) - 6; 
	int fixedCheckedN = size(listB) - 5;
	int chunk6StartPos = 0;
	int chunk6EndPos = 5;
	int listBStartPos = 0;
	int listBEndPos = 5;
	int duplicate = 0;
	
	while (checkedN > 0) {  	  
	  for (int n <- [0..fixedCheckedN]) {		    	
	  	if (chunk6StartPos == chunk6EndPos) { 
	  		listBStartPos += 1;
	  		listBEndPos += 1;
	  	}
	  	
	  	if (listB[chunk6StartPos..chunk6EndPos] == listB[listBStartPos..listBEndPos]) {
	  		duplicate += 1;
	  	}
	  	  	
	  	listBStartPos += 1;
	    listBEndPos += 1;	  	
	  }
	  
	  chunk6StartPos += 1;
	  chunk6EndPos += 1;
	  listBStartPos = 0;
	  listBEndPos = 5;
	  checkedN -= 1;
	}	
	return duplicate;
	chunk6StartPos =0;
	chunk6EndPos   =0;
	listBStartPos  =0;
	listBEndPos    =0;
	checkedN       =0;
}

