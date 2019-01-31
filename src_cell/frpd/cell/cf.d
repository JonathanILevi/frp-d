module frpd.cell.cf;

import std.algorithm;
import frpd.cell.cell;
import frpd.cell._add_listener : addListener,removeListener;
import std.typecons:tuple,Tuple;
import std.traits : Parameters, ReturnType;
import std.meta : staticMap;

/**	Create a "cell function" from a normal function.
	A cell function is a function that rather than taking values
	takes cells as arguments and will return a cell (changing value) of said calculation.
	
	Cell!<ReturnType> cf(<function>)(Cell!<Parameter>...)
*/
template cf(alias f) {// TODO: better error reporting is f is not of the right type.
	private {
		alias F = typeof(f);
		alias T = ReturnType!F;
		alias Params = Parameters!F;
		alias CellParams = staticMap!(Cell,Params);
		
		class FuncCell : Cell!T, CellListener {
			import std.meta : staticMap;
			
			//---Values
			T heldValue;
			bool heldNeedsUpdate;
			Tuple!CellParams cellArgs;	// The Cells from which to extract values from when recalculating.
			T delegate(Params) func;	// The function to call with the extracted values.
			
			//---Constructor
			this(	Tuple!CellParams cellArgs,
				T delegate(Params) func,
			){
				heldNeedsUpdate = true;
				this.cellArgs = cellArgs;
				this.func = func;
				
				cellArgs.each!(i=>i.addListener(this));
			}
			~this() {
				cellArgs.each!(i=>i.removeListener(this));
			}
			
			//---Methods
			/**	Call this "function" to calculate the value.
				I might make opCall an alias for this?
			*/
			override @property T value() {
				if (heldNeedsUpdate) {
					Tuple!(Params) args;
					foreach(i,cellArg; cellArgs) {
						args[i] = cellArg.value;
					}
					heldValue = func(args.expand);
					heldNeedsUpdate = false;
				}
				return heldValue;
			}
			
			//---Listener methods
			override void onValueReady() {
				heldNeedsUpdate = true;
				super.onValueReady;
			}
			override void push() {
				super.push;
			}
			
		}
	}
	Cell!T cf(CellParams cellArgs) {
		return new FuncCell(cellArgs.tuple, (Params args){return f(args);});
	};
}


unittest {
	import frpd.cell.settable_cell : cell;
	int mul(int l, int r) {
		return l*r;
	}
	
	//---
	auto a = cell!int(1);
	auto b = cell(2);
	auto c = cf!mul(a,b);
	{
		import frpd.cell : Cell;
		assert(is(typeof(c)==Cell!int));
	}
	
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

