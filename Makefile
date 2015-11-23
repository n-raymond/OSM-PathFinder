
##########################
# Makefile Configuration #
##########################

COWORKERS = Tortrat-Raymond
TARGET    = swom

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
