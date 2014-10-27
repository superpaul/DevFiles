#!/bin/sh
#
# DESCRIPTION: ... Include functional description ...
#
# Requiresments:
#	awk
#	... 
#	uname
#
# Example usag:
#	$ template.sh -h 
#	$ template.sh -p ARG1 -q ARG2
#
# Source:
#	http://blog.xi-group.com/2014/07/devops-shell-script-template/

RET_CODE_OK=0
RET_CODE_ERROR=1

# Help / Usage function
print_help() {
	echo "$0: Functional description of the utility"
	echo ""
	echo "$0: Usage"
	echo "    [-h] Print help"
	echo "    [-p] (MANDATORY) First argument"
	echo "    [-q] (OPTIONAL) Second argument"
	exit $RET_CODE_ERROR;
}

# Check for supported operating system
p_uname=`whereis uname | cut -d' ' -f2`
if [ ! -x "$p_uname" ]; then
	echo "$0: No UNAME available in the system"
	exit $RET_CODE_ERROR;
fi
OS=`$p_uname`
if [ "$OS" != "Linux" ]; then
	echo "$0: Unsupported OS!";
	exit $RET_CODE_ERROR;
fi

# Check if awk is available in the system
p_awk=`whereis awk | cut -d' ' -f2`
if [ ! -x "$p_awk" ]; then
	echo "$0: No AWK available in the system!";
	exit $RET_CODE_ERROR;
fi

# Check for other used local utilities
#	bc
#	curl
#	grep 
#	etc ...

# Parse command line arguments
while test -n "$1"; do
	case "$1" in
	--help|-h)
		print_help
		exit 0
		;;
	-p)
		P_ARG=$2
		shift
		;;
	-q)
		Q_ARG=$2
		shift
		;;
	*)
		echo "$0: Unknown Argument: $1"
		print_help
		exit $RET_CODE_ERROR;
		;;
	esac
	
	shift
done

# Check if mandatory argument is present?
if [ -z "$P_ARG" ]; then
	echo "$0: Required parameter not specified!"
	print_help
	exit $RET_CODE_ERROR;
fi

# ... 

# Check if optional argument is present and if not, initialize!
if [ -z "$Q_ARG" ]; then
	Q_ARG="0";
fi

# ... 

# DO THE ACTUAL WORK HERE 

exit $RET_CODE_OK;
