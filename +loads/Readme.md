# Loads Surrogates

Namespace incorperating Aeroelastic loads surrogates which adhere to the abstract class ```cast.size.AbstractLaods```

```
classdef (Abstract) AbstractLoads < handle
 methods(Abstract)
 SetConfiguration(obj,opts)
 Lds = GetLoads(obj,Cases)
 end
end
```
`Cases` is a set of Load cases. For the cruise of a locked wing, you can generate an example set of load cases using
```c = LoadCaseFactory.GetCases(ADP);```
Load cases can include manoeuvres, gusts, and turbulence. Each case can have different aircraft configurations (e.g., payload and fuel fractions, hinge locked/free, etc.). We can also vary the safety factor for each load case.

the function `SetConfiguration` shoufl setup analysis methodoligies for a given airarcft configuration, then the function `GetLoads` will be called to estimate the loads along a elastic axis of the wing structure.

`GetLoads` returns an array of `cast.size.Loads` instances which are explained more in a later section, but basicly store the loads on each wing for each load case specified.

The slected loads surrogate can be changed near line 17 of `TAW.StructuralSizing`

## Enforced Lift Dist Surrogate

`loads.EnforcedLiftDist` is a simple Loads surrogate to estimate wing loads given an enforced lift distribution. Given an instance `ld = loads.EnforcedLiftDist(ADP)`, the method `ld.GetLoads(...)` iterates over each load case and passes it the specific methods depending on the type of Loadcase.
- `ld.GroundLoads`: e.g. Loads at the gate
- `ld.GustLoads`: assumed zero
- `ld.TurbLoads`: Turbulence loads, assumed zero
- `ld.StaticLoads`: Manouvre loads, estimated via an enforced lift distribution.

### TODO
- Change lift distribution as a fucntion of manourve load factor
- implement wingtip free lift distribution
- include self weight

## Nastran Surrogate

`loads.NastranModel` can estimate aeroelastic loads via nastran static and dyanmic simualtions using solution sequences *SOL144* (static analysis), *SOL145* (flutter), *SOL146* (transients, gusts + turbulence), *SOL101* ground loads.

Given an instance `ld = loads.NastranModel(ADP)`, the method `ld.SetConfiguration()`
1. updates the baff model for this fuel / payload confiuration
2. converts the baff object into an `ads.fe.Model` object

looking at the property `ld.fe` you'll notice it is a very simialr setup to a baff object. But this one can be serilised into a bdf file for Nastran analysis.

All this relies on the package [ads](https://github.com/DCRG-Bristol/ads). The `ads.fe` namespace defiens the fe model 
https://github.com/DCRG-Bristol/ads/tree/master/tbx/%2Bads/%2Bbaff
The `ads.baff` namespace converts a baff model to an fe model 
https://github.com/DCRG-Bristol/ads/tree/master/tbx/%2Bads/%2Bbaff
The `ads.nast` namespace includes helper functions to run nastran simulation 
https://github.com/DCRG-Bristol/ads/tree/master/tbx/%2Bads/%2Bnast

As with `loads.EnforcedLiftDist`, the method `ld.GetLoads(...)` iterates over each load case and passes it the specific methods depending on the type of Loadcase.
- `ld.GroundLoads`: ground loads (SOL101)
- `ld.GustLoads`: gust Loads of differnt gust length + freqeuncies (SOL146)
- `ld.TurbLoads`: Von Karman Turbulence (SOL146)
- `ld.StaticLoads`: Manouvre loads, 1G cruise loads plus 2.5G and -1G manourves (SOL144)

before running any loads cases `ld.GetLoads(...)` actually calls the method `lg.JigTwistSizing` which adjusts the wing jig twist to achieve a target cruise lift distribtion (at the moment this is assumed to be elliptical)

You don't need to run the full sizing code to run Nastran simulations. `loads.examples.run_sol144` runs a 2.5G manouvre then plots the deformed shape (using the package Matran) and the load distrubtion.

## cast.size.Loads

Load case Loads are stored in teh somewhat esoteric `cast.size.Loads` object. For the `TAW` class it is fist important to understand we size:
1. only one side of the model
2. two/three wings: the connector (centreline to edge of fuselage), the wing (+wingtip if `ADP.HingeEta` <1) 

By running 
```
clear all
load('example_data\UB321_simple.mat')
```
you'll notice the `Lds` object is an array of two `cast.size.Loads` objects. Eash object corresponds to a sized wing `Lds(1)` is teh connecter and `Lds(2)` is the wing. Each object has a series of paramters storing forces and moments (e.g. Lds(1).Fz, Lds(1).My) and indicies (e.g.) `Lds(1).MyIdx`. the forces are stored in an NxM matrix where N is the number of loads cases and M is the number of stations of the baff wing object (e.g. `numel(ADP.Baff.Wing(1).Stations)`). the indicies are in the same format are are the indices of each lods case.

You can condense Lds objects into maximum Loads with teh method `Lds_max = Lds.max()`. Now each force will have the shape 1xN, and the indices correspond to the critical load case at each station.

### Operator overloading
The `cast.size.Loads` makes use of operator overloading to simplify concatinating, summing or multiplying the loads etc...

For example imagine `Lds_1` contains one load case for a wing (e.g. the loads are 1xN) and `Lds_2` contains another load case for a wing:
- `Lds = Lds1 + Lds2;` sums the loads (e.g. final shape 1xN)  
- `Lds_max = Lds1 & Lds2` takes the maximum load at each station (e.g. final shape 1xN) 
- `Lds_concat = Lds1 | Lds2` concatinates the loads (e.g. final shape 2xN)
- `Lds_max = Lds_concat.max()` takes the maximum load at each station (e.g. final shape 1xN) 
- `Lds_min = Lds_concat.min()` takes the minimium load at each station (e.g. final shape 1xN)
- `Lds_max = Lds_concat.abs().max()` takes the maximum absolute load at each station (e.g. final shape 1xN) 
- `Lds = Lds1 * 1.5` multiplies loads by a scaler

