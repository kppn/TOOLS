
msgform3 / msgform3g  - smonを整形出力する - 

usage

	./msgform3.pl [-C] [imsi=XXXX] [msisdn=XXXX] [guti=XXXX] [(file)]

	options
		-C
			From 'view_xxsmon file' command output.
			If this option is not presented, target is smon 
			asynchronous message.

		imsi/msisdn/guti
			Matching and print specific subscribed number
			only.

		(file)
			target file.
			if this option is not presented, target file is 
			Today's msglog at /SYSTEM/LOG_COM/msglog/
			

	example)

	./msgform3.pl
		smon message from Today's msglog

	./msgform3.pl (file)
		smon message from file

	./msgform3.pl imsi=XXXX msisdn=XXXX
		only specified imsi/msisdn (matching)

	./msgform3.pl -C
		from 'view_xxsmon file' command output



