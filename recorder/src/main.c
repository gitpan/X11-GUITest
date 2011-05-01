/* X11::GUITest ($Id: main.c,v 1.3 2011/05/01 17:47:49 ctrondlp Exp $)
 *  
 * Copyright (c) 2003-2011  Dennis K. Paulsen, All Rights Reserved.
 * Email: ctrondlp@cpan.org
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses>.
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <popt.h>
#include <unistd.h>
#include <libintl.h>
#include <X11/Xutil.h>
#include "record.h"
#include "record_event.h"
#include "KeyUtil.h"
#include "script_file.h"
#include "Common.h"
#include "main.h"


static char *scriptFile = NULL;
static char *exitKey = "ESC";
static KeySym exitKeySym = 0;
static int excludeDelays = 0;
static int waitSeconds = 1;
static int granularity = MAX_GRANULARITY; // TODO: use
static struct record_event lastEvent = {0};
static char buttonName[MAX_MBUTTON_NAME] = "\0";
static char keyBuffer[MAX_KEY_BUFFER] = "\0";


int main (int argc, char *argv[]) 
{
	poptContext	optCon;

	// International support
	setlocale(LC_MESSAGES, "");
	bindtextdomain(APP_NAME, APP_TEXTDOMAIN);
	textdomain(APP_NAME);
	
	// Handle Args
	struct poptOption optTbl[] = {
		{"script", 's', POPT_ARG_STRING, &scriptFile, 0, _("Script file"), NULL},
		{"wait", 'w', POPT_ARG_INT, &waitSeconds, 0, _("Seconds to wait before recording"), NULL},
		{"exitkey", 'e', POPT_ARG_STRING, &exitKey, 0, _("Exit key to stop recording (default: ESC)"), NULL},
		{"nodelay", 'n', POPT_ARG_NONE, &excludeDelays, 0, _("Don't include user delays"), NULL},
		{"granularity", 'g', POPT_ARG_NONE, &granularity, 0, _("Level of granularity (mouse move frequency, default: 10 out of 1-10)"), NULL},
		POPT_AUTOHELP
		{NULL, 0, 0, NULL, 0}
	};
	optCon = poptGetContext(NULL, argc, (const char **)argv, optTbl, 0);
	while (poptGetNextOpt(optCon) >= 0) {}
	poptFreeContext(optCon);

	if (scriptFile == NULL || !*scriptFile) {
		fprintf(stderr, _("No script file specified.\n"));
		exit(1);
	}
	if (!GetKeySym(exitKey, &exitKeySym)) {
		fprintf(stderr, _("Invalid exit key defined.\n"));
		exit(1);
	}
	if (waitSeconds <= 0 || waitSeconds > MAX_WAIT_SECONDS) {
		fprintf(stderr, _("Invalid wait defined (supplied %d, but needs 1-%d).\n"), 
				waitSeconds, MAX_WAIT_SECONDS);
		exit(1);
	}
	if (granularity < MIN_GRANULARITY || granularity > MAX_GRANULARITY) {
		fprintf(stderr, _("Invalid granularity defined (supplied %d, but needs %d-%d).\n"), 
				granularity, MIN_GRANULARITY, MAX_GRANULARITY);
		exit(1);
	}
	if (!OpenScript(scriptFile)) {
		fprintf(stderr, _("Unable to open script file '%s'!\n"), scriptFile);	
		exit(1);
	}

	usleep(waitSeconds * 1000000);
	printf(_("Recording Started, press %s to exit.\n"), exitKey);

	WriteScript("#!/usr/bin/perl\n\n");
	WriteScript("use X11::GUITest qw/:ALL/;\n\n");
	
	WriteScript(_("\n# Begin (Recorder Version %s).\n"), APP_VERSION);

	////
	RecordEvents(ProcessEvent);
	////

	WriteScript(_("\n\n# End.\n"));
	CloseScript();

	printf(_("\nRecording Finished.\n"));
	exit(0);
}

BOOL GetMouseButtonFromIndex(int index, char *button)
{
	if (button == NULL) {
		return FALSE;
	}
	*button = NUL;

	if (index == 1) {
		strcpy(button, "M_LEFT");
	} else if (index == 2) {
		strcpy(button, "M_MIDDLE");
	} else if (index == 3) {
		strcpy(button, "M_RIGHT");
	} else {
		return FALSE;
	}

	return TRUE;
}

void HandleDelay(unsigned long delay)
{
	if (excludeDelays == 0) {
		if (delay > MIN_DELAY_MS) {	
			float secs = ((float)delay / 1000);
			WriteScript("select(undef, undef, undef, %0.3f);\n", secs);
		}
	}
}

void HandleKeyBuffer(BOOL force)
{
	int len = strlen(keyBuffer);
	if (force || len >= KEY_BUFFER_THRESHOLD) {
		if (len > 0) {
			WriteScript("SendKeys('%s');\n", keyBuffer);
			*keyBuffer = '\0'; // clear
		}
	}	
}

void ProcessEvent(struct record_event ev) 
{
	if (ev.type == KEY) {
		BOOL flushKeys = (ev.delay > MIN_KEYDELAY_MS);
		HandleKeyBuffer(flushKeys);
		if (flushKeys) {
			HandleDelay(ev.delay);
		}
		
		// Are we exiting?
		if (ev.data == exitKeySym) {
			HandleKeyBuffer(TRUE);
			StopRecording();
			return;
		}

		const char *nam = GetKeyName(ev.data);
		if (nam != NULL) {
			const char *mod = GetModifierCode(ev.data);
			if (mod != NULL) {
				// handle modifiers
				if (ev.state == DOWN) {
					strcat(keyBuffer, mod);
					strcat(keyBuffer, "(");
				} else {
					strcat(keyBuffer, ")");
				}
			} else {
				// handle other keys
				if (ev.state == UP) {
					//printf("Key: %s (%s)\n", nam, mod);
					if (strlen(nam) > 1) {
						// special key
						strcat(keyBuffer, "{"); 
						strcat(keyBuffer, nam);
						strcat(keyBuffer, "}");
					} else {
						if (strcmp(nam, "'") ==  0) { // escape this
							strcat(keyBuffer, "\\");
						}
						strcat(keyBuffer, nam);
					}
				}
			}
		} else {
			WriteScript(_("# [Unhandled Key %d/%d]\n"), ev.data, ev.state);
		}	
	} else { // Mouse, etc.
		HandleKeyBuffer(TRUE);
		HandleDelay(ev.delay);

		if (ev.type == MOUSEMOVE) {
			if (!IsMouseMoveTooGranular(ev)) {
				WriteScript("MoveMouseAbs(%d, %d);\n", ev.posX, ev.posY);
			}
		} else if (ev.type == MOUSEBUTTON) {
			GetMouseButtonFromIndex(ev.data, buttonName);
			if (!*buttonName) {
				WriteScript(_("# [Unhandled Mouse Button %d/%d]\n"), ev.data, ev.state);
			} else {
				// TODO: Simplify to 'ClickMouseButton' where possible...
				if (ev.state == UP) {
					WriteScript("ReleaseMouseButton(%s);\n", buttonName);
				} else {
					WriteScript("PressMouseButton(%s);\n", buttonName);
				}
			}
		} else {
			//printf("Unhandled event type: %d\n", ev.type);
		}	
	}
	memcpy(&lastEvent, &ev, sizeof(struct record_event));
}

BOOL IsMouseMoveTooGranular(struct record_event ev)
{
	if (lastEvent.type != MOUSEMOVE) {
		return(FALSE); // must be mousemove -> mousemove to count
	} else {
		// TODO: Adjust
		int threshold = (int)MAX_GRANULARITY / granularity - 1;
		if (ev.delay < threshold) {
			return(TRUE);
		}
	}
	return(FALSE);
}
