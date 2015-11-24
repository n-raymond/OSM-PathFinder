OSM-PathFinder
==============
_Nicolas Tortrat--Gentilhomme_ / _Nicolas Raymond, 2014/2015_

![Preview](/images/Preview.jpg)


##About the software

The OpenStreetMap PathFinder is a command line tool that allows you to compute itineraries
for pedestrians, bicycles and motorized vehicules on maps from [OpenStreetMap.org](https://www.openstreetmap.org/).

It can extract data from OSM files and display the path which you have requested in two formats :
 - A graphical and visual format stored as a jpeg file.
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
A simple ` make ` in the root of the project  will produce the runnable `osm_pathfinder`

####Generate documentation
A ` make doc ` will generate an ocamldoc documentation in the `doc` subdirectory.


## How to use it

######_Note :_
The following exemples will use an OpenStreetMap file not included in this repo in order to keep
it light. If you want to do some tests on the same file and use exactly the same commands, you might
clone this [repo](https://github.com/PixelSpirit/MapExemple) at the root of the project.

####Basics
To compute an itinerary, OSM-PathFinder must at least be used with the following command line :
```
$ ./osm_pathfinder -f <map>.osm {starting and ending points}
```
where :
 - option `-f` allows to select the OSM file (`<map>.osm`) to work with.
 - _`{starting and ending points}`_ allows to select the starting and ending point of your itinerary.
   These points could be defined by three different ways :
   - `-n <nodeID1> <nodeID2>` where `nodeID1` and `nodeID2` are integers to directly select them from
     OSM nodes with their field `id`.
   - `-c <latitude1>/<longitude1> <latitude2>/<longitude2>` to select theme from coordinates in latitude
     and longitude.
   - `-a <address1> <address2>` to select theme from addresses. _(Not implemented yet)_

######_Exemple :_
```
$ ./osm_pathfinder -f MapExemple/exemple.osm -c 48.6499/2.3648 48.6890/2.38233
```
will compute the itinerary on the map `MapExemple/exemple.osm` from the point of coordinates `48.6499/2.3648`
to the point of coordinates `48.6890/2.38233`.

####Itinerary Settings :

######Set the vehicule :
By setting the vehicule, OSM-PathFinder will compute the itinerary for the choosen vehicule.
You can use :
 - `--motorized` or `-m` for a motorized vehicule (car / motocycle) itinerary. _(default)_
 - `--bicycle` or `-b` for a bicycle itinerary.
 - `--pedestrian` or `-p` for a pedestrian itinerary.
 
 
######Set the kind of itinerary :
Two kinds of itinerary are available :
 - `--distance` or `-d` will set the itinerary to be the shortest in distance. _(default)_
 - `--time` or `-t` will set the itinerary to be the shortest in time.

######Set the display output :
The itinerary can be displayed in two formats :
 - `--roadmap` or `-r` will print the itinerary as a roadmap, explaining you all the steps
   to travrel through it. _(default)_
 - `--graphical <image>.jpg` or `-g <image>.jpg` will draw the map, the itinerary and
   will save the result in the image file `<image>.jpg`. The itinerary will be represented
   by a red line, the starting point by a green dot and the destination by a blue one. 


####Preprocessing :
The first time OSM-PathFinder will handle an OSM file, it will extracts his data in order to
use it. Also, the first time you will use the `--graphical` option, it will draw the map from
the data it has extracted.
This first treatments can be quiet long due to the very large size of Open Street Map files, but
they are only necessary once. The next times OSM-PathFinder will handle the same file, the processing
must be very faster.

The command line :
```
$ ./osm_pathfinder -P -f <map>.osm
```
will run all those pre-treatments separatly. It can be useful if you want to use the tool in a server
application and reprocess the maps when they have been updated.

####Help :
The command line :
```
$ ./osm_pathfinder -h
```
will prints you the usage of the programe.


##_Exemples :_

####1. _RoadMap Generation_ :
```
$ ./osm_pathfinder --motorized --time --roadmap -f MapExemple/exemple.osm -c 48.6603/2.3774 48.6890/2.38233
```
will produce the following roadmap :

![roadmap](/images/roadmap.png)

####2. _JPEG File Generation_ :
```
$ ./osm_pathfinder --bicycle --distance --graphic myItinerary.jpg -f MapExemple/exemple.osm -c 48.6603/2.3774 48.6890/2.38233
```
will produce the file myItinerary.jpg with this picture :

![myItinerary](/images/myItinerary.jpg)



 


