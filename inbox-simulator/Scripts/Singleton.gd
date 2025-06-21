# Author: Michael Knighten
# Date: 6/20/2025
# Last Modified: 6/20/2025
#
# Descritption:
# This is a global variable that holds the current logged in username for JSON access.
#
# Project>Project Settings>Global>Auoload (How it was set to be global)
#
# Notes:
#
# Added: 6/20/2025
# -Currently just hold the string of the username.
# -Is set to autoload like a Singleton, anything in every scene can access this. (Potential Security Issue?)
# !!!SCRIPT IS COMPLETE FOR PROTOTYPE!!!

extends Node

var Current_Username: String = ""
