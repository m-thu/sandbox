// Linux Cross Reference: http://lxr.free-electrons.com/
// FreeBSD and Linux Kernel Cross-Reference: http://fxr.watson.org/
// https://www.kernel.org/doc/, https://www.kernel.org/doc/Documentation/

// RFC 7414
// A Roadmap for Transmission Control Protocol (TCP)
// https://tools.ietf.org/html/rfc7414

// TUN/TAP devices: https://www.kernel.org/doc/Documentation/networking/tuntap.txt

// /usr/include/linux/if_ether.h, https://en.wikipedia.org/wiki/Ethernet_frame

// /usr/include/net/if_arp.h

// RFC 826
// An Ethernet Address Resolution Protocol
// https://tools.ietf.org/html/rfc826

// /usr/include/netinet/ip.h
// /usr/include/netinet/in.h

// RFC 791
// INTERNET PROTOCOL
// https://tools.ietf.org/html/rfc791

// RFC 1071
// Computing the Internet Checksum
// https://tools.ietf.org/html/rfc1071

// /usr/include/netinet/ip_icmp.h

// RFC 792
// INTERNET CONTROL MESSAGE PROTOCOL
// https://tools.ietf.org/html/rfc792

// Convert binary packet dump for wireshark: 'od -Ax -tx1 -v packet.bin >packet.hex'

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/if_tun.h>
#include <errno.h>
#include <string.h>
#include <signal.h>

/* Host to network byteorder (big endian) functions */
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__

static inline uint32_t __htonl(uint32_t hostlong)
{
	return __builtin_bswap32(hostlong);
}

static inline uint16_t __htons(uint16_t hostshort)
{
	return __builtin_bswap16(hostshort);
}

static inline uint32_t __ntohl(uint32_t netlong)
{
	return __builtin_bswap32(netlong);
}

static inline uint16_t __ntohs(uint16_t netshort)
{
	return __builtin_bswap16(netshort);
}

#else

static inline uint32_t __htonl(uint32_t hostlong)
{
	return hostlong;
}

static inline uint16_t __htons(uint16_t hostshort)
{
	return hostshort;
}

static inline uint32_t __ntohl(uint32_t netlong)
{
	return netlong;
}

static inline uint16_t __ntohs(uint16_t netshort)
{
	return netshort;
}

/* #if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ */
#endif

/* Number of bytes in MAC address */
#define ADDR_MAC_LEN 6

/* Number of bytes in IP address */
#define ADDR_IP4_LEN 4

/* Our MAC address */
static const uint8_t my_mac[] = {0x00,0x11,0x22,0x33,0x44,0x55};
/* Our IP address */
static const uint8_t my_ip[] = {10, 0, 0, 2};
//static const uint8_t my_ip[] = {172, 16, 0, 2};

static const uint8_t bcast_mac[] = {0xff,0xff,0xff,0xff,0xff,0xff};
static const uint8_t test_ip[] = {10, 0, 0, 1};

/* Ethernet frame header (layer 2) */
struct eth_header {
	uint8_t  dst[ADDR_MAC_LEN]; /* destination MAC             */
	uint8_t  src[ADDR_MAC_LEN]; /* source MAC                  */
	uint16_t proto            ; /* ethertype or payload length */
} __attribute__((packed));

/* Payload length: 46-1500 octets */

#define MIN_PAYLOAD_LEN 46UL
#define MAX_PAYLOAD_LEN 1500UL

/* max. length of ethernet frame (layer 2) including Frame Check Sequence (FCS) */
#define ETH_FRAME_MAX 1518

/* ethertype values */
#define ETH_PROTO_IP   0x0800
#define ETH_PROTO_ARP  0x0806
#define ETH_PROTO_IPV6 0x86dd

static const char *ETH_PROTO(uint16_t proto)
{
	switch (__ntohs(proto)) {
	case ETH_PROTO_IPV6:
		return "IPV6   ";
	case ETH_PROTO_IP:
		return "IP     ";
	case ETH_PROTO_ARP:
		return "ARP    ";
	default:
		return "UNKNOWN";
	}
}

/* ARP header */
struct arp_header {
	uint16_t hw;       /* format hardware address */
	uint16_t pro;      /* format protocol address */
	uint8_t  hw_len;   /* length hardware address */
	uint8_t  pro_len;  /* length protocol address */
	uint16_t opcode;   /* ARP command             */
} __attribute__((packed));

