module frpd.implicit.cell;

import frpd.cell : ExplicitCell = Cell ;

class Cell(T) : ExplicitCell!T {
	/**	Implicit casting
	*/
	alias value this; // Implicit cast for the get.
	/// ditto
	final void opAssign(T v) {
		this.value = v;
	}
	/// ditto
	final bool opEquals(T v) {
		return value == v;
	}
	
	///Constructor
	this(T v) {
		super(v);
	}
}

/**	Simple syntax sugar for creating a cell.
*/
Cell!T cell(T)(T v) {
	return new Cell!T(v);
}

/**	Create implicit cell from explicit (explicit to implicit is implicit)
*/
Cell!T implicit(T)(ExplicitCell!T c) {
	return cast(Cell!T)cast(void*)c;
}

// same as for explicit cell
unittest {
	Cell!int a = cell!int(1);
	auto b = cell(2);
	
	assert(!a.heldNeedsUpdate);
	assert(!b.heldNeedsUpdate);
	assert(a.value==1);
	assert(a==1);
	assert(b==2);
	assert(b.value==2);
	
	a = 3;
	
	assert(!a.heldNeedsUpdate);
	assert(!b.heldNeedsUpdate);
	assert(a.value==3);
	assert(b.value==2);
	
	a.listeners~=b;
	
	a = 4;
	
	assert(!a.heldNeedsUpdate);
	assert(b.heldNeedsUpdate);
	assert(a.value==4);
	try {
		b.value;
		assert(0);
	}
	catch(Throwable) {}
}

// mixing implicit and explicit
unittest {
	import frpd.cell : explicitCell = cell;
	ExplicitCell!int a = cell!int(1);
	Cell!int b = cell(2);
	
	assert(!a.heldNeedsUpdate);
	assert(!b.heldNeedsUpdate);
	assert(a.value==1);
	assert(b==2);
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

// switching between
unittest {
	import frpd.cell : explicitCell = cell;
	{
		Cell!int a = cell(5);
		ExplicitCell!int b = a;
		assert(__traits(compiles,a=1));
		assert(!__traits(compiles,b=2));
		
		a = 3;
		assert(b.value==3);
		assert(a==3);
		b.value = 4;
		assert(a==4);
		assert(b.value==4);
	}
	{
		ExplicitCell!int a = explicitCell(5);
		Cell!int b = a.implicit;
		assert(!__traits(compiles,a=1));
		assert(__traits(compiles,b=2));
		
		a.value = 3;
		assert(b==3);
		assert(a.value==3);
		b = 4;
		assert(a.value==4);
		assert(b==4);
	}
}



