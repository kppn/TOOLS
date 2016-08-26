




enum Nego_state{
	
};


	int phase;
	int nego_state;







   /*
    *
    *  PPP State Transition Table. from rfc1661.
    *  
    *        | State
    *        |    0         1         2         3         4         5          6         7         8           9
    *  Events| Initial   Starting  Closed    Stopped   Closing   Stopping   Req-Sent  Ack-Rcvd  Ack-Sent    Opened
    *  ------+-----------------------------------------------------------------------------------------------------
    *   Up   |    2     irc,scr/6     -         -         -         -          -         -         -           -
    *   Down |    -         -         0       tls/1       0         1          1         1         1         tld/1
    *   Open |  tls/1       1     irc,scr/6     3r        5r        5r         6         7         8           9r
    *   Close|    0       tlf/0       2         2         4         4      irc,str/4 irc,str/4 irc,str/4 tld,irc,str/4
    *        |                                                             
    *    TO+ |    -         -         -         -       str/4     str/5      scr/6     scr/6     scr/8         -
    *    TO- |    -         -         -         -       tlf/2     tlf/3      tlf/3p    tlf/3p    tlf/3p        -
    *        |                                                             
    *   RCR+ |    -         -       sta/2 irc,scr,sca/8   4         5        sca/8   sca,tlu/9   sca/8   tld,scr,sca/8
    *   RCR- |    -         -       sta/2 irc,scr,scn/6   4         5        scn/6     scn/7     scn/6   tld,scr,scn/6
    *   RCA  |    -         -       sta/2     sta/3       4         5        irc/7     scr/6x  irc,tlu/9   tld,scr/6x
    *   RCN  |    -         -       sta/2     sta/3       4         5      irc,scr/6   scr/6x  irc,scr/8   tld,scr/6x
    *        |                                                             
    *   RTR  |    -         -       sta/2     sta/3     sta/4     sta/5      sta/6     sta/6     sta/6   tld,zrc,sta/5
    *   RTA  |    -         -         2         3       tlf/2     tlf/3        6         6         8       tld,scr/6
    *        |                                                             
    *   RUC  |    -         -       scj/2     scj/3     scj/4     scj/5      scj/6     scj/7     scj/8       scj/9
    *   RXJ+ |    -         -         2         3         4         5          6         6         8           9
    *   RXJ- |    -         -       tlf/2     tlf/3     tlf/2     tlf/3      tlf/3     tlf/3     tlf/3   tld,irc,str/5
    *        |                                                             
    *   RXR  |    -         -         2         3         4         5          6         7         8         ser/9
    *  
    */
    


   /*  
    *  Assigned PPP DLL Protocol Numbers. from rfc1700
    *  
    *  Value (in hex)  Protocol Name
    *  
    *  0001            Padding Protocol
    *  0003 to 001f    reserved (transparency inefficient)
    *  0021            Internet Protocol
    *  0023            OSI Network Layer
    *  0025            Xerox NS IDP
    *  0027            DECnet Phase IV
    *  0029            Appletalk
    *  002b            Novell IPX
    *  002d            Van Jacobson Compressed TCP/IP
    *  002f            Van Jacobson Uncompressed TCP/IP
    *  0031            Bridging PDU
    *  0033            Stream Protocol (ST-II)
    *  0035            Banyan Vines
    *  0037            reserved (until 1993)
    *  0039            AppleTalk EDDP
    *  003b            AppleTalk SmartBuffered
    *  003d            Multi-Link
    *  003f            NETBIOS Framing
    *  0041            Cisco Systems
    *  0043            Ascom Timeplex
    *  0045            Fujitsu Link Backup and Load Balancing (LBLB)
    *  0047            DCA Remote Lan
    *  0049            Serial Data Transport Protocol (PPP-SDTP)
    *  004b            SNA over 802.2
    *  004d            SNA
    *  004f            IP6 Header Compression
    *  006f            Stampede Bridging
    *  007d            reserved (Control Escape)             [RFC1661]
    *  007f            reserved (compression inefficient)    [RFC1662]
    *  00cf            reserved (PPP NLPID)
    *  00fb            compression on single link in multilink group
    *  00fd            1st choice compression
    *  
    *  00ff            reserved (compression inefficient)
    *  
    *  0201            802.1d Hello Packets
    *  0203            IBM Source Routing BPDU
    *  0205            DEC LANBridge100 Spanning Tree
    *  0231            Luxcom
    *  0233            Sigma Network Systems
    *  
    *  8001-801f       Not Used - reserved                   [RFC1661]
    *  8021            Internet Protocol Control Protocol
    *  8023            OSI Network Layer Control Protocol
    *  8025            Xerox NS IDP Control Protocol
    *  8027            DECnet Phase IV Control Protocol
    *  8029            Appletalk Control Protocol
    *  802b            Novell IPX Control Protocol
    *  802d            reserved
    *  802f            reserved
    *  8031            Bridging NCP
    *  8033            Stream Protocol Control Protocol
    *  8035            Banyan Vines Control Protocol
    *  8037            reserved till 1993
    *  8039            reserved
    *  803b            reserved
    *  803d            Multi-Link Control Protocol
    *  803f            NETBIOS Framing Control Protocol
    *  807d            Not Used - reserved                   [RFC1661]
    *  8041            Cisco Systems Control Protocol
    *  8043            Ascom Timeplex
    *  8045            Fujitsu LBLB Control Protocol
    *  8047            DCA Remote Lan Network Control Protocol (RLNCP)
    *  8049            Serial Data Control Protocol (PPP-SDCP)
    *  804b            SNA over 802.2 Control Protocol
    *  804d            SNA Control Protocol
    *  804f            IP6 Header Compression Control Protocol
    *  006f            Stampede Bridging Control Protocol
    *  80cf            Not Used - reserved                   [RFC1661]
    *  80fb            compression on single link in multilink group control
    *  80fd            Compression Control Protocol
    *  80ff            Not Used - reserved                   [RFC1661]
    *  
    *  c021            Link Control Protocol
    *  c023            Password Authentication Protocol
    *  c025            Link Quality Report
    *  c027            Shiva Password Authentication Protocol
    *  c029            CallBack Control Protocol (CBCP)
    *  c081            Container Control Protocol                  [KEN]
    *  c223            Challenge Handshake Authentication Protocol
    *  c281            Proprietary Authentication Protocol         [KEN]
    *  c26f            Stampede Bridging Authorization Protocol
    *  c481            Proprietary Node ID Authentication Protocol [KEN]
    *  
    */
    