/*
   *****************************************************
   Sensirion SHT21 userspace driver for BeagleBone Black
   *****************************************************

   Compile with:
   -------------
   gcc -Os -pedantic -Wall -Wextra -std=c99 -o beaglebone_sht21 beaglebone_sht21.c


   Wiring (http://beagleboard.org/static/images/cape-headers.png):
   ---------------------------------------------------------------
   BeagleBone               SHT21

   P9.1  DGND     --------  VSS
   P9.3  VDD_3V3  --------  VDD
   P9.19 I2C2_SCL --------  SCL
   P9.20 I2C2_SDA --------  SDA


   References:
   -----------
   * Datasheet SHT21 -- Humidity and Temperature Sensor IC:
     https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity_Sensors/Sensirion_Humidity_Sensors_SHT21_Datasheet_V4.pdf
   * CRC Checksum Calculation For Safe Communication with SHT 2x Sensors:
     https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity_Sensors/Sensirion_Humidity_Sensors_SHT2x_CRC_Calculation_V1.pdf
   * Electronic Identification Code -- How to read out the serial number of SHT2x:
     https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity_Sensors/Sensirion_Humidity_Sensors_SHT2x_Electronic_Identification_Code_V1.1.pdf
   * Datasheet Evaluation Kit EK-H5:
     https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity_Sensors/Sensirion_Humidity_Sensors_EK-H5_Datasheet_V4.pdf
   * https://www.kernel.org/doc/Documentation/i2c/dev-interface
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <linux/i2c-dev.h>
#include <linux/i2c.h>

#define I2C_DEV_FILE     "/dev/i2c-1"
#define SHT21_SLAVE_ADDR 0x40

/* SHT21 I2C commands */
#define CMD_TRIGGER_T_HOLD  0xe3
#define CMD_TRIGGER_RH_HOLD 0xe5
#define CMD_TRIGGER_T       0xf3
#define CMD_TRIGGER_RH      0xf5
#define CMD_WRITE_USER_REG  0xe6
#define CMD_READ_USER_REG   0xe7
#define CMD_SOFT_RESET      0xfe

/* SHT21 User Register */
enum {
	/*
	   Bit 7,0: Measurement resolution
	   (default 00)
	*/
	RH_12_T_14 = 0x00,
	RH_8_T_12  = 0x01,
	RH_10_T_13 = 0x80,
	RH_11_T_11 = 0x81,

	/*
	   Bit 6: Status: End of battery
	   0: VDD > 2.25 V
	   1: VDD < 2.25 V
	*/
	END_OF_BATTERY = 0x40,

	/*
	   Bit 3,4,5: reserved
	*/

	/*
	   Bit 2: Enable on-chip heater
	*/
	ENABLE_HEATER = 0x04,

	/*
	   Bit 1: Disable OTP Reload
	   (default 1)
	*/
	DISABLE_OTP_RELOAD = 0x2
};

uint64_t read_serial(int);
uint8_t read_user_register(int);
void write_user_register(int, uint8_t);
float get_temp(int fd);
float get_rh(int fd);

int main()
{
	int fd;
	unsigned long funcs;
	uint8_t reg;

	if ((fd = open(I2C_DEV_FILE, O_RDWR)) < 0) {
		perror("open");
		exit(EXIT_FAILURE);
	}

	/* set slave address */
	if (ioctl(fd, I2C_SLAVE, SHT21_SLAVE_ADDR) < 0) {
		perror("ioctl");
		exit(EXIT_FAILURE);
	}

	if (ioctl(fd, I2C_FUNCS, &funcs) < 0) {
		perror("ioctl");
		exit(EXIT_FAILURE);
	}
	if (!(funcs & I2C_FUNC_I2C)) {
		fprintf(stderr, "adapter doesn't support combined read/write "\
		        "transactions without stop!\n");
		exit(EXIT_FAILURE);
	}

	printf("SHT21 serial number: %" PRIx64 "\n", read_serial(fd));

	/* set RH resolution to 12 bit, T resolution to 14 bit */
	reg = read_user_register(fd);
	reg &= ~RH_11_T_11;
	write_user_register(fd, reg);
	reg = read_user_register(fd);
	printf("User register: %02x\n\n", reg);

	for (;;) {
		printf("T: %.2f\tRH: %.1f\n", get_temp(fd), get_rh(fd));
		sleep(1);
	}

	close(fd);
	return 0;
}

