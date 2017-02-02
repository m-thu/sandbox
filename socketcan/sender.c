// https://www.kernel.org/doc/Documentation/networking/can.txt

// Introduction to the Controller Area Network (CAN):
// http://www.ti.com/lit/an/sloa101a/sloa101a.pdf

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

	struct can_frame msg = {
		.can_id = 0x01,
		.can_dlc = 5,
		.data = {'H','e','l','l','o'}
	};

	for (int i = 0; i < 10; ++i) {
		printf("[ Sending message ... ]\n");
		if (write(s, &msg, sizeof msg) < 0) {
			perror("write");
			retval = EXIT_FAILURE;
			goto exit;
		}

		sleep(5);
	}

exit:
	if (s) {
		if (close(s) < 0)
			perror("close");
	}
	return retval;
}
