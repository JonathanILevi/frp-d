module frpd.implicit.cf;

import frpd.implicit.cell : implicit;
import frpd.cf : explicitCf = cf;
import frpd.cell : ExplicitCell = Cell ;

/**	Create a "cell function" from a normal function.
	A cell function is a function that rather than taking values
	takes cells as arguments and will return a cell (changing value) of said calculation.
*/
template cf(alias f) {
	import std.traits : Parameters;
	import std.meta : staticMap;
	alias F = typeof(f);
	alias Params = Parameters!F;
	alias CellParams = staticMap!(ExplicitCell,Params);
	auto cf (CellParams cellArgs) {
		return explicitCf!f(cellArgs).implicit;
	};
}


unittest {
	import frpd.implicit.cell : cell;
	int mul(int l, int r) {
		return l*r;
	}
	
	//---
	auto a = cell!int(1);
	auto b = cell(2);
	auto c = cf!mul(a,b);
	
	assert(c.value==2);
	
	a.value = 2;
	assert(c.value==4);
	b.value = 3;
	assert(c.value==6);
	
	//---
	import std.conv : to;
	auto d = cf!((int v)=>v.to!string)(c);
	
	assert(d.value=="6");
	a.value = 12;
	assert(d.value=="36");
	
	//---
	import std.range : repeat;
	import std.array : join;
	auto e = cf!(	(string s, int t) {
			return s.repeat(t).join;
		}
	)(d, b);
	
	assert(e.value=="363636");
	a.value = 1;
	assert(e.value=="333");
}

unittest {
	import frpd.cell : explicitCell = cell;
	import frpd.implicit.cell : Cell;
	int mul(int l, int r) {
		return l*r;
	}
	
	auto a = explicitCell(5);
	auto b = explicitCell(2);
	auto c = cf!mul(a,b);
	
	assert(is(typeof(c)==Cell!int) && !is(typeof(c)==ExplicitCell!int));
}

