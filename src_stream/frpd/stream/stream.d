module frpd.stream.stream;

import std.algorithm;


abstract class Stream(T) {
	//---values
	StreamListener!T[] listeners;
	
	//---metods
	void onEventsComming() {
		listeners.each!(l=>l.onEventsComming);
	}
	void push(T[] e) {
		listeners.each!(l=>l.push(e));
	}
}
interface StreamListener(T) {
	void onEventsComming();
	void push(T[]);
}




