# This Dockerfile creates a container with tools for tuberculosis genomic analysis:
# - sra-toolkit: For downloading sequencing data from NCBI SRA
# - snippy: For bacterial variant calling from NGS reads
# - tb-profiler: For TB resistance profiling and lineage identification
#
# Created with the assistance of Claude Code.

FROM nextstrain/base

# ==============================================================================
# System Package Installation
# ==============================================================================

# Update package manager cache
# Reference: https://docs.docker.com/develop/dev-best-practices/
RUN apt-get update

# Install SRA Toolkit for downloading sequencing data from NCBI
# Reference: https://github.com/ncbi/sra-tools
# Documentation: https://ncbi.github.io/sra-tools/
RUN apt-get install -y sra-toolkit

# Install dependencies for snippy and tb-profiler
# Core Perl runtime and modules for snippy:
#   - perl: Core Perl interpreter
#   - libparallel-forkmanager-perl: Parallel processing for Perl
#   - liblist-moreutils-perl: Additional list manipulation functions
#   - libbio-perl-perl: BioPerl library for bioinformatics
# Sequence alignment and analysis tools:
#   - bwa: Burrows-Wheeler Aligner - https://github.com/lh3/bwa
#   - samtools: SAM/BAM file manipulation - https://github.com/samtools/samtools  
#   - bcftools: VCF/BCF file manipulation - https://github.com/samtools/bcftools
#   - vcftools: VCF file analysis - https://vcftools.github.io/
#   - freebayes: Bayesian variant caller - https://github.com/freebayes/freebayes
#   - snpeff: Variant annotation - https://pcingola.github.io/SnpEff/
#   - bedtools: Genome arithmetic - https://bedtools.readthedocs.io/
#   - samclip: SAM/BAM soft-clipping tool
RUN apt-get install -y \
    perl \
    libparallel-forkmanager-perl \
    liblist-moreutils-perl \
    libbio-perl-perl \
    bwa \
    samtools \
    bcftools \
    vcftools \
    freebayes \
    snpeff \
    bedtools \
    samclip

# ==============================================================================
# Snippy Installation
# ==============================================================================

# Install snippy: Fast bacterial variant calling from NGS reads
# Repository: https://github.com/tseemann/snippy
# Citation: Seemann T (2015) snippy: fast bacterial variant calling from NGS reads
# Documentation: https://github.com/tseemann/snippy#synopsis
RUN git clone https://github.com/tseemann/snippy.git /opt/snippy && \
    chmod +x /opt/snippy/bin/snippy* && \
    ln -s /opt/snippy/bin/* /usr/local/bin/

# ==============================================================================
# TB-Profiler Installation
# ==============================================================================

# Install Python dependencies and TB-Profiler components
# TB-Profiler: Profiling tool for Mycobacterium tuberculosis
# Repository: https://github.com/jodyphelan/TBProfiler
# Citation: Phelan et al. (2019) Integrating informatics tools and portable sequencing technology for rapid detection of resistance to anti-tuberculous drugs. Genome Medicine 11:41
# Documentation: https://jodyphelan.github.io/TBProfiler/
# Core Python dependencies:
#   - pysam: Python interface for SAM/BAM files - https://github.com/pysam-developers/pysam
#   - numpy: Numerical computing - https://numpy.org/
#   - pydantic: Data validation - https://pydantic-docs.helpmanual.io/
#   - rich-argparse: Rich command-line argument parsing - https://github.com/hynek/rich-argparse
#   - requests: HTTP library - https://docs.python-requests.org/
#   - tomli: TOML parser - https://github.com/hukkin/tomli
#   - docxtpl: Word document templating - https://github.com/elapouya/python-docx-template
#   - filelock: File locking - https://github.com/tox-dev/py-filelock
RUN pip install --upgrade pip && \
    pip install pysam numpy pydantic rich-argparse requests tomli docxtpl filelock && \
    # Install iTOL configuration library (dependency for TB-Profiler)
    # Repository: https://github.com/jodyphelan/itol-config
    git clone https://github.com/jodyphelan/itol-config.git /opt/itol-config && \
    cd /opt/itol-config && \
    pip install . && \
    # Install pathogen-profiler (core library for TB-Profiler)
    # Repository: https://github.com/jodyphelan/pathogen-profiler
    git clone https://github.com/jodyphelan/pathogen-profiler.git /opt/pathogen-profiler && \
    cd /opt/pathogen-profiler && \
    pip install . && \
    # Install TB-Profiler main application
    # Repository: https://github.com/jodyphelan/TBProfiler
    git clone https://github.com/jodyphelan/TBProfiler.git /opt/tbprofiler && \
    cd /opt/tbprofiler && \
    pip install . && \
    # Create writable directory for TB-Profiler database files
    mkdir -p /usr/local/share/tbprofiler && \
    chmod 777 /usr/local/share/tbprofiler

# ==============================================================================
# Cleanup and Final Configuration
# ==============================================================================

# Clean up package cache to reduce image size
# Reference: https://docs.docker.com/develop/dev-best-practices/#minimize-the-number-of-layers
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
