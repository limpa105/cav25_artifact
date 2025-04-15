# Use the official Ubuntu image as the base image
FROM ubuntu:20.04

# Set environment variable to avoid interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  curl \
  libgmp-dev \
  libmpfr-dev \
  libboost-all-dev \
  wget \
  g++ \
  make \
  python3 \
  python3-pip \
  python3-venv \
  unzip \
  libfl-dev \
  texlive \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-lang-english \
  lsb-release




# Setup z3
# RUN git clone https://github.com/Z3Prover/z3.git
# RUN g++ --version

# # upgrading g++
# RUN apt-get update && \
#     apt-get install -y software-properties-common && \
#     add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
#     apt-get update && \
#     apt-get install -y g++-13 && \
#     update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
#     update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100

# WORKDIR /z3
# RUN git checkout 26b8d634a318b3aa0bacbcbaadbf8e5234d21034
# RUN python3 scripts/mk_make.py
# WORKDIR /z3/build
# RUN make -j12
# WORKDIR /

# setup yices 
# RUN pip install sphinx
# RUN apt-get install -y libgmp-dev
# RUN apt-get install -y build-essential gperf autoconf automake libtool
# RUN git clone https://github.com/SRI-CSL/yices2.git
# WORKDIR /yices2 

# # Build libpoly
# WORKDIR /deps
# RUN git clone https://github.com/SRI-CSL/libpoly.git
# WORKDIR /deps/libpoly/build
# RUN cmake .. && make -j$(nproc) && make install

# RUN wget http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz && \
#     tar -xzf automake-1.14.tar.gz && \
#     cd automake-1.14 && \
#     ./configure && \
#     make -j$(nproc) && \
#     make install


# WORKDIR /deps
# RUN git clone --depth 1 --branch cudd-3.0.0 https://github.com/ivmai/cudd.git
# WORKDIR /deps/cudd
# ENV CFLAGS="-fPIC" CXXFLAGS="-fPIC"
# # Configure with static linking enabled, disable shared to avoid confusion
# RUN ./configure  && make -j$(nproc) && make install

# WORKDIR /yices2 
# RUN git checkout c0a2609283b62592e6abc7be03c81957351b81b4
# ENV CPPFLAGS="-I/usr/local/include"
# ENV LDFLAGS="-L/usr/local/lib"
# RUN autoconf
# RUN ./configure --enable-mcsat
# RUN make -j12

# WORKDIR /

# # bitwuzla yayyy 
# RUN git clone https://github.com/bitwuzla/bitwuzla
# WORKDIR /bitwuzla
# RUN apt-get install -y ninja-build
# RUN pip install meson
# RUN ./configure.py 
# WORKDIR /bitwuzla/build
# RUN ninja

# WORKDIR /

# RUN apt install -y build-essential libreadline-dev libgmp-dev
# RUN wget https://www.singular.uni-kl.de/ftp/pub/Math/Singular/SOURCES/4-0-0//singular-4.0.0.p4.tar.gz
# RUN tar -xzf singular-4.0.0.p4.tar.gz
# WORKDIR /singular-4.0.0.p4
# RUN ./configure
# RUN make -j 12 && make install
#sudo make install




WORKDIR /opt
COPY Singular-4.4.0-x86_64-Linux.tar.gz . 
RUN tar -xzf Singular-4.4.0-x86_64-Linux.tar.gz
RUN export PATH="/opt/bin:$PATH"
WORKDIR /

# Setup my solver 
# WORKDIR /range_solver 
# RUN  git clone https://github.com/limpa105/cvc5.git
# WORKDIR /range_solver/cvc5 
# RUN git checkout aritifact
# RUN pip install tomli
# RUN pip install pyparsing
# RUN ./configure.sh --auto-download 
# WORKDIR /range_solver/cvc5/build
# RUN make -j12
# WORKDIR /


RUN export PATH="/opt/bin:$PATH"

# copy benchmarks over and untar  
COPY   benchmarks.tar.gz  benchmarks.tar.gz 
RUN tar -xzf benchmarks.tar.gz

