cat aaa.txt | perl aaa.pl > aaa2.txt
cat aaa2.txt | perl aaa2.pl > aaa3.txt
cat aaa3.txt | perl offset.pl > file.txt
xxd -r file.txt > file.bin
./nogi
