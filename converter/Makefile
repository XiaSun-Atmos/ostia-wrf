NETCDF = /cm/shared/uniol/software/netCDF-Fortran/4.4.4-intel-2016b
FC = ifort
FFLAGS = -I$(NETCDF)/include -convert big_endian
FFLAGS2 = -I$(NETCDF)/include -convert big_endian
LDFLAGS2 = -L$(NETCDF)/lib -lnetcdf -lnetcdff 
LDFLAGS = -L$(NETCDF)/lib -lnetcdf -lnetcdff 

objects = decodeOSTIA.o interpOSTIA.o get_vars.o

# List of executables to be built within the package
PROGRAMS = decodeOSTIA interpOSTIA

# "make" builds all
all: $(PROGRAMS)

interpOSTIA: interpOSTIA.o get_vars.o geth_newdate.o nfeb.o
	$(FC) -o $@ interpOSTIA.o get_vars.o geth_newdate.o nfeb.o ${LDFLAGS2}
#	mv interpOSTIA /home/${USER}/bin

decodeOSTIA: decodeOSTIA.o get_vars.o geth_newdate.o nfeb.o
	$(FC) -o $@ decodeOSTIA.o get_vars.o geth_newdate.o nfeb.o ${LDFLAGS2}
#	mv decodeOSTIA /home/${USER}/bin

%.o : %.f90
	$(FC) ${FFLAGS} -c $<

%.o : %.f
	$(FC) ${FFLAGS} -c $<

clean:
	rm -f *.o *.mod *.MOD

veryclean: clean
	rm -f *~ $(PROGRAMS)

