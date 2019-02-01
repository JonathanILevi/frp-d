# FRP-D: Functional Reactive Programming Library for D

This library is built from the ground up in order to take full advantage of some of Ds unique features.

# Basic Usage

## Cell Usage

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

## Stream Usage

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

# Contributing

If you have an interest is seeing a good FRP library native in D, join in the fun!  I love colaborating!

If you have questions just ask.
