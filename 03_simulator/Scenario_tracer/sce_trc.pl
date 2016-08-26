#!/usr/bin/perl


$event_number = 1;

sub print_trace
{
	my $indent       = shift;
	my $position     = shift;
	my $line         = shift;
	my $traceline;
	
	$traceline = 
		sprintf("%s", $indent) .
		sprintf("multiply\(sce_trc_event, 0x100, sce_trc_event\); ") .
		sprintf("increase\(sce_trc_event, 0x%02x\);", $event_number);
	
	if ($position eq 'insert') {
		$line =~ s/\{/\{ $traceline /;
		print $line;
	}
	else {
		if ($position eq 'rear') {
			printf("%s", $line);
		}
		
		$traceline .= "\n";
		print $traceline;
		
		if ($position eq 'front') {
			printf("%s", $line);
		}
	}
	
	$event_number++;
}



#==============================================================================
# 
#==============================================================================
while ($line = <STDIN>) {
	if ($line =~ /^[ \t]+transit/) {
		print "\n";
		print "    control print_trace = 0;\n";
		print "    private sce_trc_event = 0x00000000;\n";
		print "\n";
		print $line;
		
		last;
	}
	print $line;
}



#==============================================================================
# print and insert trace procedure
#==============================================================================
while ($line = <STDIN>) {
	if ($line =~ /^[ \t]*#/) {
		print $line;
		next;
	}
	
	if ($line =~ /^[ \t]*in.*ANY_STATE/) {
		$in_any = 1;
	}
	if ($in_any and $line =~ /^\}/) {
		print "    \n";
		print "    case control\(print_trace, 1\) \{\n";
		print "        snap(\"trace\", sce_trc_event\);\n";
		print "    \}\n";
		print "    \n";
		
		$in_any = 0;
	}
	
	#---------------------------------------------------------------------
	# case statement
	#---------------------------------------------------------------------
	
	# open/close blacket at same line
	if ($line =~ /(^[ \t]*)case.*\{(.*)}/) {
		$indent = $1;
		print_trace($indent . "    ", 'insert', $line);
	}
	# case statement, open blacket at same line
	elsif ($line =~ /(^[ \t]*)case.*\{/) {
		$indent = $1;
		print_trace($indent . "    ", 'rear', $line);
	}
	# case statement,open blacket at different line
	elsif ($line =~ /(^[ \t]*)case/) {
		$indent = $1;
		print $line;
		while ($line = <STDIN>) {
			last if $line =~ /\{/;
			print $line;
		}
		print_trace($indent . "    ", 'rear', $line);
	}
	
	
	#---------------------------------------------------------------------
	# if statement
	#---------------------------------------------------------------------
	
	# if statement, blacket at same line
	elsif ($line =~ /(^[ \t]*)if.*\{/) {
		$indent = $1;
		print_trace($indent . "    ", 'rear', $line);
	}
	# if statement blacket at different line
	elsif ($line =~ /(^[ \t]*)if/) { 
		$indent = $1;
		print $line;
		while ($line = <STDIN>) {
			last if $line =~ /\{/;
			print $line;
		}
		print_trace($indent . "    ", 'rear', $line);
	}
	
	
	#---------------------------------------------------------------------
	# else statement
	#---------------------------------------------------------------------
	
	# else statement, blacket at same line
	elsif ($line =~ /(^[ \t]*)else.*\{/) {
		$indent = $1;
		print_trace($indent . "    ", 'rear', $line);
	}
	# else statement blacket at different line
	elsif ($line =~ /(^[ \t]*)else/) { 
		$indent = $1;
		print $line;
		while ($line = <STDIN>) {
			last if $line =~ /\{/;
			print $line;
		}
		print_trace($indent . "    ", 'rear', $line);
	}
	
	
	#---------------------------------------------------------------------
	# end of logic blocks
	#---------------------------------------------------------------------
	elsif ($line =~ /^[ \t]*pdu/){
		print $line;
		last;
	}
	
	#---------------------------------------------------------------------
	# not target
	#---------------------------------------------------------------------
	else {
		print $line;
	}
}



#==============================================================================
# print lines left
#==============================================================================
while (<>) {
	print;
}










