/*
	SDS011 dust sensor

	Compile with:
	-------------
	make

	References:
	-----------
	* https://web.archive.org/web/20160705112431/http://inovafitness.com/software/SDS011%20laser%20PM2.5%20sensor%20specification-V1.3.pdf
	* https://github.com/ryszard/sds011/blob/master/doc/Protocol_V1.3.docx
	* http://www.tldp.org/HOWTO/Serial-Programming-HOWTO/
	* https://www.cmrr.umn.edu/~strupp/serial.html
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <stdbool.h>

static const bool debug = false;

/* size of data packet */
#define MSG_SIZE    10
/* message header */
#define MSG_HDR     0xaa
/* data command */
#define MSG_DATA    0xc0
/* message tail */
#define MSG_TAIL    0xab

/* offsets in data packets */
enum {
	OFF_HDR = 0, /* message header                         */
	OFF_CMD,     /* command                                */
	OFF_DATA1,   /* PM 2.5 low byte                        */
	OFF_DATA2,   /* PM 2.5 high byte                       */
	OFF_DATA3,   /* PM 10 low byte                         */
	OFF_DATA4,   /* PM 10 high byte                        */
	OFF_DATA5,   /* ID byte 1                              */
	OFF_DATA6,   /* ID byte 2                              */
	OFF_CHK,     /* checksum = DATA1 + DATA2 + ... + DATA6 */
	OFF_TAIL     /* message tail                           */
};

/* directory for log files */
#define LOGDIR "/home/pi/sds011/logs"

int main(int argc, char *argv[])
{
	int fd, ret = EXIT_SUCCESS;
	struct termios opt;

	if (argc < 2) {
		fprintf(stderr, "Usage: %s /dev/ttyUSBx\n", argv[0]);
		ret = EXIT_FAILURE;
		goto error;
	}

	/* process isn't a controlling terminal, ignore DCD state */
	if ((fd = open(argv[1], O_RDWR | O_NOCTTY | O_NDELAY)) == -1) {
		perror("Error opening serial port");
		ret = EXIT_FAILURE;
		goto error;
	}

	/* we want read calls to block */
	if (fcntl(fd, F_SETFL, 0) == -1) {
		perror("fcntl");
		ret = EXIT_FAILURE;
		goto error;
	}

	/* get settings for serial port */
	if (tcgetattr(fd, &opt) == -1) {
		perror("tcgetattr");
		ret = EXIT_FAILURE;
		goto error;
	}

	/* 8 data bits */
	opt.c_cflag &= ~CSIZE;
	opt.c_cflag |= CS8;
	/* 1 stop bit */
	opt.c_cflag &= ~CSTOPB;
	/* enable receiver */
	opt.c_cflag |= CREAD;
	/* disable parity */
	opt.c_cflag &= ~PARENB;
	/* local line */
	opt.c_cflag |= CLOCAL;
	/* disable hardware control flow */
#ifdef CNEW_RTSCTS
	opt.c_cflag &= ~CNEW_RTSCTS;
#endif

	/* set baud rate to 9600 */
	if (cfsetispeed(&opt, B9600) == -1 || cfsetospeed(&opt, B9600) == -1) {
		perror("cfsetispeed/cfsetospeed");
		ret = EXIT_FAILURE;
		goto error;
	}

	/* raw input */
	opt.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
	/* no software flow control */
	opt.c_iflag &= ~(IXON | IXOFF | IXANY);

	/* raw output */
	opt.c_oflag &= ~OPOST;

	/* receive at least PACKET_SIZE bytes with read, no timer */
	opt.c_cc[VMIN] = MSG_SIZE;
	opt.c_cc[VTIME] = 0;

	/* apply settings to serial port and flush input/output buffers */
	if (tcsetattr(fd, TCSAFLUSH, &opt) == -1) {
		perror("tcsetattr");
		ret = EXIT_FAILURE;
		goto error;
	}

	uint8_t buf[MSG_SIZE];
	FILE *log = NULL;

	while (read(fd, buf, MSG_SIZE) > 0) {
		/* calculate checksum */
		uint8_t chksum = 0;
		for (int i = OFF_DATA1; i <= OFF_DATA6; ++i)
			chksum += buf[i];
		/* check if message is valid, otherwise discard it
		   and flush input buffer */
		if (buf[OFF_HDR] == MSG_HDR && buf[OFF_CMD] == MSG_DATA &&
		    buf[OFF_CHK] == chksum && buf[OFF_TAIL] == MSG_TAIL) {
			/* PM 2.5 (ug/m^3) */
			float pm25 = (buf[OFF_DATA2]<<8 | buf[OFF_DATA1])/10.f;
			/* PM 10  (ug/m^3) */
			float pm10 = (buf[OFF_DATA4]<<8 | buf[OFF_DATA3])/10.f;
			if (debug)
				printf("PM 2.5: %f, PM 10: %f\n", pm25, pm10);

			/* get time and date */
			time_t unix_time = time(NULL);
			struct tm *t = localtime(&unix_time);
			struct stat st;
			char logname[strlen(LOGDIR)+1+strlen("yyyy-mm-dd")+1];

			snprintf(logname, sizeof logname, "%s/%04d-%02d-%02d",
			         LOGDIR,
			         t->tm_year + 1900, t->tm_mon + 1, t->tm_mday);

			/* append to logfile if it already exists */
			if (log == NULL && stat(logname, &st) == 0)
				log = fopen(logname, "a");
			/* create new logfile at midnight */
			if (stat(logname, &st) == -1) {
				/* close old logfile */
				if (log)
					(void)fclose(log);
				if ((log = fopen(logname, "w")))
					fprintf(log, "# hh:mm:ss"
					        "\tPM2.5 / ug/m^3"
					        "\tPM10 / ug/m^3\n");
			}

			if (log)
				fprintf(log, "%02i:%02i:%02i\t%f\t%f\n",
				        t->tm_hour, t->tm_min, t->tm_sec,
					pm25, pm10);
		} else {
			tcflush(fd, TCIFLUSH);
			if (debug) {
				/* PM 2.5 (ug/m^3) */
				float pm25 = (buf[OFF_DATA2]<<8 | buf[OFF_DATA1])/10.f;
				/* PM 10  (ug/m^3) */
				float pm10 = (buf[OFF_DATA4]<<8 | buf[OFF_DATA3])/10.f;

				printf("PM 2.5: %f, PM 10: %f\n", pm25, pm10);
				fprintf(stderr, "header  : %s\n",
				        buf[OFF_HDR]==MSG_HDR?"pass":"fail");
				fprintf(stderr, "cmd     : %s\n",
				        buf[OFF_CMD]==MSG_DATA?"pass":"fail");
				fprintf(stderr, "checksum: %s\n",
				        buf[OFF_CHK]==chksum?"pass":"fail");
				if (buf[OFF_CHK] != chksum)
					fprintf(stderr, "checksum: 0x%02x, "
					        "expected: 0x%02x\n",
						buf[OFF_CHK], chksum);
				fprintf(stderr, "tail    : %s\n",
				        buf[OFF_TAIL]==MSG_TAIL?"pass":"fail");
			}
		}	
	}

error:
	return ret;
}
