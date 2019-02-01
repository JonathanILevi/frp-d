module frpd.stream._add_listener;

import std.algorithm;
import frpd.stream.stream : Stream, StreamListener;

/**
	Add a StreamListener to a stream.
	To get informed of changes.
*/
void addListener(T)(Stream!T stream, StreamListener!T listener) {
	stream.listeners~=listener;
}
/// ditto
void listenTo(T)(StreamListener!T listener, Stream!T stream) {
	addListener(stream, listener);
}
/**
	Remove a StreamListener from a stream.
*/
void removeListener(T)(Stream!T stream, StreamListener!T listener) {
	stream.listeners = stream.listeners.remove(stream.listeners.countUntil(listener));
}
/// ditto
void unlistenTo(T)(StreamListener!T listener, Stream!T stream) {
	removeListener(stream, listener);
}


unittest {
	import frpd.stream.sink_stream : stream;
	class B : StreamListener!int {
		bool eventsComming = false;
		int last = 0;
		void onEventsComming() {
			eventsComming = true;
		}
		void push(int[] a) {
			last = a[$-1];
			eventsComming = false;
		}
	}
	{
		auto a = stream!int;
		auto b = new B;
		assert(!b.eventsComming);
		assert(b.last==0);
		a.addListener(b);
		a.bufferPut([1]);
		assert(b.eventsComming);
		assert(b.last==0);
		a.push;
		assert(!b.eventsComming);
		assert(b.last==1);
		a.put(2);
		assert(!b.eventsComming);
		assert(b.last==2);
		a.removeListener(b);
		a.bufferPut([3]);
		assert(!b.eventsComming);
		assert(b.last==2);
		a.push;
		assert(!b.eventsComming);
		assert(b.last==2);
	}
	{
		auto a = stream!int;
		auto b = new B;
		assert(!b.eventsComming);
		assert(b.last==0);
		b.listenTo(a);
		a.bufferPut([1]);
		assert(b.eventsComming);
		assert(b.last==0);
		a.push;
		assert(!b.eventsComming);
		assert(b.last==1);
		a.put(2);
		assert(!b.eventsComming);
		assert(b.last==2);
		b.unlistenTo(a);
		a.bufferPut([3]);
		assert(!b.eventsComming);
		assert(b.last==2);
		a.push;
		assert(!b.eventsComming);
		assert(b.last==2);
	}
}

