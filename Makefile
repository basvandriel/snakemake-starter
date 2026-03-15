setup:
	curl -L https://api.github.com/repos/snakemake/snakemake-tutorial-data/tarball -o snakemake-tutorial-data.tar.gz
	tar -xf snakemake-tutorial-data.tar.gz --strip 1 "*/data" "*/environment.yaml"