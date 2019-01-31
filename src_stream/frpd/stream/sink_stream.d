module frpd.stream.sink_stream;

import frpd.stream.stream : Stream;


class SinkStream(T) : Stream!T {
	//---values
	private T[] buffer = [];
	bool bufferComming = false;
	
	//---metods
	void put(T e) {
		put([e]);
	}
	void put(T[] es) {
		assert(!bufferComming, "Event buffer already given, call push to push current events first.");
		super.onEventsComming();
		super.push(es);
	}
	void bufferPut(T[] es) {
		assert(!bufferComming, "Event buffer already given, call push to push current events first.");
		buffer = es;
		bufferComming = true;
		super.onEventsComming();
	}
	void push() {
		assert(bufferComming, "No event buffer was given, call bufferPut first.");
		super.push(buffer);
		bufferComming = false;
	}
}

SinkStream!T stream(T)() {
	return new SinkStream!T;
}


