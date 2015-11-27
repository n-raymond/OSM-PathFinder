OSM-PathFinder
==============
_Nicolas Raymond / Nicolas Tortrat--Gentilhomme, 2014/2015_

![Preview](/images/Preview.jpg)


##About the software

The OpenStreetMap-PathFinder is a command line tool that allows you to compute itineraries
for pedestrians, bicycles and motorized vehicles on maps coming from
[OpenStreetMap.org](https://www.openstreetmap.org/).

OSM-Pathfinder can extract data from OSM files and display the path that you have requested
in two different formats :
 - A graphical and visual format stored as a jpeg file.
 - A textual format that gives you a roadmap discribing your itinerary.

This project is a study work realized by a team at the _University Paris Diderot, Paris 7_.


##How to compile it

OSM-PathFinder at least needs the `4.02.0` version of OCaml and uses different packages :
 - `xml-light`
 - `lablgtk`
 - `camlimages` 
 - `ocamlbuild`

The easiest way to install them is to use the OPAM package manager.

####Install Ocaml and OPAM
######On linux systems
```
$ sudo apt-get install opam
$ opam init
$ eval `opam config env`
```
######On OSX
Use [homebrew](http://brew.sh/).
```
$ brew install Caskroom/cask/xquartz
$ brew install ocaml --with-x11
$ brew install opam
$ opam init
$ eval `opam config env`
```
*_Note_*: You will probably have to reboot your computer after these commands
because of the installation of XQuartz.

####Instal GTK+
The `lablgtk` and `camlimages` packages need a recent version of `gtk+`.
######On linux systems
```
$ sudo apt-get install libgtk2.0-dev libjpeg-dev
```
######On OSX
```
$ brew install gtk+
```


####Install packages
```
$ opam install ocamlbuild lablgtk camlimages xml-light
$ eval `opam config env`
```

####Compile the project
Clone this repo at a desired place on your computer.
A simple ` make ` in the root of the project will produce the runnable `osm_pathfinder`

####Generate documentation
A ` make doc ` will generate an ocamldoc documentation in the `doc` subdirectory.


## How to use it

*_Note_* : The following examples will use an OpenStreetMap file not included in this repo in order to keep
it light. If you want to do some tests on the same file and use exactly the same commands, you might
clone that [repo](https://github.com/PixelSpirit/MapExample) at the root of the project.

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

######_Example :_
```
$ ./osm_pathfinder -f MapExample/example.osm -c 48.6499/2.3648 48.6890/2.38233
```
will compute the itinerary on the map `MapExample/example.osm` from the point of coordinates `48.6499/2.3648`
to the point of coordinates `48.6890/2.38233`.

####Itinerary Settings :

######Set the vehicle :
By setting the vehicle, OSM-PathFinder will compute the itinerary for the circulating form
you have chosen.
You can use :
 - `--motorized` or `-m` for a motorized vehicle (car / motocycle) itinerary. _(default)_
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
The first time OSM-PathFinder will handle an OSM file, it will extracts his data in order
to use it. Also, the first time you will use the `--graphical` option, it will draw the
map from the data it has extracted.
This first treatments can be quite long due to the very large size of OpenStreetMap files,
but fortunately, they have to be computed only once. The next times OSM-PathFinder will
handle the same file, the global processing should be drastically faster.

The command line :
```
$ ./osm_pathfinder -P -f <map>.osm
```
will run all those pre-treatments separatly. It can be useful if you want to use the tool in a server
application and only re-process the maps if they have been updated.

####Help :
The command line :
```
$ ./osm_pathfinder -h
```
will prints you the usage of the software.


##_Examples :_

####1. _RoadMap Generation_ :
```
$ ./osm_pathfinder --motorized --time --roadmap -f MapExample/example.osm -c 48.6603/2.3774 48.6890/2.38233
```
will produce the following roadmap :

![roadmap](/images/roadmap.png)

####2. _JPEG File Generation_ :
```
$ ./osm_pathfinder --bicycle --distance --graphic myItinerary.jpg -f MapExemple/exemple.osm -c 48.6603/2.3774 48.6890/2.38233
```
will produce the file `myItinerary.jpg` with this picture :

![myItinerary](/images/myItinerary.jpg)



 


