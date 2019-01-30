module frpd.cell.settable_cell;

import std.algorithm;
import frpd.cell.cell : Cell, CellListener;

/**	A cell managed/set in non-frp code.
	The most basic entry point of data into the frp tree.
	Simply use the `value` property to set (`settableCell.value = newValue`).
*/
class SettableCell(T) : Cell!T {
	public {
		/// Create with a starting value.
		this(T v) {
			currentValue = v;
		}
		/// Set current value
		@property void value(T v) {
			currentValue = v;
			onValueReady;
		}
		/// Get current value.
		override @property T value() {
			return currentValue;
		}
	}
	private {
		T currentValue;
	}
}
/**	Create a settable cell.
	Takes the starting value.
*/
SettableCell!T cell(T)(T v) {
	return new SettableCell!T(v);
}




unittest {
	{
		SettableCell!int a = cell!int(1);
		auto b = cell(2);
		
		assert(a.value==1);
		assert(b.value==2);
		
		a.value = 3;
		
		assert(a.value==3);
		assert(b.value==2);
	}
	//---test push
	{
		class B : CellListener {
			bool valueReady = false;
			void onValueReady() {
				valueReady = true;
			}
			void push() {
				valueReady = false;
			}
		}
		
		auto a = cell(1);
		B b = new B;
		a.listeners~=b;
		
		a.value = 4;
		assert(b.valueReady);
		a.push;
		assert(!b.valueReady);
	}
}





