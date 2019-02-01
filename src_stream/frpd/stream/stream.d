module frpd.stream.stream;

import std.algorithm;

/**	The Steam is a stream of events.
	Unlike the cell with is a value that changes the stream does not always have a value.
	Values pulse through it, without keeping the events value around.
	
	Events can be things like a button press on a keyboard or the change of the mouse position.
*/
abstract class Stream(T) {
	//---values
	StreamListener!T[] listeners; // Listeners who need to hear events.
	
	//---metods
	/// Notify listeners that an event is coming so stream can wait for it before continuing execution.
	void onEventsComming() {
		listeners.each!(l=>l.onEventsComming);
	}
	/// Send event sequence to listeners (they must on been informed with onEventsComming first).
	void push(T[] e) {
		listeners.each!(l=>l.push(e));
	}
}
/**	For a class to listen to a stream.
*/
interface StreamListener(T) {
	/// Pass it down the line that an event sequence is coming.N
	void onEventsComming();
	/// Pass event sequence down the line.
	void push(T[]);
}




