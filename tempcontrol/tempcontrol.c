#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <error.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <sys/stat.h>

/* DEBUG */
static const bool debug = false;

/* GPIO 27: Heater 1 (output) */
#define HEATER_1   "/sys/class/gpio/gpio27/value"
/* GPIO 22: Heater 2 (output) */
#define HEATER_2   "/sys/class/gpio/gpio22/value"
/* GPIO 16: Status LED (output) */
#define STATUS_LED "/sys/class/gpio/gpio16/value"

/* Directory containing log files */
#define LOG_DIR "/home/pi/logs"

/* Reference temperature sensor */
#define TEMP_REF    "/sys/bus/w1/devices/28-051691e533ff/w1_slave"
/* Tank 1 temperature sensor */
#define TEMP_TANK_1 "/sys/bus/w1/devices/28-0416927dcdff/w1_slave"
/* Tank 2 temperature sensor */
#define TEMP_TANK_2 "/sys/bus/w1/devices/28-051691e2c3ff/w1_slave"

/* Buffer size for reading 1-Wire sensors */
#define BUFSIZE_1W (4096)

/* Interval (s) between temperature readings */
#define INTERVAL (60)
/* Temperature difference reference tank <-> tank 1, tank 2 (K) */
#define TEMP_DIFF (2.f)

static void signal_handler(int);

/* Global, so signal handler can access file descriptors */
static int fd_heater_1, fd_heater_2, fd_status_led;

