#!/bin/bash -e

perllib=(CGI Image::Size File::Spec CGI::Cookie Scalar::Util LWP::UserAgent parent Archive::Zip Image::Magick XML::Parser T
ext::CSV_XS DBD::mysql )

for pl in "${perllib[@]}"
do
        echo "${pl}"
        perl -M${pl} -e ''
done

echo "File::Specのバージョンは、0.8以上が必要です";
perl -MFile::Spec -e 'print $File::Spec::VERSION';
echo "";

echo "DBIのバージョンは1.21以上が必要です";
perl -MDBI -e 'print $DBI::VERSION';
echo ""