uint64_t read_serial(int fd)
{
	struct i2c_rdwr_ioctl_data ioctl_data;
	struct i2c_msg msg[2];
	uint8_t cmd[2];
	uint8_t data[8];
	uint64_t res;

	/* get first part of serial number */
	cmd[0] = 0xfa;
	cmd[1] = 0x0f;

	msg[0].addr = SHT21_SLAVE_ADDR;
	msg[0].flags = 0x0000;
	msg[0].len = sizeof cmd;
	msg[0].buf = cmd;

	msg[1].addr = SHT21_SLAVE_ADDR;
	msg[1].flags = I2C_M_RD;
	msg[1].len = sizeof data;
	msg[1].buf = data;

	ioctl_data.msgs = msg;
	ioctl_data.nmsgs = 2;

	if (ioctl(fd, I2C_RDWR, &ioctl_data) < 0) {
		perror("ioctl");
		exit(EXIT_FAILURE);
	}

	res = (uint64_t)data[0]<<40 | (uint64_t)data[2]<<32
	      | (uint64_t)data[4]<<24 | (uint64_t)data[6]<<16;

	/* get second part of serial number */
	cmd[0] = 0xfc;
	cmd[1] = 0xc9;

	msg[0].addr = SHT21_SLAVE_ADDR;
	msg[0].flags = 0x0000;
	msg[0].len = sizeof cmd;
	msg[0].buf = cmd;

	msg[1].addr = SHT21_SLAVE_ADDR;
	msg[1].flags = I2C_M_RD;
	msg[1].len = 6;
	msg[1].buf = data;

	ioctl_data.msgs = msg;
	ioctl_data.nmsgs = 2;

	if (ioctl(fd, I2C_RDWR, &ioctl_data) < 0) {
		perror("ioctl");
		exit(EXIT_FAILURE);
	}

	res |= (uint64_t)data[0]<<8 | (uint64_t)data[1]
	       | (uint64_t)data[3]<<56 | (uint64_t)data[4]<<48;

	return res;
}

uint8_t read_user_register(int fd)
{
	struct i2c_rdwr_ioctl_data ioctl_data;
	struct i2c_msg msg[2];
	uint8_t cmd;
	uint8_t data;

	cmd = CMD_READ_USER_REG;

	msg[0].addr = SHT21_SLAVE_ADDR;
	msg[0].flags = 0x0000;
	msg[0].len = sizeof cmd;
	msg[0].buf = &cmd;

	msg[1].addr = SHT21_SLAVE_ADDR;
	msg[1].flags = I2C_M_RD;
	msg[1].len = sizeof data;
	msg[1].buf = &data;

	ioctl_data.msgs = msg;
	ioctl_data.nmsgs = 2;

	if (ioctl(fd, I2C_RDWR, &ioctl_data) < 0) {
		perror("ioctl");
		exit(EXIT_FAILURE);
	}

	return data;
}

void write_user_register(int fd, uint8_t reg)
{
	uint8_t data[2];

	data[0] = CMD_WRITE_USER_REG;
	data[1] = reg;

	if (write(fd, data, sizeof data) != sizeof data) {
		perror("write");
		exit(EXIT_FAILURE);
	}
}

uint16_t get_measurement(int fd, uint8_t command)
{
	struct i2c_rdwr_ioctl_data ioctl_data;
	struct i2c_msg msg[2];
	uint8_t cmd;
	uint8_t data[3];

	cmd = command;

	msg[0].addr = SHT21_SLAVE_ADDR;
	msg[0].flags = 0x0000;
	msg[0].len = sizeof cmd;
	msg[0].buf = &cmd;

	msg[1].addr = SHT21_SLAVE_ADDR;
	msg[1].flags = I2C_M_RD;
	msg[1].len = sizeof data;
	msg[1].buf = data;

	ioctl_data.msgs = msg;
	ioctl_data.nmsgs = 2;

	if (ioctl(fd, I2C_RDWR, &ioctl_data) < 0) {
		perror("ioctl");
		exit(EXIT_FAILURE);
	}

	return data[0]<<8 | data[1];
}

float get_temp(int fd)
{
	uint16_t s_t;

	s_t = get_measurement(fd, CMD_TRIGGER_T_HOLD);
	/* clear status bits */
	s_t &= ~0x03;

	return -46.85f + 175.72f * s_t / 0x10000;
}

float get_rh(int fd)
{
	uint16_t s_rh;

	s_rh = get_measurement(fd, CMD_TRIGGER_RH_HOLD);
	/* clear status bits */
	s_rh &= ~0x03;

	return -6.f + 125.f * s_rh / 0x10000;
}
