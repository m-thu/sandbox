/* Lists all connected devices supported by libnfc */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <nfc/nfc.h>
#include <nfc/nfc-types.h>

static const int MAX_DEVICES = 32;

int main()
{
	nfc_context *context = NULL;
	nfc_connstring connstrings[MAX_DEVICES];
	nfc_device *dev;
	const nfc_modulation_type *supported_mt;
	const nfc_baud_rate *supported_br;
	int err = EXIT_SUCCESS;

	nfc_init(&context);
	if (context == NULL) {
		printf("Error initializing libnfc!\n");
		err = EXIT_FAILURE;
		goto error;
	}
	printf("libnfc version: %s\n", nfc_version());
	
	for (size_t i = 0; i < nfc_list_devices(context, connstrings, MAX_DEVICES); ++i) {
		printf("\nDevice %zd: %s\n", i, connstrings[i]);
		if ((dev = nfc_open(context, connstrings[i])) == NULL) {
			printf("Failed to open device!\n");
			continue;
		}

		printf("Supported modulation types as initiator:");
		if (nfc_device_get_supported_modulation(dev, N_INITIATOR, &supported_mt) < 0) {
			nfc_perror(dev, "nfc_device_get_supported_modulation");
			err = EXIT_FAILURE;
			goto error;
		}

		while (*supported_mt) {
			printf("\n\t* %s: ", str_nfc_modulation_type(*supported_mt));
			
			if (nfc_device_get_supported_baud_rate(dev, *supported_mt, &supported_br) < 0) {
				nfc_perror(dev, "nfc_device_get_supported_baud_rate");
				err = EXIT_FAILURE;
				goto error;
			}

			while (*supported_br) {
				printf("%s%s", str_nfc_baud_rate(*supported_br), supported_br[1]?", ":"");
				++supported_br;
			}

			++supported_mt;
		}

		printf("\nSupported modulation types as target:");
		if (nfc_device_get_supported_modulation(dev, N_TARGET, &supported_mt) < 0) {
			nfc_perror(dev, "nfc_device_get_supported_modulation");
			err = EXIT_FAILURE;
			goto error;
		}

		while (*supported_mt) {
			printf("\n\t* %s: ", str_nfc_modulation_type(*supported_mt));

			if (nfc_device_get_supported_baud_rate(dev, *supported_mt, &supported_br) < 0) {
				nfc_perror(dev, "nfc_device_get_supported_baud_rate");
				err = EXIT_FAILURE;
				goto error;
			}

			while (*supported_br) {
				printf("%s%s", str_nfc_baud_rate(*supported_br), supported_br[1]?", ":"");
				++supported_br;
			}

			++supported_mt;
		}

		puts("\n");
		nfc_close(dev);
	}

error:
	if (context)
		nfc_exit(context);
	return err;
}
