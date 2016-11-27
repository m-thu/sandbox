/* Lists all tags in vicinity of reader */

/* for sigaction */
#define _POSIX_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <nfc/nfc.h>
#include <nfc/nfc-types.h>

static const int MAX_DEVICES = 32;
static const int MAX_TARGETS = 32;

/* global, so signal handler can access those */
nfc_context *context;
nfc_device *dev;

static void handler_sigint(int);

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

	const nfc_modulation_type *supported_mt;

	/* Get supported modulation types as initiator */
	if (nfc_device_get_supported_modulation(dev, N_INITIATOR, &supported_mt) < 0) {
		nfc_perror(dev, "nfc_device_get_supported_modulation");
		err = EXIT_FAILURE;
		goto error;
	}

	/* Initialize NFC device as initiator */
	if (nfc_initiator_init(dev) < 0) {
		nfc_perror(dev, "nfc_initiator_init");
		err = EXIT_FAILURE;
		goto error;
	}
	/* Disable forced ISO 14443-A mode (enabled by default) */
	if (nfc_device_set_property_bool(dev, NP_FORCE_ISO14443_A, false) < 0) {
		nfc_perror(dev, "nfc_device_set_property");
		err = EXIT_FAILURE;
		goto error;
	}
	/* Disable forced speed of 106 kbps (enabled by default) */
	if (nfc_device_set_property_bool(dev, NP_FORCE_SPEED_106, false) < 0) {
		nfc_perror(dev, "nfc_device_set_property");
		err = EXIT_FAILURE;
		goto error;
	}

	/* List all targets for each modulation type */
	while (*supported_mt) {
		const nfc_baud_rate *supported_br;

		printf("\nListing tags with modulation type %s, ", str_nfc_modulation_type(*supported_mt));
		
		/* Get supported baud rates for mod. type and find the slowest */
		if (nfc_device_get_supported_baud_rate(dev, *supported_mt, &supported_br) < 0) {
			nfc_perror(dev, "nfc_device_get_supported_baud_rate");
			err = EXIT_FAILURE;
			goto error;
		}
		while (*supported_br)
			++supported_br;
		--supported_br;
		printf("baud rate: %s\n", str_nfc_baud_rate(*supported_br));


		nfc_modulation mod;
		mod.nmt = *supported_mt;
		mod.nbr = *supported_br;

		int tags;
		nfc_target targets[MAX_TARGETS];

		/* List passive targets */
		if ((tags = nfc_initiator_list_passive_targets(dev, mod, targets, MAX_TARGETS)) < 0) {
			nfc_perror(dev, "nfc_initiator_list_passive_targets");
			err = EXIT_FAILURE;
			goto error;
		}

		for (int i = 0; i < tags; ++i) {
			char *target_info;

			if (str_nfc_target(&target_info, &targets[i], true) < 0) {
				nfc_perror(dev, "str_nfc_target");
				err = EXIT_FAILURE;
				goto error;
			}

			printf("\n=====\nTag %i\n=====\n%s\n", i, target_info);
			nfc_free(target_info);
		}

		++supported_mt;
	}

error:
	if (dev)
		nfc_close(dev);
	if (context)
		nfc_exit(context);
	return err;
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
