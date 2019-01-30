module frpd.cell.cell;

import std.algorithm;

/**	A cell is the most basic type in FRP.
	A cell is a changing value (named after the cell in a spreadsheet).
	Often called a "behavior" in other FRP implementations,
	the name "cell" was borrowed from Sodium (github.com/SodiumFRP/sodium).
	
	This is the face of a cell.
	For managing access to the value contained within.
	For getting the value or pushing or pulling calculation of the value.
	Not how the value is actually calculated.
	
	The settable cell is a cell where the value is set/managed in non-frp code.
	A cell func (created with `cf`) creates a type of cell who's
	value comes from a calculation with other cells.
*/
abstract class Cell(T) {
	//---values
	CellListener[] listeners = []; // Listeners who needs to know of changes.
	//---methods
	/// Get the value currently within this cell (calculating it if needing) (lazy by default).
	abstract @property T value();
	/// Force this value to be calulated now.  (and consequently those that this cell depends on)
	void pull() {
		value;
	}
	/// Force calculation related to this cell to happen now.  (update this cell's value, those this cell depends on, and those that depend on this cell)
	void push() {
		pull;
		listeners.each!(l=>l.push); // Pass on to listeners.
	}
	/// Pass on down the line that the currently calculated value is no longer valid.
	void onValueReady() {
		listeners.each!(l=>l.onValueReady); // Pass on to listeners.
	}
}
/**	For any object that wants to listen to the changes of a cell.
*/
interface CellListener {
	/// Pass on down the line that the currently calculated value is no longer valid.
	void onValueReady();
	/// Request calculation of value to be done now (eagerly).
	void push();
}






