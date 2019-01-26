module frpd.cf;

import frpd.cell;
import frpd.add_listener : addListener;
import std.typecons:tuple;

/**	Create a "cell function" from a normal function.
	A cell function is a function that rather than taking values
	takes cells as arguments and will return a cell (changing value) of said calculation.
*/
template cf(alias f) {// TODO: better error reporting is f is not of the right type.
	import std.traits : Parameters, ReturnType;
	import std.meta : staticMap;
	alias F = typeof(f);
	alias Params = Parameters!F;
	alias CellParams = staticMap!(Cell,Params);
	alias ThisCell = Cell!(ReturnType!F);
	
	auto cf (CellParams cellArgs) {
		ThisCell thisCell;
		{
			auto func = new ThisCell.FuncMaker!Params(
				tuple(cellArgs),
				(Params args){
					return f(args);
				}
			);
			thisCell = new ThisCell(func.call);
			thisCell.func = func;
		}
		{
			foreach (cellArg; cellArgs) {
				cellArg.addListener(thisCell);
			}
		}
		return thisCell;
	};
}


unittest {
	import frpd.cell : cell;
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