/* hw values */
#define ARP_HW_ETHER 1

static const char *ARP_HW(uint16_t hw)
{
	switch (__ntohs(hw)) {
	case ARP_HW_ETHER:
		return "HW_ETHER";
	default:
		return "UNKNOWN";
	}
}

/* pro values */
#define ARP_PRO_IPV4 0x0800

static const char *ARP_PRO(uint16_t pro)
{
	switch (__ntohs(pro)) {
	case ARP_PRO_IPV4:
		return "IPV4   ";
	default:
		return "UNKNOWN";
	}
}

/* opcode values */
#define ARP_OP_REQUEST  1 /* ARP request  */
#define ARP_OP_REPLY    2 /* APR reply    */
#define ARP_OP_RREQUEST 3 /* RARP request */
#define ARP_OP_RREPLY   4 /* RARP reply   */

static const char *ARP_OP(uint16_t opcode)
{
	switch (__ntohs(opcode)) {
	case ARP_OP_REQUEST:
		return "REQUEST ";
	case ARP_OP_REPLY:
		return "REPLY   ";
	case ARP_OP_RREQUEST:
		return "RREQUEST";
	case ARP_OP_RREPLY:
		return "RREPLY  ";
	default:
		return "UNKNOWN ";
	}
}

/* IPV4 ARP request */
struct arp_ipv4 {
	uint8_t src   [ADDR_MAC_LEN]; /* sender MAC address */
	uint8_t src_ip[ADDR_IP4_LEN]; /* sender IP address  */
	uint8_t dst   [ADDR_MAC_LEN]; /* target MAC address */
	uint8_t dst_ip[ADDR_IP4_LEN]; /* target IP address  */
} __attribute__((packed));

/*  ARP table entry */
struct arp_entry {
	uint8_t mac[ADDR_MAC_LEN];
	uint8_t ip [ADDR_IP4_LEN];
};

/* IP V4 header */
struct ipv4_header {
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	/* hlen: number of 32 bit words */
	unsigned int hlen : 4;      /* header length           */
	unsigned int ver  : 4;      /* IP version              */
#else
	unsigned int ver  : 4;      /* IP version              */
	unsigned int hlen : 4;      /* header length           */
#endif
	uint8_t  tos;               /* type of service         */
	uint16_t len;               /* total length            */
	uint16_t id;                /* identification          */
	uint16_t frag_off;          /* fragment offset + flags */
	uint8_t  ttl;               /* time to live            */
	uint8_t  prot;              /* protocol                */
	uint16_t chksum;            /* IP checksum (header)    */
	uint8_t  src[ADDR_IP4_LEN]; /* source IP address       */
	uint8_t  dst[ADDR_IP4_LEN]; /* destination IP address  */
} __attribute__((packed));

/* frag_off values (contains flags) */
#define IP4_FRAG_RF   0x8000 /* reserved         */
#define IP4_FRAG_DF   0x4000 /* don't fragment   */
#define IP4_FRAG_MF   0x2000 /* more fragments   */
#define IP4_FRAG_MASK 0x1fff /* mask offset part */

static const char *IP4_FRAG(uint16_t frag_off)
{
	switch (__ntohs(frag_off) & ~IP4_FRAG_MASK) {
	case IP4_FRAG_RF:
		return "RF";
	case IP4_FRAG_DF:
		return "DF";
	case IP4_FRAG_MF:
		return "MF";
	/* suppress compiler warning */
	default:
		return "";
	}
}

/* prot values */
#define IP4_PROT_IP        0
#define IP4_PROT_ICMP      1
#define IP4_PROT_IGMP      2
#define IP4_PROT_IPIP      4
#define IP4_PROT_TCP       6
#define IP4_PROT_EGP       8
#define IP4_PROT_PUP      12
#define IP4_PROT_UDP      17
#define IP4_PROT_IDP      22
#define IP4_PROT_TP       29
#define IP4_PROT_DCCP     33
#define IP4_PROT_IPV6     41
#define IP4_PROT_RSVP     46
#define IP4_PROT_GRE      47
#define IP4_PROT_ESP      50
#define IP4_PROT_AH       51
#define IP4_PROT_MTP      92
#define IP4_PROT_BEETPH   94
#define IP4_PROT_ENCAP    98
#define IP4_PROT_PIM     103
#define IP4_PROT_COMP    108
#define IP4_PROT_SCTP    132
#define IP4_PROT_UDPLITE 136

