module Main

import IO;
import metrics::Volume;
import metrics::Duplicate;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

map[str,loc] projects = ("smallsql" : |project://smallsql0.21_src|);
