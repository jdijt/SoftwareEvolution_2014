module volume

public str ignoreComments(str lines){
	return visit(lines){
	case /\/\*.*?\*\//s=>""				//multi line
	case /\/\/.*/      =>"" 			// single line
	}
}
