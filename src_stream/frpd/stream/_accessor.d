module frpd.stream._accessor;

import std.algorithm;
import frpd.stream.stream : Stream, StreamListener;
import frpd.stream._add_listener;

/**	Helper for when a node needs to take multiple streams.
	Without this events from different streams are indistinguishable.
*/
class Accessor(T) : StreamListener!T {
	bool eventsComming = false;
	T[] events = [];
	Stream!T source;
	AccessorOwner owner;
	
	this(Stream!T source, AccessorOwner owner) {
		this.source = source;
		this.owner = owner;
		this.listenTo(source);
	}
	~this() {
		this.unlistenTo(source);
	}
	
	void onEventsComming() {
		assert(!eventsComming,"The impossible happened, please submit a bug report.");
		eventsComming = true;
		owner.onEventsComming;
	}
	void push(T[] e) {
		assert(eventsComming,"The impossible happened, please submit a bug report.");
		eventsComming = false;
		events = e;
		owner.push;
	}
	T[] takeEvents() {
		assert(!eventsComming,"You tried to take events when they are still comming.  Please check `eventsComming` before calling.");
		auto toReturn = events;
		events = [];
		return toReturn;
	}
}
/**	For the node which is using accessors.
*/
interface AccessorOwner {
	void onEventsComming();
	void push();
}
