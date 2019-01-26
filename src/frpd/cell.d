module frpd.cell;

import std.algorithm;
import std.typecons:Tuple;

/**	A cell is the most basic type in FRP.
	A cell is a changing value (named after the cell in a spreadsheet).
	Often called a "behavior" in other FRP implementations,
	the name Cell was borrowed from Sodium (github.com/SodiumFRP/sodium).
*/
class Cell(T) : ListeningCell {
	//---Values
	T heldValue;	// The current value of the cell. (may need updated)
	bool heldNeedsUpdate;	// Whether the `heldValue` is up to date.
	
	Func func;	// This function to call to update the held value.
		// use `func.call` it will return the new value (of type `T`).
	ListeningCell[] listeners;	// The Cells (and later steams) that need to know when I change.
	
	//---Methods
	/**	Called when a value this cell cares about is changed.
	*/
	void onUpdateReady() {
		heldNeedsUpdate = true;
		listeners.each!(l=>l.onUpdateReady());
	}
	
	/**	The constructor.
		v is the starting value of the cell.
	*/
	this(T v) {
		heldValue	= v	;
		heldNeedsUpdate	= false	;
	}
	/**	The smart property methods to get and set `value`.
		These are lazy by default.  The tree will not be updated until a value is needed.
	*/
	@property {
		/**	Get the value, updating it if needed (pulling).
		*/
		T value() {
			if (heldNeedsUpdate) {
				assert(!(func is null), "The impossible happened, please submit a bug report.");
				heldValue = func.call;
				heldNeedsUpdate = false;
			}
			return heldValue;
		}
		/**	Set the value, informing listeners of the change.
			(This is not called pushing, pushing (yet to be implemented) is when the listeners are forcible updated.)
		*/
		void value(T v) {
			assert(func is null, "You cannot set the value of a cell that is defined by a function.");
			heldValue = v;
			heldNeedsUpdate = false;
			listeners.each!(l=>l.onUpdateReady());
		}
	}
	
	//---Inner Types
static:
	/**	The Func is basically a complex function that knows what other cells this cell depends on
		and contains the function to recalculate the value.
		Use func.call to calculate the value.
	*/
	class Func {
		abstract T call();
	}
	///	Template magic! Used internally to create the Func.
	class FuncMaker(Ins...) : Func {
		import std.meta : staticMap;
		private alias CellIns = staticMap!(Cell,Ins);
		
		//---Values
		Tuple!CellIns ins;	// The Cells from which to extract values from when recalculating.
		T delegate(Ins) func;	// The function to call with the extracted values.
		
		//---Constructor
		this(	Tuple!CellIns ins,
			T delegate(Ins) func,
		){
			this.ins = ins;
			this.func = func;
		}
		
		//---Method
		/**	Call this "function" to calculate the value.
			I might make opCall an alias for this?
		*/
		override T call() {
			Tuple!(Ins) args;
			foreach(i,in_; ins) {
				args[i] = in_.value;
			}
			return func(args.expand);
		}
	}
}

/**	Any type of cell must be able to be told when it needs to recalculate its value.
*/
package(frpd)
interface ListeningCell {
	void onUpdateReady();
}

/**	Simple syntax sugar for creating a cell.
*/
Cell!T cell(T)(T v) {
	return new Cell!T(v);
}



unittest {
	Cell!int a = cell!int(1);
	auto b = cell(2);
	
	assert(!a.heldNeedsUpdate);
	assert(!b.heldNeedsUpdate);
	assert(a.value==1);
	assert(b.value==2);
	
	a.value = 3;
	
	assert(!a.heldNeedsUpdate);
	assert(!b.heldNeedsUpdate);
	assert(a.value==3);
	assert(b.value==2);
	
	a.listeners~=b;
	
	a.value = 4;
	
	assert(!a.heldNeedsUpdate);
	assert(b.heldNeedsUpdate);
	assert(a.value==4);
	try {
		b.value;
		assert(0);
	}
	catch(Throwable) {}
}



