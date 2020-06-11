NETCDF = /usr
FC = gfortran
FFLAGS = -I/usr/include -fconvert=big-endian
FFLAGS2 = -I/usr/include -fconvert=big-endian
LDFLAGS2 = -L/usr/lib/x86_64-linux-gnu -lnetcdf -lnetcdff
LDFLAGS = -L/usr/lib/x86_64-linux-gnu -lnetcdf -lnetcdff

objects = decodeOSTIA.o interpOSTIA.o get_vars.o

# List of executables to be built within the package
PROGRAMS = decodeOSTIA interpOSTIA

# "make" builds all
all: $(PROGRAMS)

interpOSTIA: interpOSTIA.o get_vars.o geth_newdate.o nfeb.o
	$(FC) -o $@ interpOSTIA.o get_vars.o geth_newdate.o nfeb.o ${LDFLAGS2}

decodeOSTIA: decodeOSTIA.o get_vars.o geth_newdate.o nfeb.o
	$(FC) -o $@ decodeOSTIA.o get_vars.o geth_newdate.o nfeb.o ${LDFLAGS2}

%.o : %.f90
	$(FC) ${FFLAGS} -c $<

%.o : %.f
	$(FC) ${FFLAGS} -c $<

clean:
	rm -f *.o *.mod *.MOD

veryclean: clean
	rm -f *~ $(PROGRAMS)