/* IPV4 ICMP header */
struct icmp_v4_header {
	uint8_t  type;   /* message type              */
	uint8_t  code;   /* type sub-code             */
	uint16_t chksum; /* checksum (header+payload) */
} __attribute__((packed));

/* values for type */
#define ICMP_V4_ECHOREPLY       0
#define ICMP_V4_DEST_UNREACH    3
#define ICMP_V4_SOURCE_QUENCH   4
#define ICMP_V4_REDIRECT        5
#define ICMP_V4_ECHO            8
#define ICMP_V4_TIME_EXCEEDED  11
#define ICMP_V4_PARAMETERPROB  12
#define ICMP_V4_TIMESTAMP      13
#define ICMP_V4_TIMESTAMPREPLY 14
#define ICMP_V4_INFO_REQUEST   15
#define ICMP_V4_INFO_REPLY     16
#define ICMP_V4_ADDRESS        17
#define ICMP_V4_ADDRESSREPLY   18

/* ICMP echo/reply message */
struct icmp_v4_echo {
	uint16_t id;  /* identifier      */
	uint16_t seq; /* sequence number */
} __attribute__((unused));

static void receive(uint8_t *, size_t);
static void transmit(uint8_t *, uint8_t *, uint16_t, uint8_t *, size_t);
static void arp(uint8_t *, size_t);
static void send_arp_reply(uint8_t *, uint8_t *);
static void send_arp_request(uint8_t *);
static void ip4(uint8_t *, size_t);
static uint16_t ipv4_chksum(uint8_t *, size_t);
static void sigint(int);

/* Global variables */

static int fd;

/* Maximum number of entries in ARP table */
#define ARP_TABLE_MAX 32

static struct arp_entry arp_table[ARP_TABLE_MAX];
/* Points to next free entry in ARP table */
static int arp_tbl_idx;

int main(int argc, char *argv[])
{
	(void)argc;
	(void)argv;

	int retval = EXIT_SUCCESS;

	struct sigaction sa;

	sigemptyset(&sa.sa_mask);
	sa.sa_flags = 0;
	sa.sa_handler = sigint;

	if (sigaction(SIGINT, &sa, NULL) < 0) {
		perror("sigaction");
		retval = EXIT_FAILURE;
		goto exit;
	}

	struct ifreq ifr;

	if ((fd = open("/dev/net/tap", O_RDWR)) < 0) {
		perror("open");
		retval = EXIT_FAILURE;
		goto exit;
	}

	memset(&ifr, 0, sizeof ifr);
	ifr.ifr_flags = IFF_TAP | IFF_NO_PI;

	if (ioctl(fd, TUNSETIFF, &ifr) < 0) {
		perror("ioctl");
		retval = EXIT_FAILURE;
		goto exit_close_fd;
	}

	printf("[ opened TAP device %s ]\n", ifr.ifr_name);

	uint8_t buf[ETH_FRAME_MAX];
	ssize_t in;

	for (;;) {
		while ((in = read(fd, buf, ETH_FRAME_MAX)) > 0) {
			receive(buf, in);
		}
	}

	if (in < 0)
		perror("read");

exit_close_fd:
	if (close(fd) < 0) {
		perror("close");
		retval = EXIT_FAILURE;
	}

	printf("[ closed TAP device %s]\n", ifr.ifr_name);

exit:
	return retval;
}

static void receive(uint8_t *rx, size_t len)
{
	struct eth_header *h = (struct eth_header *)rx;

	if (len < sizeof(struct eth_header)) {
		printf("[ invalid packet (length < ethernet header) ]\n");
		return;
	}

	printf("[ SRC: %02x:%02x:%02x:%02x:%02x:%02x,"
	       " DST: %02x:%02x:%02x:%02x:%02x:%02x,"
	       " TYPE: %s ]\n",
	       h->src[0], h->src[1], h->src[2], h->src[3], h->src[4], h->src[5],
	       h->dst[0], h->dst[1], h->dst[2], h->dst[3], h->dst[4], h->dst[5],
	       ETH_PROTO(h->proto));

	switch (__ntohs(h->proto)) {
	case ETH_PROTO_ARP:
		arp(rx, len);
		break;
	case ETH_PROTO_IP:
		ip4(rx, len);
		break;
	}
}

