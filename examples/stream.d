/+dub.sdl:
dependency "frp-d:stream" path=".."
+/

module cell_; // Renamed because `stream` conflicts with function name.

import std.stdio;
import frpd.stream;
import frpd.stream.sink_stream;
import frpd.stream.listener;

void main() {
	auto a = stream!int;
	auto b = stream!int;
	
	auto a3 = a.map!triple;
	auto a3b = join!((int[] l, int[] r)=>l~r)(a3,b);
	
	a3.addListener!((int v){writeln("Event in `a3`: ",v);});
	a3b.addListener!((int v){writeln("Event in `a3b`: ",v);});
	
	writeln("Order of listeners being called from events from the same source is undefined. (More technically, events in the same transaction.");
	a.put(1);
	writeln("--- Transation break.");
	b.put(2);
	writeln("--- Transation break.");
	a.put(5);
	writeln("--- Transation break.");
	a.put(6);
}

int triple(int v) {
	return v*3;
}

