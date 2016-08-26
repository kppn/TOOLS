#include "stdio.h"
#include "string.h"

#define GTP      0
#define DIAMETER 1
#define PMIP     2
#define RADIUS   3

#define SGW      0
#define PGW      1

void node_disp()
{
    printf("               ¨£¨¡¨¡¨¡¨¡¨¤       ¨£¨¡¨¡¨¤       ¨£¨¡¨¡¨¤       ¨£¨¡¨¡¨¤       ¨£¨¡¨¡¨¡¨¤\n");
    printf("               ¨¢MME/SGSN¨¢       ¨¢S-GW¨¢       ¨¢P-GW¨¢       ¨¢PCRF¨¢       ¨¢Radius¨¢\n");
    printf("               ¨¦¨¡¨¡¨¡¨¡¨¥       ¨¦¨¡¨¡¨¥       ¨¦¨¡¨¡¨¥       ¨¦¨¡¨¡¨¥       ¨¦¨¡¨¡¨¡¨¥\n");
    printf("                    ¨¢               ¨¢             ¨¢             ¨¢              ¨¢    \n");

    return;
}

int data_disp(char* line1, char* line2, char* line3)
{
    char  mme_sgw[32];
    char  sgw_pgw[32];
    char  pgw_pcrf[32];
    char  pcrf_radius[32];
    char  time[16];
    char  signal[64];
    char* a_str;
    int   node;

    /* ½é´ü²½ */
    strcpy(mme_sgw, "               ¨¢");
    strcpy(sgw_pgw, "             ¨¢");
    strcpy(pgw_pcrf, "             ¨¢");
    strcpy(pcrf_radius, "              ¨¢");
    memset(time, '\0', sizeof(time));
    memset(signal, '\0', sizeof(signal));

    /* »þ´Ö¼èÆÀ */
    a_str = strstr(line2, "tm=");
    if (a_str == '\0')
    {
        return(1);
    }
    memcpy(time, a_str+3, 12);

    /* ¥á¥Ã¥»¡¼¥¸¼èÆÀ */
    a_str = strstr(line3, "sig=");
    if (a_str == '\0')
    {
        return(1);
    }
    strcpy(signal, a_str+4);

    /* ¥Î¡¼¥É¼èÆÀ */
    if (strstr(line2, "s-gw") != '\0')
    {
        node = SGW;
    }
    else if (strstr(line2, "p-gw") != '\0')
    {
        node = PGW;
    }
    else
    {
        return(1);
    }

    /* protocol¼èÆÀ */
    if (strstr(line1, "# GTP signal monitor #") != '\0')
    {
        /* Êý¸þ¼èÆÀ */
        if (strstr(line2, "rec") != '\0')
        {
            strcpy(mme_sgw, "-------------->¨¢");
        }
        else if (strstr(line2, "snd") != '\0')
        {
            strcpy(mme_sgw, "<--------------¨¢");
        }
        else
        {
            return(1);
        }

    }
    else if (strstr(line1, "# DIAMETER signal monitor #") != '\0')
    {
        /* Êý¸þ¼èÆÀ */
        if (strstr(line2, "rec") != '\0')
        {
            if (node == SGW)
            {
                strcpy(sgw_pgw,  "<--------------");
                strcpy(pgw_pcrf, "-------------¨¢");
            }
            else /* PGW */
            {
                strcpy(pgw_pcrf, "<------------¨¢");
            }
        }
        else if (strstr(line2, "snd") != '\0')
        {
            if (node == SGW)
            {
                strcpy(sgw_pgw,  "---------------");
                strcpy(pgw_pcrf, "------------>¨¢");
            }
            else /* PGW */
            {
                strcpy(pgw_pcrf, "------------>¨¢");
            }
        }
        else
        {
            return(1);
        }
    }
    else if (strstr(line1, "# PMIP signal monitor #") != '\0')
    {
        /* Êý¸þ¼èÆÀ */
        if (strstr(line2, "rec") != '\0')
        {
            if (node == SGW)
            {
                strcpy(sgw_pgw,  "<------------¨¢");
            }
            else /* PGW */
            {
                strcpy(sgw_pgw,  "------------>¨¢");
            }
        }
        else if (strstr(line2, "snd") != '\0')
        {
            if (node == SGW)
            {
                strcpy(sgw_pgw,  "------------>¨¢");
            }
            else /* PGW */
            {
                strcpy(sgw_pgw,  "<------------¨¢");
            }
        }
        else
        {
            return(1);
        }
    }
    else  /* RADIUS */
    {
        /* Êý¸þ¼èÆÀ */
        if (strstr(line2, "rec") != '\0')
        {
                strcpy(pgw_pcrf, "<--------------");
                strcpy(pcrf_radius, "--------------¨¢");
        }
        else if (strstr(line2, "snd") != '\0')
        {
                strcpy(pgw_pcrf, "---------------");
                strcpy(pcrf_radius, "------------->¨¢");
        }
        else
        {
            return(1);
        }
    }

    /* É½¼¨ */
    printf("12%s      ¨¢%s%s%s%s %s\n", time, mme_sgw, sgw_pgw, pgw_pcrf, pcrf_radius, signal);

    return(0);
}

int main(int argc, char** argv)
{
    unsigned char buf[4096];
    unsigned char line1[1024];
    unsigned char line2[1024];
    unsigned char line3[1024];
    char          filename[1024];
    FILE*         a_file;
    unsigned int  i;
    char*         a_str;
    char          msisdn[32];
    char          imsi[32];
    int           ret;

    if (argc != 2)
    {
        printf("¥Õ¥¡¥¤¥ëÌ¾¤¬É¬Í×¤Ç¤¹\n");
        printf("sig [filename]\n\n");
        return(0);
    } 

    strcpy(filename, argv[1]);

    a_file = fopen(filename, "r");

    if (a_file == '\0')
    {
        printf(" ----- File Open NG !!! -----\n");
        printf("   %s\n\n", filename);
        return(0);
    }

    /*  ¥Î¡¼¥ÉÉ½¼¨ */
    node_disp();

    while (fgets(buf, sizeof(buf)-1, a_file))
    {
        *strchr(buf, '\n') = '\0';

        /* ÂÐ¾ÝÈ½Äê */
        a_str = strstr(buf, "#.. signal_monitor_report");
        if (a_str != '\0')
        {
            /* msisdn or imsi */
            if (strstr(buf, "msisdn") != '\0')
            {
                strcpy(msisdn, a_str+7);
            }
            else
            {
                strcpy(imsi, a_str+5);
            }

            /* ¥Ç¡¼¥¿¼èÆÀ */
            for (i = 0; i < 3; i++)
            {
                if(*fgets(buf, sizeof(buf)-1, a_file) != EOF )
                {
                    *strchr(buf, '\n') = '\0';
                    if (i == 0)
                    {
                        strcpy(line1, &buf[18]);
                    }
                    else if (i == 1)
                    {
                        strcpy(line2, &buf[18]);
                    }
                    else
                    {
                        strcpy(line3, &buf[18]);
                    }
                    
                }
                else
                {
                    break;
                }
            }

            /* ¥Ç¡¼¥¿É½¼¨ */
            ret = data_disp(line1, line2, line3);
            if (ret == 1)
            {
            }
        }
    }

    return(0);
}
