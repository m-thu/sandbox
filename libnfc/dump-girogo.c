/* Dumps girogo cards */

/* for sigaction */
#define _POSIX_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <nfc/nfc.h>
#include <nfc/nfc-types.h>

static const int MAX_DEVICES = 32;
static const int MAX_TARGETS = 32;

static const size_t MAX_RX_LENGTH = 64;

/* girogo commands */
static const uint8_t DF_BOERSE[] = {0x00, 0xa4, 0x04, 0x0c, 0x09, 0xd2, 0x76, 0x00, 0x00, 0x25, 0x45, 0x50, 0x02, 0x00};
static const uint8_t EF_BETRAG[] = {0x00, 0xb2, 0x01, 0xc4, 0x00};
static const uint8_t EF_ID[]     = {0x00, 0xb2, 0x01, 0xbc, 0x00};
static const uint8_t EF_BOERSE[] = {0x00, 0xb2, 0x01, 0xcc, 0x00};

/* Global, so signal handler can access those */
nfc_context *context;
nfc_device *dev;

static void handler_sigint(int);
static void dump_girogo(void);
static void dump_buffer(char *, uint8_t *, int);

int main()
{
	struct sigaction sa;
	nfc_connstring connstrings[MAX_DEVICES];
	int err = EXIT_SUCCESS;

	/* Init libnfc */
	nfc_init(&context);
	if (context == NULL) {
		printf("Error initializing libnfc!\n");
		err = EXIT_FAILURE;
		goto error;
	}
	printf("libnfc version: %s\n", nfc_version());

	/* Install signal handler for SIGINT */
	sigemptyset(&sa.sa_mask);
	sa.sa_handler = handler_sigint;
	if (sigaction(SIGINT, &sa, NULL) < 0) {
		perror("sigaction");
		err = EXIT_FAILURE;
		goto error;
	}
	
	/* Find supported device */
	for (size_t i = 0; i < nfc_list_devices(context, connstrings, MAX_DEVICES); ++i) {
		if ((dev = nfc_open(context, connstrings[i])) == NULL) {
			printf("Failed to open device '%s'!\n", connstrings[i]);
			continue;
		} else {
			printf("Opened device '%s'\n", connstrings[i]);
			break;
		}
	}
	if (dev == NULL) {
		printf("No supported device found!\n");
		err = EXIT_FAILURE;
		goto error;
	}

	/* Initialize NFC device as initiator */
	if (nfc_initiator_init(dev) < 0) {
		nfc_perror(dev, "nfc_initiator_init");
		err = EXIT_FAILURE;
		goto error;
	}

	/* Set modulation type */
	nfc_modulation mod;
	mod.nmt = NMT_ISO14443A;
	mod.nbr = NBR_106;

	int tags;
	nfc_target target;

	/* Poll for targets */
	printf("\nPolling for tags ...\n");
	if ((tags = nfc_initiator_poll_target(dev, &mod, 1, 10, 0x01, &target)) < 0) {
		nfc_perror(dev, "nfc_initiator_poll_target");
		err = EXIT_FAILURE;
		goto error;
	}
	printf("... %i tag%s found.\n", tags, tags==1?"":"s");

	if (tags > 0)
		dump_girogo();

error:
	if (dev)
		nfc_close(dev);
	if (context)
		nfc_exit(context);
	return err;
}

static void dump_girogo(void)
{
	uint8_t rx_buf[MAX_RX_LENGTH];
	int rx;

	/* Select DF_BOERSE */
	if ((rx = nfc_initiator_transceive_bytes(dev, DF_BOERSE, sizeof DF_BOERSE, rx_buf, MAX_RX_LENGTH, 1000)) < 0) {
		nfc_perror(dev, "nfc_initiator_transceive_bytes");
		return;
	}
	if (rx >= 2 && rx_buf[0] == 0x90 && rx_buf[1] == 0x00) {
		printf("\nGeldKarte found!\n\n");
	} else {
		printf("\nCard not supported!\n\n");
		return;
	}

	/* EF_BETRAG */
	if ((rx = nfc_initiator_transceive_bytes(dev, EF_BETRAG, sizeof EF_BETRAG, rx_buf, MAX_RX_LENGTH, 1000)) < 0) {
		nfc_perror(dev, "nfc_initiator_transceive_bytes");
		return;
	}
	dump_buffer("EF_BETRAG", rx_buf, rx);

	/* EF_ID */
	if ((rx = nfc_initiator_transceive_bytes(dev, EF_ID, sizeof EF_ID, rx_buf, MAX_RX_LENGTH, 1000)) < 0) {
		nfc_perror(dev, "nfc_initiator_transceive_bytes");
		return;
	}
	dump_buffer("EF_ID", rx_buf, rx);

	/* EF_BOERSE */
	if ((rx = nfc_initiator_transceive_bytes(dev, EF_BOERSE, sizeof EF_BOERSE, rx_buf, MAX_RX_LENGTH, 1000)) < 0) {
		nfc_perror(dev, "nfc_initiator_transceive_bytes");
		return;
	}
	dump_buffer("EF_BOERSE", rx_buf, rx);
}

static void handler_sigint(int signal)
{
	(void)signal;

	if (dev != NULL) {
		nfc_abort_command(dev);
	} else {
		if (context)
			nfc_exit(context);
		exit(EXIT_FAILURE);
	}
}

static void dump_buffer(char *buf_name, uint8_t *buf, int size)
{
	printf("%s, length: %i\n\t", buf_name, size);
	for (int i = 0; i < size; ++i)
		printf("%02x%s", buf[i], i<size-1?" ":"");
	puts("\n");
}