int main(int argc, char *argv[])
{
	int retval = EXIT_SUCCESS;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s tolerance\n", argv[0]);
		retval = EXIT_FAILURE;
		goto exit;
	}
	
	/* Tolerance (temperature) */
	float eps = 0.5f;
	char *endptr;
	if ((strtof(argv[1], &endptr) == 0.f) && (endptr == argv[1])) {
		fprintf(stderr, "Invalid value for tolerance!\n");
		retval = EXIT_FAILURE;
		goto exit;
	}
	if (debug)
		printf("Tolerance for temperature: %f K\n", eps);
	
	/* Set signal handler for SIGINT */
	struct sigaction sa;
	sigemptyset(&sa.sa_mask);
	sa.sa_handler = signal_handler;
	if (sigaction(SIGINT, &sa, NULL) < 0) {
		perror("sigaction");
		retval = EXIT_FAILURE;
		goto exit;
	}
	
	/* Open GPIO ports */
	if ((fd_heater_1 = open(HEATER_1, O_WRONLY)) < 0) {
		perror("open: fd_heater_1");
		retval = EXIT_FAILURE;
		goto exit;
	}
	if ((fd_heater_2 = open(HEATER_2, O_WRONLY)) < 0) {
		perror("open: fd_heater_2");
		retval = EXIT_FAILURE;
		goto exit;
	}
	if ((fd_status_led = open(STATUS_LED, O_WRONLY)) < 0) {
		perror("open: fd_status_led");
		retval = EXIT_FAILURE;
		goto exit;
	}
	
	/* Open 1-Wire temperature sensors */
	int fd_temp_ref, fd_temp_tank_1, fd_temp_tank_2;
	if ((fd_temp_ref = open(TEMP_REF, O_RDONLY)) < 0) {
		perror("open: fd_temp_ref");
		retval = EXIT_FAILURE;
		goto exit;
	}
	if ((fd_temp_tank_1 = open(TEMP_TANK_1, O_RDONLY)) < 0) {
		perror("open: fd_temp_tank_1");
		retval = EXIT_FAILURE;
		goto exit;
	}
	if ((fd_temp_tank_2 = open(TEMP_TANK_2, O_RDONLY)) < 0) {
		perror("open: fd_temp_tank_2");
		retval = EXIT_FAILURE;
		goto exit;
	}
	
	/* Main control loop */
	bool status_led = false;
	bool heater_1 = false, heater_2 = false;
	FILE *log = NULL;
	for (;;) {
		struct timespec start, stop;
		(void)clock_gettime(CLOCK_MONOTONIC, &start);
		
		/* Get time and open new logfile if necessary */
		time_t unix_time = time(NULL);
		struct tm *t = localtime(&unix_time);
		struct stat st;
		char logname[strlen(LOG_DIR)+1+strlen("dd-mm-yyyy")+1];

		snprintf(logname, sizeof logname, "%s/%02d-%02d-%04d",
		         LOG_DIR, t->tm_mday, t->tm_mon, t->tm_year + 1900);
		if (debug)
			printf("Logfile: '%s'\n", logname);
		if ((log == NULL) || (stat(logname, &st) == -1)) {
			if (log != NULL) {
				if (debug)
					printf("Closing old logfile.\n");
				(void)fclose(log);
			}
			/* Append to logfile, if it already exists */
			if ((log == NULL) && (stat(logname, &st) == 0)) {
				if (debug)
					printf("Appending to existing logfile.\n");
				log = fopen(logname, "a");
			}
			else if ((log = fopen(logname, "w"))) {
				if (debug)
					printf("Creating new logfile.\n");
				fprintf(log, "# Tolerance: %f, Temperature diff. : %f\n",
				        eps, TEMP_DIFF);
				fprintf(log, "# Time\tUnix time\tReference\tSet point\tTank 1\tTank 2\t"
				             "Heater 1\tHeater 2\n\n");
			}
		}
		
		/* Get temperature from sensors */
		char one_wire_ref[BUFSIZE_1W], one_wire_1[BUFSIZE_1W], one_wire_2[BUFSIZE_1W];
		float temp_ref = 0.f, temp_tank_1 = 0.f, temp_tank_2 = 0.f;
		
		memset(one_wire_ref, '\0', sizeof one_wire_ref);
		memset(one_wire_1, '\0', sizeof one_wire_1);
		memset(one_wire_2, '\0', sizeof one_wire_2);
		(void)read(fd_temp_ref, one_wire_ref, sizeof one_wire_ref);
		(void)read(fd_temp_tank_1, one_wire_1, sizeof one_wire_1);
		(void)read(fd_temp_tank_2, one_wire_2, sizeof one_wire_2);
		(void)lseek(fd_temp_ref, 0, SEEK_SET);
		(void)lseek(fd_temp_tank_1, 0, SEEK_SET);
		(void)lseek(fd_temp_tank_2, 0, SEEK_SET);

		/* Parse 1-Wire output */
		/*
		pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-0416927dcdff/w1_slave
		d2 00 4b 46 7f ff 0c 10 c1 : crc=c1 YES
		d2 00 4b 46 7f ff 0c 10 c1 t=13125
		pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-0416927dcdff/w1_slave
		3f 00 4b 46 7f ff 0c 10 ce : crc=ce YES
		3f 00 4b 46 7f ff 0c 10 ce t=3937
		pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-0416927dcdff/w1_slave
		ea ff 4b 46 7f ff 0c 10 11 : crc=11 YES
		ea ff 4b 46 7f ff 0c 10 11 t=-1375
		*/

		/* Check CRC for reference temp. */
		if (strstr(one_wire_ref, "YES") == NULL) {
			/* Retry on failure */
			if (debug)
				printf("CRC check for reference temp. failed!\n");
			continue;
		}
		/* Check CRC for tank 1 temp. */
		if (strstr(one_wire_1, "YES") == NULL) {
			/* Retry on failure */
			if (debug)
				printf("CRC check for tank 1 temp. failed!\n");
			continue;
		}
		/* Check CRC for tank 2 temp. */
		if (strstr(one_wire_2, "YES") == NULL) {
			/* Retry on failure */
			if (debug)
				printf("CRC check for tank 2 temp. failed!\n");
			continue;
		}

		char *s;
		/* Parse reference temp. */
		if ((s = strstr(one_wire_ref, "t="))) {
			temp_ref = strtol(s + 2, NULL, 10) / 1000.f;
			if (debug)
				printf("Reference temp.: %f degree C\n", temp_ref);
		} else {
			/* Retry on failure */
			if (debug)
				printf("Missing 't=' in reference temp. output!\n");
			continue;
		}
		/* Parse tank 1 temp. */
		if ((s = strstr(one_wire_1, "t="))) {
			temp_tank_1 = strtol(s + 2, NULL, 10) / 1000.f;
			if (debug)
				printf("Tank 1 temp.: %f degree C\n", temp_tank_1);
		} else {
			/* Retry on failure */
			if (debug)
				printf("Missing 't=' in tank 1 temp. output!\n");
			continue;
		}
		/* Parse tank 2 temp. */
		if ((s = strstr(one_wire_2, "t="))) {
			temp_tank_2 = strtol(s + 2, NULL, 10) / 1000.f;
			if (debug)
				printf("Tank 2 temp.: %f degree C\n", temp_tank_2);
		} else {
			/* Retry on failure */
			if (debug)
				printf("Missing 't=' in tank 2 temp. output!\n");
			continue;
		}

		/* Calculate new set point for tanks 1, 2 */
		float set_point = temp_ref + TEMP_DIFF;
		if (debug)
			printf("New set point: %f degree C\n", set_point);

		/* Control heaters */
		uint8_t buf;

		if (temp_tank_1 < (set_point - eps))
			heater_1 = true;
		if (temp_tank_1 > (set_point + eps))
			heater_1 = false;
		buf = '0' + heater_1;
		(void)write(fd_heater_1, &buf, sizeof buf);
		(void)lseek(fd_heater_1, 0, SEEK_SET);
		if (debug)
			printf("Heater 1: %s\n", heater_1 ? "ON" : "OFF");

		if (temp_tank_2 < (set_point - eps))
			heater_2 = true;
		if (temp_tank_2 > (set_point + eps))
			heater_2 = false;
		buf = '0' + heater_2;
		(void)write(fd_heater_2, &buf, sizeof buf);
		(void)lseek(fd_heater_2, 0, SEEK_SET);
		if (debug)
			printf("Heater 2: %s\n", heater_2 ? "ON" : "OFF");

		/* Log temperature values */
		if (log) {
			fprintf(log, "%02d:%02d:%02d\t%d\t",
			        t->tm_hour, t->tm_min, t->tm_sec, (int)unix_time);
			if (debug)
				printf("Time: %02d:%02d:%02d\t%d\n",
				       t->tm_hour, t->tm_min, t->tm_sec,
				       (int)unix_time);
			fprintf(log, "%f\t%f\t%f\t%f\t",
			        temp_ref, set_point, temp_tank_1, temp_tank_2);	
			fprintf(log, "%s\t%s\n",
			        heater_1 ? "ON" : "OFF",
				heater_2 ? "ON" : "OFF");
			fflush(log);
			sync();
		}

		/* Wait for INTERVAL seconds, blink status LED */
		struct timespec slp;
		slp.tv_sec = 0;
		slp.tv_nsec = 250000000; /* range 0 to 999999999 */
		do {
			uint8_t led = '0' + status_led;
			status_led = !status_led;
			(void)write(fd_status_led, &led, sizeof led);
			(void)lseek(fd_status_led, 0, SEEK_SET);
			(void)nanosleep(&slp, NULL);
			(void)clock_gettime(CLOCK_MONOTONIC, &stop);
		} while ((stop.tv_sec - start.tv_sec) < INTERVAL);
	}

exit:
	return retval;
}

static void signal_handler(int signal)
{
	(void)signal;

	/* Switch off heaters and status LED */
	uint8_t buf = '0';
	(void)write(fd_heater_1, &buf, sizeof buf);
	(void)write(fd_heater_2, &buf, sizeof buf);
	(void)write(fd_status_led, &buf, sizeof buf);
	
	exit(EXIT_SUCCESS);
}
