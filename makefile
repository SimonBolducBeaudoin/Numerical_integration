NAME = Numeric_Integrals
PYLIB_EXT = $(if $(filter $(OS),Windows_NT),.pyd,.so)
TARGET_STATIC = lib$(NAME).a

NUMERICAL_INT = ../Numerical_integration
LIBS = ../libs

IDIR = includes
ODIR = obj
LDIR = lib
SDIR = src

EXTERNAL_INCLUDES = -I$(NUMERICAL_INT)/$(IDIR)

SRC  = $(wildcard $(SDIR)/*.cpp)
OBJ  = $(patsubst $(SDIR)/%.cpp,$(ODIR)/%.o,$(SRC))
ASS  = $(patsubst $(SDIR)/%.cpp,$(ODIR)/%.s,$(SRC))
DEPS = $(OBJ:.o=.d)

CXX = $(OS:Windows_NT=x86_64-w64-mingw32-)g++
OPTIMIZATION = -O3 -march=native
CPP_STD = -std=c++14
WARNINGS = -Wall
MINGW_COMPATIBLE = $(OS:Windows_NT=-DMS_WIN64 -D_hypot=hypot)
DEPS_FLAG = -MMD -MP

POSITION_INDEP = -fPIC

MATH = -lm 

INCLUDES = $(MATH)  $(EXTERNAL_INCLUDES)
COMPILE = $(CXX) $(OPTIMIZATION) $(POSITION_INDEP)  -c -o $@ $< $(INCLUDES) $(DEPS_FLAG) $(MINGW_COMPATIBLE)
ASSEMBLY = $(CXX) $(OPTIMIZATION) $(POSITION_INDEP)  -S -o $@ $< $(INCLUDES) $(DEPS_FLAG) $(MINGW_COMPATIBLE)
STATIC_LIB = ar cr $(TARGET_STATIC) $(OBJ) 	

static_library : $(TARGET_STATIC)

all : $(TARGET_STATIC) $(OBJ) $(ASS)

compile_objects : $(OBJ)

assembly : $(ASS)

$(TARGET_STATIC) : $(OBJ)
	@ echo " "
	@ echo "---------Compiling static library $(TARGET_STATIC)---------"
	$(STATIC_LIB)

$(ODIR)/%.o : $(SDIR)/%.cpp
	@ echo " "
	@ echo "---------Compile object $@ from $<--------"
	$(COMPILE)
	
$(ODIR)/%.s : $(SDIR)/%.cpp
	@ echo " "
	@ echo "---------Assembly $@ from $<--------"
	$(ASSEMBLY)

-include $(DEPS)

clean:
	@rm -f $(TARGET_STATIC) $(OBJ) $(ASS) $(DEPS)

.PHONY: all , clean , compile_objects , assembly