static void arp(uint8_t *rx, size_t len)
{
	(void)len;

	struct arp_header *h = (struct arp_header *)
	                       (rx + sizeof(struct eth_header));

	printf("[ |ARP| HW: %s, PRO: %s, HW_LEN: %u, PRO_LEN: %u, "
	       "OPCODE: %s ]\n",
	       ARP_HW(h->hw), ARP_PRO(h->pro), h->hw_len, h->pro_len,
	       ARP_OP(h->opcode));

	struct arp_ipv4 *a = (struct arp_ipv4 *)
	                     (rx + sizeof(struct eth_header)
	                         + sizeof(struct arp_header));

	printf("[ |ARP PAYLOAD| SRC: %02x:%02x:%02x:%02x:%02x:%02x,"
	       " SRC IP: %u.%u.%u.%u,"
	       " DST: %02x:%02x:%02x:%02x:%02x:%02x,"
	       " DST IP: %u.%u.%u.%u ]\n",
	       a->src[0], a->src[1], a->src[2],
	       a->src[3], a->src[4], a->src[5],
	       a->src_ip[0], a->src_ip[1], a->src_ip[2], a->src_ip[3],
	       a->dst[0], a->dst[1], a->dst[2],
	       a->dst[3], a->dst[4], a->dst[5],
	       a->dst_ip[0], a->dst_ip[1], a->dst_ip[2], a->dst_ip[3]);

	if (__ntohs(h->hw) != ARP_HW_ETHER) {
		printf("[ wrong HW! ]\n");
		return;
	}
	if (h->hw_len != ADDR_MAC_LEN) {
		printf("[ wrong HW_LEN! ]\n");
		return;
	}
	if (__ntohs(h->pro) != ARP_PRO_IPV4) {
		printf("[ wrong PRO! ]\n");
		return;
	}
	if (h->pro_len != ADDR_IP4_LEN) {
		printf("[ wrong PRO_LEN! ]\n");
		return;
	}

	bool merge = false;

	/* Update ARP table if it already contains the sender IP */
	for (int i = 0; i < arp_tbl_idx; ++i) {
		if (memcmp(arp_table[i].ip, a->src_ip, ADDR_IP4_LEN) == 0) {
			printf("[ updating ARP table entry for "
			       "%u.%u.%u.%u ]\n",
			       a->src_ip[0], a->src_ip[1],
			       a->src_ip[2], a->src_ip[3]);
			memcpy(arp_table[i].mac, a->src, ADDR_MAC_LEN);
			merge = true;
		}
	}

	/* Check if ARP packet is for us */
	if (memcmp(a->dst_ip, my_ip, ADDR_IP4_LEN) == 0) {
		/* Add entry to ARP table if it doesn't exist yet */
		if (!merge) {
			printf("[ adding ARP table entry for "
			       "%u.%u.%u.%u ]\n",
			       a->src_ip[0], a->src_ip[1],
			       a->src_ip[2], a->src_ip[3]);
			memcpy(arp_table[arp_tbl_idx].ip, a->src_ip,
			       ADDR_IP4_LEN);
			memcpy(arp_table[arp_tbl_idx].mac, a->src,
			       ADDR_MAC_LEN);

			++arp_tbl_idx;
			arp_tbl_idx %= ARP_TABLE_MAX;
		}

		/* Send reply, if operation is an ARP request */
		if (__ntohs(h->opcode) == ARP_OP_REQUEST) {
			printf("[ sending ARP reply to %u.%u.%u.%u ]\n",
			       a->src_ip[0], a->src_ip[1],
			       a->src_ip[2], a->src_ip[3]);
			send_arp_reply(a->src, a->src_ip);
		}
	}
}

