#ifndef __GLOBAL
#define __GLOBAL

#define DEBUG
#ifdef	DEBUG


#ifdef GLOBAL_IMPL 
#	define	EXTERN
#	define	INITIALIZER	=0
#else
#	define	EXTERN	extern
#	define	INITIALIZER
#endif
EXTERN	const int debuglevel INITIALIZER;

#	define DEBUGPRINT(n,f)	(debuglevel>=(n) ? printf f : 0)
#	define DEBUGDUMP(n,f)	(debuglevel>=(n) ? dump f : 0)
#else
#	define DEBUGPRINT(n,f)
#	define DEBUGDUMP(n,f)
#endif

#endif /* __GLOBAL */



