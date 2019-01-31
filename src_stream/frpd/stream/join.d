module frpd.stream.join;

import frpd.stream.stream : Stream, StreamListener;
import frpd.stream._accessor : Accessor, AccessorOwner;
import std.typecons:tuple,Tuple;
import std.traits : Parameters, ReturnType, ForeachType;
import std.meta : staticMap;

template join(alias f) {// TODO: better error reporting is f is not of the right type.
	private {
		alias F = typeof(f);
		alias T = ForeachType!(ReturnType!F);
		alias ArrayParams = Parameters!F;
		alias Params = staticMap!(ForeachType,ArrayParams);
		static assert(Params.length>1, "Stream join function must 2 or more arguments.  Use map for 1 argument.");
		alias StreamParams = staticMap!(Stream,Params);
		
		class JoinStream : Stream!T, AccessorOwner {
			//---Values
			Tuple!(staticMap!(Accessor,Params)) accessorArgs;	// The Cells from which to extract values from when recalculating.
			T[] delegate(ArrayParams) func;	// The function to call with the extracted values.
			
			//---Constructor
			this(	Tuple!StreamParams streamArgs,
				T[] delegate(ArrayParams) func,
			){
				foreach (i,arg;streamArgs) {
					accessorArgs[i] = new Accessor!(Params[i])(arg, this);
				}
				this.func = func;
			}
			~this() {
				foreach (a;accessorArgs) {
					destroy(a);
				}
			}
			
			//---Methods
			//---Listener methods
			override void onEventsComming() {
				super.onEventsComming;
			}
			override void push() {
				bool ready = true;
				foreach(a; accessorArgs) {
					if (a.eventsComming)
						ready = false;
				}
				if (ready) {
					Tuple!ArrayParams args;
					foreach(i,accessor;accessorArgs) {
						args[i] = accessor.takeEvents;
					}
					super.push(func(args.expand));
				}
			}
			
		}
		
		template Array(T) {
			alias Array = T[];
		}
	}
	
	Stream!T join (StreamParams s) {
		return new JoinStream(s.tuple, (ArrayParams es){return f(es);});
	};
}


unittest {
	import frpd.stream.sink_stream : stream;
	import frpd.stream.listener;
	
	//---
	auto a = stream!int;
	auto b = stream!int;
	alias joiner = join!((int[] eas, int[] ebs)=>eas~ebs);
	auto c = joiner(a,b);
	////auto b = a.map!((int e)=>twice(e));
	{
		import frpd.stream.stream : Stream;
		assert(is(typeof(c)==Stream!int));
	}
	
	int[] cs = [];
	c.addListener!((int e){cs~=e;});
	
	assert(cs==[]);
	a.put(1);
	assert(cs==[1]);
	b.put(2);
	assert(cs==[1,2]);
	b.bufferPut(4);
	a.bufferPut(3);
	b.push;
	a.push;
	assert(cs==[1,2,3,4]);
}



