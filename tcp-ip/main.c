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

/* Ethernet frame header (layer 2) */
struct eth_header {
	uint8_t  dst  [6]; /* destination MAC             */
	uint8_t  src  [6]; /* source MAC                  */
	uint16_t proto   ; /* ethertype or payload length */
} __attribute__((packed));

/* Payload length: 46-1500 octets */

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
	uint8_t src   [6]; /* sender MAC address */
	uint8_t src_ip[4]; /* sender IP address  */
	uint8_t dst   [6]; /* target MAC address */
	uint8_t dst_ip[4]; /* target IP address  */
} __attribute__((packed));

static void receive(uint8_t *, size_t);
static void arp(uint8_t *, size_t);
static void ip4(uint8_t *, size_t);
static void sigint(int);

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
	int fd;

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

	printf("[ opened TAP device %s]\n", ifr.ifr_name);

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
		printf("[ invalid packet (len < ethernet header) ]\n");
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

	printf("[ ARP HW: %s, PRO: %s, HW_LEN: %u, PRO_LEN: %u, OPCODE: %s ]\n",
	       ARP_HW(h->hw), ARP_PRO(h->pro), h->hw_len, h->pro_len,
	       ARP_OP(h->opcode));

	struct arp_ipv4 *a = (struct arp_ipv4 *)
	                     (rx + sizeof(struct eth_header)
	                         + sizeof(struct arp_header));

	printf("[ PAYLOAD SRC: %02x:%02x:%02x:%02x:%02x:%02x,"
	       " SRC IP: %u.%u.%u.%u,"
	       " DST: %02x:%02x:%02x:%02x:%02x:%02x,"
	       " DST IP: %u.%u.%u.%u ]\n\n",
	       a->src[0], a->src[1], a->src[2],
	       a->src[3], a->src[4], a->src[5],
	       a->src_ip[0], a->src_ip[1], a->src_ip[2], a->src_ip[3],
	       a->dst[0], a->dst[1], a->dst[2],
	       a->dst[3], a->dst[4], a->dst[5],
	       a->dst_ip[0], a->dst_ip[1], a->dst_ip[2], a->dst_ip[3]);
}

static void ip4(uint8_t *rx, size_t len)
{
	(void)rx;
	(void)len;
}

static void sigint(int sig)
{
	(void)sig;
	exit(EXIT_SUCCESS);
}
