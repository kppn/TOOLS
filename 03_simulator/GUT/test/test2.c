#include <sys/socket.h>
#include <netinet/in.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * @brief 送信元指定sendmsg
 *
 * @arg s ソケット(UDP限定?)
 * @arg msg 送信したいメッセージ本体
 * @arg msglen msgの長さ
 * @arg daddr_sin 宛先アドレス(sockaddr_in6構造体なのてポートもここで指定)
 * @arg saddr 送信元アドレス．NULLであれば指定しない
 * @arg ifindex 送信インターフェース
 *
 * saddrは必ず自身についている物理アドレスから選択すること．
 * 必ずしもifindexと対応している必要はない(リンクローカルアドレスの場合は例外)．
 * Copyright (C) 2005 tak5219
 */
int
sendmsg_with_dstaddr(int s, char *msg, size_t msglen,
                struct sockaddr_in6 *daddr_sin, struct in6_addr *saddr, int ifindex)
{
        int err, cmsglen;
        int on = 1, tmp;
        struct msghdr msghdr;
        struct cmsghdr *cmsg;
        struct iovec iov;
        struct in6_pktinfo *pinfo;
        size_t vlen;

        /* 制御メッセージ設定(IPV6_PKTINFOのみ) */
        cmsglen = CMSG_SPACE(sizeof(*pinfo));
        cmsg = malloc(cmsglen);
        if (cmsg == NULL)
        {
                perror("malloc");
                err = -1;
                goto out2;
        }
        memset(cmsg, 0, cmsglen);
        cmsg->cmsg_len = CMSG_LEN(sizeof(*pinfo));
        cmsg->cmsg_level = IPPROTO_IPV6;
        cmsg->cmsg_type = IPV6_PKTINFO;
        pinfo = (struct in6_pktinfo *)CMSG_DATA(cmsg);

        /* in6_pktinfo構造体設定 */
        memset(pinfo, 0, sizeof(*pinfo));
        memcpy(&pinfo->ipi6_addr, saddr, sizeof(*saddr));
        pinfo->ipi6_ifindex = ifindex;

        /* メッセージ設定 */
        iov.iov_base = msg;
        iov.iov_len = msglen;
        memset(&msghdr, 0, sizeof(msghdr));
        msghdr.msg_control = cmsg;
        msghdr.msg_controllen = cmsglen;
        msghdr.msg_iov = &iov;
        msghdr.msg_iovlen = 1;
        msghdr.msg_name = (void *)daddr_sin;
        msghdr.msg_namelen = sizeof(*daddr_sin);

        /* ソケットオプション保存 */
        vlen = sizeof(int);
        err = getsockopt(s, IPPROTO_IPV6, IPV6_PKTINFO, &tmp, &vlen);
        if (err < 0) {
                perror("getsockopt");
                goto out1;
        }
        /* ソケットオプション設定 */
        err = setsockopt(s, IPPROTO_IPV6, IPV6_PKTINFO, &on, sizeof(int));
        if (err < 0) {
                perror("setsockopt");
                goto out1;
        }

        /* 送信！ */
        err = sendmsg(s, &msghdr, 0);
        if (err < 0) {
                perror("sendmsg");
        }

        /* ソケットオプション元に戻す */
	/*
        err = setsockopt(s, IPPROTO_IPV6, IPV6_PKTINFO, &tmp, sizeof(int));
        if (err < 0) {
                perror("setsockopt");
                goto out1;
        }
out1:
        free(cmsg);
out2:
        return err;
}

int main(int argc, char **argv)
{
        int s, ret;
        char buf[10];
        struct sockaddr_in6 daddr_sin;
        struct in6_addr saddr;

        s = socket(PF_INET6, SOCK_DGRAM, 0);
        if (s < 0)
        {
                perror("socket");
                exit(-1);
        }

        memset(&daddr_sin, 0, sizeof(daddr_sin));
        daddr_sin.sin6_family = AF_INET6;
        inet_pton(AF_INET6, "8765:4321::dead:beef", &daddr_sin.sin6_addr);
        daddr_sin.sin6_port = htons(53);

        inet_pton(AF_INET6, "1234:5678::fade:cafe", &saddr);

        ret = sendmsg_with_dstaddr(s, buf, 10, &daddr_sin, &saddr, 0);
        if (ret < 0)
        {
                printf("エラー\n");
        }

        return 0;

}
