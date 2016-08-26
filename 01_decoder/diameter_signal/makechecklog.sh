#!/usr/bin/perl




`perl ./cutter.pl $ARGV[0]`;
`rm *GTP*`;
`rm *PMIP*`;

@files = `ls -1 *.mylog`;
print @files;

foreach $file (@files) {
	chomp($file);
	`xxd -r $file ${file}.bin`;
	`rm $file`;
	`cat ${file}.bin | ./dia_form > $ARGV[0]_${file}.check`;
	`rm ${file}.bin`;
	print "-----------------------------------------\n";
}





