module frpd.add_listener;

import std.algorithm;
import frpd.cell : Cell, CellListener;

/**
	Add a CellListener to a cell.
	To get informed of changes.
*/
void addListener(T)(Cell!T cell, CellListener listener) {
	cell.listeners~=listener;
}
/// ditto
void listenTo(T)(CellListener listener, Cell!T cell) {
	addListener(cell, listener);
}
/**
	Remove a CellListener from a cell.
*/
void removeListener(T)(Cell!T cell, CellListener listener) {
	cell.listeners = cell.listeners.remove(cell.listeners.countUntil(listener));
}
/// ditto
void unlistenTo(T)(CellListener listener, Cell!T cell) {
	removeListener(cell, listener);
}


unittest {
	import frpd.settable_cell : cell;
	class B : CellListener {
		bool valueReady = false;
		void onValueReady() {
			valueReady = true;
		}
		void push() {
			valueReady = false;
		}
	}
	{
		auto a = cell(1);
		auto b = new B;
		assert(!b.valueReady);
		a.addListener(b);
		a.value = 2;
		assert(b.valueReady);
		b.valueReady = false;
		a.removeListener(b);
		a.value = 3;
		assert(!b.valueReady);
	}
	{
		auto a = cell(1);
		auto b = new B;
		assert(!b.valueReady);
		b.listenTo(a);
		a.value = 2;
		assert(b.valueReady);
		b.valueReady = false;
		b.unlistenTo(a);
		a.value = 3;
		assert(!b.valueReady);
	}
}

