---
title: hue-manager
---

```
########################################################################
# hue-manager
########################################################################

USAGE
	hue-manager (help|install|reinstall|purge|upgrade|uninstall) <options>

SUBCOMMANDS

	help
		Show this help message.

	install
		Install Hue-shell.

	purge
		Delete all Hue-shell files including configurations.

	reinstall
		First uninstall Hue-shell and then install again.

	upgrade
		Upgrade Hue-shell.

	uninstall
		Uninstall Hue-shell. Configuration files are not deleted.

OPTIONS

	-a, --all-lights COMMA_SEPERATE_LIST_OF_IDS
		Set the option 'ALL_LIGHTS' to the given value in the
		configuration file. This option is only effective with
		the subcommand 'install'.

	-d, --debug INTEGER
		Set the option 'DEBUG' to the given value in the
		configuration file. This option is only effective with
		the subcommand 'install'.

	-h, --help
		Show this help message.

	-i, --ip IP_ADDRESS
		Set the option 'IP' to the given value in the
		configuration file. This option is only effective with
		the subcommand 'install'.

	-l, --log INTEGER
		Set the option 'LOG' to the given value in the
		configuration file. This option is only effective with
		the subcommand 'install'.

	-t, --test INTEGER
		Set `Hue-shell` in test mode. Possible values are `0` or `1`.
		In test mode the generated json code is not sent to `curl`, but
		instead to `jq`. This option is only effective with
		the subcommand 'install'.

	-u, --username USERNAME
		Set the option 'USERNAME' to the given value in the
		configuration file. This option is only effective with
		the subcommand 'install'.

DESCRIPTION

	'hue-manager' is a command to install, upgrade or uninstall
	Hue-shell.

EXAMPLES
	hue-manager install
	hue-manager install --ip 192.168.2.31 --username joseffriedrich
	hue-manager install -l 2 -d 1
	hue-manager upgrade
	hue-manager uninstall
	hue-manager --help
```

