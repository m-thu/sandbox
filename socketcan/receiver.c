// https://www.kernel.org/doc/Documentation/networking/can.txt

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/if.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[])
{
	int s = 0;
	int retval = EXIT_SUCCESS;
	struct sockaddr_can addr;
	struct ifreq ifr;

	if (argc != 2) {
		fprintf(stderr, "usage: %s canX\n", argv[0]);
		retval = EXIT_FAILURE;
		goto exit;
	}

	if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
		perror("socker");
		retval = EXIT_FAILURE;
		goto exit;
	}

	memset(&ifr, 0, sizeof ifr);
	strncpy(ifr.ifr_name, argv[1], sizeof ifr.ifr_name);
	if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
		perror("ioctl");
		retval = EXIT_FAILURE;
		goto exit;
	}

	addr.can_family = AF_CAN;
	addr.can_ifindex = ifr.ifr_ifindex;

	if (bind(s, (struct sockaddr *)&addr, sizeof addr) < 0) {
		perror("bind");
		retval = EXIT_FAILURE;
		goto exit;
	}
	printf("[ Interface: %s ]\n", argv[1]);

	uint8_t buf[sizeof(struct can_frame)];
	ssize_t len;

	for (;;) {
		if ((len = read(s, &buf, sizeof buf)) < 0) {
			perror("read");
			retval = EXIT_FAILURE;
			goto exit;
		}

		if ((size_t)len < sizeof(struct can_frame)) {
			printf("[ Received invalid CAN frame ]\n");
			continue;
		}

		struct can_frame *msg = (struct can_frame *)buf;
		printf("[ Received CAN frame, ID: %04x, LEN: %02x, ",
		       msg->can_id, msg->can_dlc);
		printf("PAYLOAD: ");
		for (uint8_t i = 0; i < msg->can_dlc; ++i) {
			if (isprint(msg->data[i]))
				putchar(msg->data[i]);
		}
		printf(" ]\n");
	}

exit:
	if (s) {
		if (close(s) < 0)
			perror("close");
	}
	return retval;
}
