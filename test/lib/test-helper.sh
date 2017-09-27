#! /bin/sh
# shellcheck disable=SC2039,SC1111,SC1112

# MIT License
#
# Copyright (c) 2017 Josef Friedrich <josef@friedrich.rocks>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

mock_path() {
	_readlink() {
		local TMP
		TMP="$(cd $(dirname "$1") && pwd -P)/$(basename "$1")"
		# Using GNU coreutils
		#TMP="$(readlink -f "$1")"
		if [ -d "$TMP" ]; then
			echo "$TMP"
		else
			echo "The given path “$1” doesn’t exist or is no directory." >&2
		fi
	}
	SAVEIFS=$IFS
	IFS=:
	local MOCK_PATHS="$1"
	local TMP_PATHS=
	if [ -n "$PARENT_MOCK_PATH" ]; then
		PARENT_MOCK_PATH=$(_readlink "$PARENT_MOCK_PATH")
		for P in $MOCK_PATHS ; do
			TMP_PATHS="$TMP_PATHS$PARENT_MOCK_PATH/$P:"
		done
		MOCK_PATHS="$TMP_PATHS"
	fi
	# Make to absolute paths and clean
	local CLEANED_PATHS=
	for P in $MOCK_PATHS ; do
		ABSOLTE_PATH=$(_readlink "$P")
		if [ -n "$ABSOLTE_PATH" ]; then
			CLEANED_PATHS="$CLEANED_PATHS$ABSOLTE_PATH:"
		fi
	done
	# Add to $PATH
	export PATH="${CLEANED_PATHS}${PATH}"
	IFS=$SAVEIFS
}

source_exec() {
	local TMP_FILE
	TMP_FILE=$(mktemp)
	local SEPARATOR='## This SEPARATOR is required for test purposes. Please don’t remove! ##'
	if [ -n "$SOURCE_EXEC_SEPARATOR" ]; then
		SEPARATOR="$SOURCE_EXEC_SEPARATOR"
	fi
	if [ -f "$1" ]; then
		# Q is not available on Darwin
		sed "/$SEPARATOR/q" "$1" > "$TMP_FILE"
		# shellcheck disable=SC1090
		. "$TMP_FILE"
	else
		echo "The file “$1” doesn’t exist and therefore couldn’t be sourced!"
	fi
}

patch() {
	local NAME="$1"
	rm -f "${NAME}_patched"
	cp "${NAME}" "${NAME}_patched"
	chmod a+x "${NAME}_patched"
	shift
	if [ -n "$1" ]; then
		sed -i "$@" "${NAME}_patched"
	fi
	if [ ! -f .gitignore ] || \
	! grep '*_patched' .gitignore > /dev/null 2>&1 ; then
		echo '*_patched' >> .gitignore
	fi
}

# https://github.com/pgrange/bash_unit/blob/master/bash_unit
fake_function() {
	local COMMAND=$1
	shift
	if [ $# -gt 0 ]; then
		eval "$COMMAND() { export FAKE_PARAMS=\"\$@\" ; $@ ; }"
	else
		eval "$COMMAND() { echo \"$(cat)\" ; }"
	fi
	export -f $COMMAND
}
