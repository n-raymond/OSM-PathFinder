# OSM-PathFinder

**************************************
*            COMPILATION             *
**************************************

Use this command :

$ make


***************************************
*           COMMAND LINE              *
***************************************

The options -f and {-c | -n} must be specified explicitly.
The options -a (--addresses) or -P (--preprocessing) are not functional

These are the 2 possible usages of SWOM :
Just be in the root directory of the project and use one of those commands :

$ ./swom [-b | -m | -p] [-t | -d] [-r | -g] -f file.osm -c longitude1/latitude1 longitude2/latitude2
$ ./swom [-b | -m | -p] [-t | -d] [-r | -g] -f file.osm -n nodeID1 nodeID2

  --file           Set which osm file need to be used.
  -f               Set which osm file need to be used.
  --morized        Set the route for motorized vehicles. (default)
  -m               Set the route for motorized vehicles. (default)
  --bicycle        Set the route for bicycles.
  -b               Set the route for bicycles.
  --pedestrian     Set the route for pedestrian.
  -p               Set the route for pedestrian.
  --distance       Set the route for the shortest distance. (default)
  -d               Set the route for the shortest distance. (default)
  --time           Set the route for the shortest.
  -t               Set the route for the shortest.
  --roadmap        Display the route in roadmap mode. (default)
  -r               Display the route in roadmap mode. (default)
  --graphic        Display the route in graphical mode.
  -g               Display the route in graphical mode.
  --nodes          Define the starting and ending points with Open Street Map nodes.
  -n               Define the starting and ending points with Open Street Map nodes.
  --coordinates    Define the starting and ending points with coordinates in latitude/longitide.
  -c               Define the starting and ending points with coordinates in latitude/longitide.
  -help            Display this list of options
  --help           Display this list of options