static void send_arp_reply(uint8_t *mac, uint8_t *ip)
{
	uint8_t r[sizeof(struct arp_header)
		  + sizeof(struct arp_ipv4)];
	struct arp_header *h = (struct arp_header *)r;
	struct arp_ipv4 *a = (struct arp_ipv4 *)
	                     (r + sizeof(struct arp_header));

	/* ARP header */
	h->hw      = __htons(ARP_HW_ETHER);
	h->pro     = __htons(ARP_PRO_IPV4);
	h->hw_len  = ADDR_MAC_LEN;
	h->pro_len = ADDR_IP4_LEN;
	h->opcode  = __htons(ARP_OP_REPLY);

	/* ARP reply */
	memcpy(a->src   , my_mac, ADDR_MAC_LEN);
	memcpy(a->src_ip, my_ip , ADDR_IP4_LEN);
	memcpy(a->dst   , mac   , ADDR_MAC_LEN);
	memcpy(a->dst_ip, ip    , ADDR_IP4_LEN);

	transmit(mac, (uint8_t *)my_mac, ETH_PROTO_ARP, r, sizeof r);
}

static void send_arp_request(uint8_t *ip)
{
	uint8_t r[sizeof(struct arp_header)
	          + sizeof(struct arp_ipv4)];
	struct arp_header *h = (struct arp_header *)r;
	struct arp_ipv4 *a = (struct arp_ipv4 *)
	                     (r + sizeof(struct arp_header));

	/* ARP header */
	h->hw      = __htons(ARP_HW_ETHER);
	h->pro     = __htons(ARP_PRO_IPV4);
	h->hw_len  = ADDR_MAC_LEN;
	h->pro_len = ADDR_IP4_LEN;
	h->opcode  = __htons(ARP_OP_REQUEST);

	/* ARP request */
	memcpy(a->src   , my_mac, ADDR_MAC_LEN);
	memcpy(a->src_ip, my_ip , ADDR_IP4_LEN);
	memset(a->dst   , 0xff  , ADDR_MAC_LEN);
	memcpy(a->dst_ip, ip    , ADDR_IP4_LEN);

	transmit((uint8_t *)bcast_mac, (uint8_t *)my_mac, ETH_PROTO_ARP, r,
	         sizeof r);
}

static void transmit(uint8_t *dst, uint8_t *src, uint16_t proto,
                     uint8_t *tx, size_t len)
{
	uint8_t  buf[sizeof(struct eth_header) + len];
	struct eth_header *h = (struct eth_header *)buf;

	/* Ethernet header */
	memset(buf, 0, sizeof buf);
	memcpy(h->dst, dst, ADDR_MAC_LEN);
	memcpy(h->src, src, ADDR_MAC_LEN);
	h->proto = __htons(proto);

	/* Payload */
	memcpy(buf + sizeof(struct eth_header), tx, len);

	if (write(fd, buf, sizeof buf) < 0) {
		perror("write");
		exit(EXIT_FAILURE);
	}
}

static void ip4(uint8_t *rx, size_t len)
{
	(void)len;

	struct ipv4_header *h = (struct ipv4_header *)
	                        (rx + sizeof(struct eth_header));
	uint16_t chksum;

	if (h->ver != 4) {
		printf("[ wrong IP protocol version! ]\n");
		return;
	}

	chksum = ipv4_chksum(rx + sizeof(struct eth_header),
	                     h->hlen * 4);
	if (chksum) {
		printf("[ invalid checksum ! ]\n");
		return;
	}

	printf("[ |IPV4| SRC: %u.%u.%u.%u, DST: %u.%u.%u.%u, TOS: %02x, "
	       "LEN: %04x, ID: %04x, FRAG: %04x, FLAG: %s, TTL: %u, "
	       "PROT: %02x, CHKSUM: %04x ]\n",
	       h->src[0], h->src[1], h->src[2], h->src[3],
	       h->dst[0], h->dst[1], h->dst[2], h->dst[3],
	       h->tos, __ntohs(h->len), __ntohs(h->id),
	       __ntohs(h->frag_off) & IP4_FRAG_MASK,
	       IP4_FRAG(h->frag_off), h->ttl, h->prot, __ntohs(h->chksum));
}

static uint16_t ipv4_chksum(uint8_t *buf, size_t len)
{
	uint32_t sum = 0;

	while (len > 1) {
		sum += buf[0]<<8 | buf[1];
		len -= 2;
		buf += 2;
       }

	if (len)
		sum += *buf;

	while (sum >> 16)
		sum = (sum & 0xffff) + (sum >> 16);

	return ~sum;
}

static void sigint(int sig)
{
	(void)sig;
	exit(EXIT_SUCCESS);
}
