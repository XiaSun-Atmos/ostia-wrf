NETCDF = /usr/local
FC = gfortran
FFLAGS = -I$(NETCDF)/include -fconvert=big-endian
FFLAGS2 = -I$(NETCDF)/include -fconvert=big-endian
LDFLAGS = -L$(NETCDF)/lib -lnetcdf -lnetcdff
LDFLAGS2 = -L$(NETCDF)/lib -lnetcdf -lnetcdff

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

