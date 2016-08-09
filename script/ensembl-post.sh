#!/bin/bash -eux
# Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# Copyright [2016] EMBL-European Bioinformatics Institute
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install post-Puppet dependencies as the ensembl user

curl -L http://xrl.us/perlbrewinstall | bash

source ~/perl5/perlbrew/etc/bashrc
echo ". ~/perl5/perlbrew/etc/bashrc" >>~/.bashrc

perlbrew install -j 2 --notest perl-5.14.2 -D=usethreads -D=useshrplib -A='ccflags=-fPIC' --as 'perl-5.14.2'

perlbrew switch perl-5.14.2
echo "Perl version currently running:"
perl -v
echo "perlbrew switch perl-5.14.2" >>~/.bashrc

#cpanp install App::cpanminus
curl -L https://cpanmin.us | perl - App::cpanminus

# Install cpan modules for ensembl
echo "Installing cpan modules for ensembl modules"
modules=( "ensembl" "ensembl-compara" "ensembl-external" "ensembl-funcgen" "ensembl-variation" "ensembl-io" "ensembl-test" )
for e in "${modules[@]}"
do
  (cd $HOME/ensembl-api-folder/$e && cpanm -v --installdeps .)
done
cpanm Test::Warn
cpanm -n DBD::SQLite
cpanm Devel::Cover
cpanm DBI
cpanm DBD::mysql
cpanm Module::Build

# Install faidx, tabix, and dependencies
cd $HOME/ensembl-api-folder/
git clone --branch master --depth 1 https://github.com/samtools/tabix.git
cd tabix
make
cd perl
perl Makefile.PL
make && make install
cd ../../

# Run the Bio-HTS install
cd $HOME/ensembl-api-folder/Bio-HTS
perl Build.PL
./Build install

# Run tests
test_modules=( "ensembl" )
for e in "${test_modules[@]}"
do
  cd $HOME/ensembl-api-folder/$e
  cp travisci/MultiTestDB.conf.travisci.mysql  modules/t/MultiTestDB.conf.mysql
 # SKIP_TESTS="--skip schemaPatches.t" ENSDIR=/home/ensembl/ensembl-api-folder DB=mysql COVERALLS=false travisci/harness.sh
 # ../ensembl-test/scripts/cleanup_databases.pl --curr_dir modules/t
done

# Delete the user password to simplify login
#passwd --delete ensembl
#gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
#dconf write /org/gnome/desktop/screensaver/idle-activation-enabled false
#dconf write /org/gnome/desktop/screensaver/lock-enabled false
