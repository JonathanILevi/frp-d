module frpd.add_listener;

import std.algorithm;
import frpd.cell : Cell, CellListener;

/**
	Add a cellListener to a cell.
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
	Remove a cellListener from a cell.
*/
void removeListener(T)(Cell!T cell, CellListener listener) {
	cell.listeners.remove(cell.listeners.countUntil(listener));
}
/// ditto
void stopListeningTo(T)(CellListener listener, Cell!T cell) {
	removeListener(cell, listener);
}


unittest {
	import frpd.implicit.cell : cell;
	{
		auto a = cell(1);
		auto b = cell(2);
		a.addListener(b);
		a.value = 3;
		assert(!a.heldNeedsUpdate);
		assert(b.heldNeedsUpdate);
		b.heldNeedsUpdate = false;
		a.removeListener(b);
		a.value = 4;
		assert(!a.heldNeedsUpdate);
		assert(b.heldNeedsUpdate);
	}
	{
		auto a = cell(1);
		auto b = cell(2);
		b.listenTo(a);
		a.value = 3;
		assert(!a.heldNeedsUpdate);
		assert(b.heldNeedsUpdate);
		b.heldNeedsUpdate = false;
		b.stopListeningTo(a);
		a.value = 4;
		assert(!a.heldNeedsUpdate);
		assert(b.heldNeedsUpdate);
	}
}

