#!/bin/sh

set -ex


export LC_ALL=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

yum -y install httpd24.x86_64

# MySQLのバージョンは利用したいものにあわせて変更すること
yum -y install mysql51-server.x86_64 
yum -y install mysql51.x86_64 

yum -y install gcc64.x86_64;
yum -y install perl-CPAN.noarch;
yum -y install perl-GD.x86_64; 
yum -y install perl-YAML-Syck.x86_64;
yum -y install perl-Archive-Tar.noarch;
yum -y install perl-YAML.noarch;
yum -y install perl-Test-Warn.noarch;
yum -y install perl-CGI.noarch;
yum -y install perl-XML-Parser.x86_64;
yum -y install ImageMagick-perl.x86_64;
yum -y install perl-Text-CSV_XS.x86_64;
yum -y install perl-Archive-Zip.noarch;
yum -y install perl-Digest-SHA1.x86_64
yum -y install perl-Authen-SASL.noarch;
yum -y install expat-devel.x86_64;
yum -y install perl-Env.noarch 
yum -y install openssl-devel.x86_64
yum -y install python26-pip.noarch

cd /usr/local/bin;
curl -LOk http://xrl.us/cpanm;
chmod +x cpanm
/usr/local/bin/cpanm Image::Size
/usr/local/bin/cpanm LWP::UserAgent
/usr/local/bin/cpanm Imager
/usr/local/bin/cpanm Fatal
/usr/local/bin/cpanm XML::SAX
/usr/local/bin/cpanm XML::SAX::ExpatXS
/usr/local/bin/cpanm XML::SAX::Expat

/usr/local/bin/cpanm Alien::Libxml2
/usr/local/bin/cpanm XML::LibXML::SAX


/usr/local/bin/cpanm Module::Build::Tiny
/usr/local/bin/cpanm Plack
/usr/local/bin/cpanm XMLRPC::Transport::HTTP::Plack


/usr/local/bin/cpanm CGI::Parse::PSGI
/usr/local/bin/cpanm CGI::PSGI
/usr/local/bin/cpanm CGI::Compile
/usr/local/bin/cpanm Task::Plack
/usr/local/bin/cpanm Starman

pip install --upgrade pip
pip install supervisor
