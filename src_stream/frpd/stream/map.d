module frpd.stream.map;

import std.algorithm;
import std.algorithm : algorithmMap = map;
import std.range : array;
import frpd.stream.stream : Stream, StreamListener;
import frpd.stream._add_listener;

template map(alias f) {// TODO: better error reporting is f is not of the right type.
	private {
		import std.traits : Parameters, ReturnType;
		alias F = typeof(f);
		alias T = ReturnType!F;
		alias Params = Parameters!F;
		static assert(Params.length==1, "Stream map function must take only one argument.");
		alias Param = Params[0];
		alias StreamParam = Stream!Param;
		
		class MapStream : Stream!T, StreamListener!Param {
			//---Values
			size_t eventsComming;
			StreamParam streamArg;	// The Cells from which to extract values from when recalculating.
			T delegate(Param) func;	// The function to call with the extracted values.
			
			//---Constructor
			this(	StreamParam streamArg,
				T delegate(Param) func,
			){
				eventsComming = true;
				this.streamArg = streamArg;
				this.func = func;
				
				streamArg.addListener(this);
			}
			~this() {
				streamArg.removeListener(this);
			}
			
			//---Methods
			//---Listener methods
			override void onEventsComming() {
				eventsComming = true;
				super.onEventsComming;
			}
			override void push(Param[] es) {
				eventsComming = false;
				super.push(es.algorithmMap!(e=>func(e)).array);
			}
			
		}
	}
	
	Stream!T map (StreamParam s) {
		return new MapStream(s, (Param e){return f(e);});
	};
}


unittest {
	import frpd.stream.sink_stream : stream;
	import frpd.stream.listener;
	int twice(int l) {
		return l*2;
	}
	
	//---
	auto a = stream!int;
	auto b = a.map!((int e)=>twice(e));
	////auto b = a.map!((int e)=>twice(e));
	{
		import frpd.stream.stream : Stream;
		assert(is(typeof(b)==Stream!int));
	}
	
	int lastB = 0;
	b.addListener!((int e){lastB = e;});
	
	assert(lastB==0);
	a.put(1);
	assert(lastB==2);
	a.put(2);
	assert(lastB==4);
	
	//---
	import std.conv : to;
	auto c = b.map!((int v)=>v.to!string);
	
	string lastC = "";
	c.addListener!((string e){lastC = e;});
	
	assert(lastC=="");
	a.put(3);
	assert(lastC=="6");
}



