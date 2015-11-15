module metrics::UnitSize

import lang::java::m3::AST;

//Counting statements for unit size.
public rel[loc,int] unitSizes(rel[loc,Declaration] units) = {<l, unitSize(ast)> | <l,ast> <- units};

private int unitSize(Declaration unit) = ( 0 | it + 1 | /Statement _ := unit);


//Some testdata:
private Declaration abstractMethod = \method(\int(), "testMethod", [], []);
private Declaration emptyMethod	   = \method(\int(), "testMethod", [], [], \empty());
private Declaration implMethod1    = \method(\int(), "testMethod", [], [], \block([\empty() | i <- [0..19]]));
private Declaration implMethod2    = \method(\int(), "testMethod", [], [], \block([\expressionStatement(\stringLiteral("Foo")) | i <- [0..19]]));

//some tests for unitSizes:
public test bool testUnitSizes_emptyRel() = unitSizes({}) == {};
public test bool testUnitSizes_nonEmpty() = unitSizes({<|project://foo|,implMethod1>}) == {<|project://foo|,20>};

//Some tests for unitSize:
//Abstract method:
public test bool testUnitSize_noImpl() = unitSize(abstractMethod) == 0;
//Beeing empty is a Statement as well:
public test bool testUnitSize_emptyUnit() = unitSize(emptyMethod) == 1;
//1 \block + 19 \empty():
public test bool testUnitSize_implUnit1() = unitSize(implMethod1) == 20;
//1 \block + 19 \expressionStatement, do we ignore the non Statement items?:
public test bool testUnitSize_implUnit2() = unitSize(implMethod2) == 20;