RUN apt-get install -y glpk-utils libglpk-dev

# set up run lim and parallel and pandas 
COPY set_up_runlim.sh .
RUN ./set_up_runlim.sh
RUN apt-get install -y parallel
RUN pip install --no-cache-dir pandas

# copy over impotant files 



# ENV LD_LIBRARY_PATH=/usr/local/lib

#RUN ln -s /opt/Singular/bin/Singular /usr/local/bin/Singular
ENV PATH="/opt/bin/:$PATH"
# Set the working directory
WORKDIR /

#Setup cvc5
# RUN git clone https://github.com/cvc5/cvc5.git /cvc5
# WORKDIR /cvc5
# RUN git checkout 7ee7051df0
# RUN ./configure.sh --auto-download
# WORKDIR /cvc5/build
# RUN make -j12
# WORKDIR /

#set up z3
# RUN git clone https://github.com/Z3Prover/z3.git
# RUN g++ --version

# upgrading g++
# RUN apt-get update && \
#     apt-get install -y software-properties-common && \
#     add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
#     apt-get update && \
#     apt-get install -y g++-13 && \
#     update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
#     update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100

# WORKDIR /z3
# RUN git checkout 26b8d634a318b3aa0bacbcbaadbf8e5234d21034
# RUN python3 scripts/mk_make.py
# WORKDIR /z3/build
# RUN make -j12
# WORKDIR /
#set up bitwuzla 
# # bitwuzla yayyy 
RUN git clone https://github.com/bitwuzla/bitwuzla
WORKDIR /bitwuzla
RUN apt-get install -y ninja-build
RUN pip install meson
RUN ./configure.py 
WORKDIR /bitwuzla/build
RUN ninja
WORKDIR /solvers


COPY solvers/cvc5 cvc5
COPY solvers/yices yices
COPY solvers/z3 z3

WORKDIR /

#Setup cvc5
RUN git clone https://github.com/cvc5/cvc5.git 
WORKDIR /cvc5
RUN ./configure.sh --auto-download --cocoa --gpl
WORKDIR /cvc5/build
RUN make -j12
WORKDIR /

RUN pip install tomli
RUN pip install pyparsing


WORKDIR /weighted_ilp 
RUN  git clone https://github.com/limpa105/cvc5.git
WORKDIR /weighted_ilp/cvc5 
RUN git checkout ablations
RUN git checkout 232748a
RUN ./configure.sh --auto-download 
WORKDIR /weighted_ilp/cvc5/build
RUN make -j12
WORKDIR /

WORKDIR /ilp 
RUN  git clone https://github.com/limpa105/cvc5.git
WORKDIR /ilp/cvc5 
RUN git checkout ablations
RUN git checkout 056030d
RUN ./configure.sh --auto-download 
WORKDIR /ilp/cvc5/build
RUN make -j12
WORKDIR /

WORKDIR /unweighted
RUN  git clone https://github.com/limpa105/cvc5.git
WORKDIR /unweighted/cvc5 
RUN git checkout ablations
RUN git checkout 58ade4d
RUN ./configure.sh --auto-download 
WORKDIR /unweighted/cvc5/build
RUN make -j12
WORKDIR /


WORKDIR /range_solver 
RUN  git clone https://github.com/limpa105/cvc5.git
WORKDIR /range_solver/cvc5 
RUN git checkout gpsol_aprox
RUN ./configure.sh --auto-download 
WORKDIR /range_solver/cvc5/build
RUN make -j12
WORKDIR /



# COPYING OVER 
COPY run_custom.sh .
COPY run_solver.py .
COPY run_small.sh .
COPY run_all.sh .
COPY test_bench.csv .
COPY analyze.py .
COPY run_custom.sh .
COPY generate_runs.sh .
COPY small_bench.csv .
COPY large_bench.csv .
COPY large_bench.csv .
COPY run_all.sh .
WORKDIR /
WORKDIR /multimod_benchmarks/qf_nia/sp_field/goldilocks_cor/
COPY cor_1var_2deg_1trm_nia.smt2  .
WORKDIR /