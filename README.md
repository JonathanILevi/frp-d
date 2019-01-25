#FRP-D: Functional Reactive Programming Library for D

This library is build from the ground up in order to take full advantage of some of Ds unique features.

#Basic Usage
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

#Current State and Further

Currently FRP-D only has a `Cell` type.

Often called a "behavior" in other FRP implementations,
the name "cell" was borrowed from Sodium (github.com/SodiumFRP/sodium).

The `Cell` is the most basic type in FRP and you can do a lot with just it.

This library is being developed to cover the full extent of FRP.

I intend to always have a simple sub-module that just contains this core functionality.  Simple cells can have many use cases in code without having to bundle a full FRP library and the simple cell implementation can be a great way to see how this library works internally without wading through a lot of code.

#Contributing

Please, if you have an interest is seeing a good FRP library native in D, join in the fun!  I love colaborating!

I have only just started this project so if you have questions just ask.

I also currently have Trello board for todo: https://trello.com/b/STcPZpQ9/frp-d
