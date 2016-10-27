# target executable
TARGET:=nbody
# Host C sources
SRC:=
# Host C++ sources
SRC_CPP:=
# GPU sources
SRC_CUDA:=kernel.cu

# OpenGL
USE_OPENGL:=1

# CUDA compute capability
CUDA_ARCHITECTURE:=-arch=compute_11 -code=sm_11
# Optimization flags
NVCC_OPTFLAGS:=-use_fast_math
# CUDA install paths
CUDA_INSTALL_PATH:=/opt/cuda
CUDA_SDK:=/opt/cudasdk

# Compiler flags
GCC_WARNINGS:=-Wall -Wextra -pedantic
GCC_OPTFLAGS:=-Os -march=native -mtune=native -fomit-frame-pointer
CFLAGS:=$(GCC_WARNINGS) $(GCC_OPTFLAGS) -pipe
CXXFLAGS:=$(GCC_WARNINGS) $(GCC_OPTFLAGS) -pipe
NVCC_FLAGS:=-O2 $(CUDA_ARCHITECTURE) $(NVCC_OPTFLAGS)

# OpenGL libs
ifeq ($(USE_OPENGL), 1)
	LIB:=-lGL -lGLU -lglut
	#LIB+=-lX11 -lXi -lXmu
	ifeq ($(shell uname -m), x86_64)
		LIB+=-lGLEW_x86_64 -L$(CUDA_SDK)/shared/lib/linux
	else
		LIB+=-lGLEW -L$(CUDA_SDK)/shared/lib/linux
	endif
endif

LIB+=-lgsl -lgslcblas

# Includes
INCLUDES:=-I. -I$(CUDA_INSTALL_PATH)/include -I$(CUDA_SDK)/C/common/inc \
	-I$(CUDA_SDK)/shared/inc
CFLAGS+=$(INCLUDES)
CXXFLAGS+=$(INCLUDES)
NVCC_FLAGS+=$(INCLUDES)

CC:=gcc
CXX:=g++
NVCC:=$(CUDA_INSTALL_PATH)/bin/nvcc

OBJ:=$(SRC:.c=.o)
OBJ_CPP:=$(SRC_CPP:.cpp=.o)
OBJ_CUDA:=$(SRC_CUDA:.cu=.o)

# link all object files
$(TARGET): $(OBJ) $(OBJ_CPP) $(OBJ_CUDA)
	$(NVCC) $(LIB) -o $(TARGET) $(OBJ) $(OBJ_CPP) $(OBJ_CUDA)

# compile CUDA files
%.o: %.cu
	$(NVCC) $(NVCC_FLAGS) -c -o $@ $<

clean:
	rm -f $(TARGET) $(OBJ) $(OBJ_CPP) $(OBJ_CUDA)

.PHONY: clean
.SUFFIXES: .cu
