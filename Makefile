
# Open Street Map PathFinder - Find your way with OpenStreetMap maps
# Copyright (C) 2015 - Nicolas TORTRAT / Nicolas Raymond

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.



##########################
# Makefile Configuration #
##########################

COWORKERS = Tortrat-Raymond
TARGET    = osm_pathfinder

OCAMLBUILD = ocamlbuild -use-ocamlfind -use-menhir $(OCAMLBUILDFLAGS)

#########
# Rules #
#########

BTARGET	 = $(TARGET).byte
OTARGET	 = $(TARGET).native
STARGET	 = $(OTARGET)
PACKAGE  = $(TARGET)-$(COWORKERS)

.PHONY: all-generic dist byte opt clean doc

all-generic: clear $(STARGET) $(TARGET)

$(TARGET):
	ln -s $(STARGET) $(TARGET)

clear:
	rm -f $(STARGET)

opt: $(OTARGET)

byte: $(BTARGET)

%:
	@ $(OCAMLBUILD) src/$@

clean:
	@ $(OCAMLBUILD) -clean
	find . -name '*~' -exec rm '{}' \;
	rm -fr *~ $(TARGET) doc

doc: byte
	$(OCAMLBUILD) $(TARGET).docdir/index.html
	mkdir -p doc/html
	rm -f $(TARGET).docdir/style.css 2> /dev/null
	mv $(TARGET).docdir/* doc/html
	rm $(TARGET).docdir

dist:
	rm -fr $(PACKAGE)
	mkdir $(PACKAGE)
	  if test -f `cat distributed_files` then					
	    cp -fr --parents `cat distributed_files` $(PACKAGE);
	  else
	    mkdir -p `cat distributed_files`
	  fi;							
	tar cvfz $(PACKAGE).tar.gz $(PACKAGE)
