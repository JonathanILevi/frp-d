/+dub.sdl:
dependency "frp-d" path=".."
+/

import std.stdio;
import frpd;

void main() {
	auto a = cell!int(1);
	auto b = cell(2);
	
	auto product = cf!mul(a,b);
	auto currentProduct = mul(a,b);
	
	writeln(a," * ",b," = ",product);
	a = 2;
	writeln(a," * ",b," = ",product);
	b = 3;
	writeln(a," * ",b," = ",product);
	
	writeln("but `currentProduct` never changed: ",currentProduct);
}

int mul(int l, int r) {
	return l*r;
}

