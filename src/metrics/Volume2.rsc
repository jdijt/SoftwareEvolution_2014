module metrics::Volume2

import List;

public int countFileLOC(map[loc,list[str]] fileLines) = sum([size(fileLines[file]) | file <- fileLines]);
