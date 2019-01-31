module frpd.stream.listener;

import std.algorithm;
import frpd.stream._add_listener : listenTo;
import frpd.stream.stream : Stream, StreamListener;

template addListener(alias f){
	private {
		import std.traits : Parameters;
		alias F = typeof(f);
		alias Params = Parameters!F;
		static assert(Params.length==1, "Stream listener can only take argument.");
		alias Param = Params[0];
		
		class Listener : StreamListener!Param {
			//---values
			size_t eventsComming;
			
			//---metods
			void onEventsComming() {}
			void push(Param[] es) {
				es.each!(e=>f(e));
			}
		}
	}
	void addListener(Stream!Param s) {
		auto l = new Listener();
		l.listenTo(s);
	}
}


unittest {
	import frpd.stream.sink_stream : stream;
	
	auto s = stream!int;
	
	int lastEvent = 0;
	s.addListener!((int e){lastEvent=e;});
	
	s.put(1);
	assert(lastEvent==1);
	s.put(2);
	assert(lastEvent==2);
}


