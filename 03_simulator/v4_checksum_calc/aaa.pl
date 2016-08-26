while(<>){
	s/(.{32})/$1\n/g;
	print;
}
