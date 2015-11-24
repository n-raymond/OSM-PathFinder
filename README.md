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
$ opam install ocamlbuild
$ opam install camlimages
$ opam install xml-light
```

####Compile the project
A simple `make` in the root of the project  will produce the runable `osm_pathfinder`

####Generate documentation
A ` make doc` will generate an ocamldoc documentation in the `doc` subdirectory.


## How to use it




