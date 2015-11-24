OSM-PathFinder
==============
_Nicolas Tortrat--Gentilhomme_ / _Nicolas Raymond, 2014/2015_

![Preview](/images/Preview.jpg)


##About the software

The OpenStreetMap PathFinder allows you to compute itinerary for pedestrians, bycicles and
motorized vehicules on maps from OpenStreetMap.

It can extract data from OSM files and display the path you requested in two formats :
 - A graphical and visual format stored in a jpeg file.
 - A textual format that gives you a roadmap discribing your itinerary.

This project is a study work realized in team at _University Paris Diderot, Paris 7_.


##How to compile it

OSM-PathFinder at least needs the `4.02.0` version of OCaml and uses different packages :
 - xml-light
 - camlimages 
 - ocamlbuild

The easiest way to install them is to use the OPAM package manager.

####Install OPAM
######On linux systems
```
$ sudo apt-get install opam
```
######On OSX
Use [homebrew](http://brew.sh/).
```
$ brew install opam
```

####Install OCaml
```
$ opam install ocaml
```

####Install packages
```
$ opam install ocamlbuild camlimages xml-light
```

####Compile the project
A simple ` make ` in the root of the project  will produce the runable `osm_pathfinder`

####Generate documentation
A ` make doc ` will generate an ocamldoc documentation in the `doc` subdirectory.


## How to use it

####Basics
To compute an itinerary, OSM-PathFinder must at least be used with the following command line :
```
$ ./osm-pathfinder -f <map>.osm {starting and ending points}
```
where :
 - option `-f` allows to select the OSM file (`<map>.osm`) to work with.
 - _`{starting and ending points}`_ allows to select the starting and ending point of your itinerary.
   These points could be defined of three different ways :
   - `-n <nodeID1> <nodeID2>` where `nodeID1` and `nodeID2` are integers to directly select them from
     OSM nodes with their field `id`.
   - `-c <latitude1>/<longitude1> <latitude2>/<longitude2>` to select theme from coordinates in latitude
     and longitude.
   - `-a <address1> <address2>` to select theme from addresses. _(Not implemented yet)_

######_Exemple :_
```
$ ./osm-pathfinder -f MapExemple/exemple.osm -c 48.6499/2.3648 48.6890/2.38233
```
will compute the itinerary on the map `MapExemple/exemple.osm` from the point of coordinates `48.6499/2.3648`
to the point of coordinates `48.6890/2.38233`.
