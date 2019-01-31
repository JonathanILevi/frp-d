module frpd.stream._accessor;

import std.algorithm;
import frpd.stream.stream : Stream, StreamListener;
import frpd.stream._add_listener;

class Accessor(T) : StreamListener!T {
	bool eventsComming = false;
////	bool eventsReady = false;
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
////		assert(!eventsReady,"The impossible happened, please submit a bug report.");
		eventsComming = true;
		owner.onEventsComming;
	}
	void push(T[] e) {
		assert(eventsComming,"The impossible happened, please submit a bug report.");
////		assert(!eventsReady,"The impossible happened, please submit a bug report.");
		eventsComming = false;
////		eventsReady = true;
		events = e;
		owner.push;
	}
	T[] takeEvents() {
		assert(!eventsComming,"You tried to take events when they are still comming.  Please check `eventsComming` before calling.");
////		assert(eventsReady,"No events ready, please check `eventsReady` before taking events.");
		auto toReturn = events;
		events = [];
////		eventsReady = false;
		return toReturn;
	}
}
interface AccessorOwner {
	void onEventsComming();
	void push();
}
