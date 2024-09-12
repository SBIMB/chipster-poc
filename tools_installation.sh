# download packages
for f in $(cat tools.txt); do wget https://a3s.fi/swift/v1/AUTH_chipcld/chipster-tools-bin/$f; done
cd ../..

# make sure you are on the same level as the 'temp' directory
for f in temp/genomes_fasta/*.tar.lz4; do sudo lz4 -d $f -c - | tar -x -C tools-bin/chipster-4.5.2; done
