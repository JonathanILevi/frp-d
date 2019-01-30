/+dub.sdl:
dependency "frp-d:cell" path=".."
+/

import std.stdio;
import frpd.cell;
import frpd.cell.settable_cell;

void main() {
	auto a = cell!int(1);
	auto b = cell(2);
	
	auto product = cf!mul(a,b);
	auto currentProduct = mul(a.value,b.value);
	writeln("`product` is a: `Cell!int`");
	writeln("`currentProduct` is a: `int`");
	
	writeln(a.value," * ",b.value," = ",product.value);
	a.value = 2;
	writeln(a.value," * ",b.value," = ",product.value);
	b.value = 3;
	writeln(a.value," * ",b.value," = ",product.value);
	
	writeln("but `currentProduct` never changed: ",currentProduct);
}

int mul(int l, int r) {
	return l*r;
}

