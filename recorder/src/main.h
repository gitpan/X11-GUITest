/* X11::GUITest ($Id: main.h,v 1.2 2011/05/01 10:50:59 ctrondlp Exp $)
 *  
 * Copyright (c) 2003-2011 Dennis K. Paulsen, All Rights Reserved.
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
#ifndef MAIN_H
#define MAIN_H

#define APP_NAME "x11guirecord"

#define MIN_DELAY_MS 50
#define MAX_KEY_NAME 35
#define MIN_KEYDELAY_MS 1000
#define MOUSE_DBLCLICK_THRESHOLD 300
#define MAX_MBUTTON_NAME 25
#define MAX_KEY_BUFFER 128
#define KEY_BUFFER_THRESHOLD 60
#define MAX_WAIT_SECONDS 240 
#define MIN_GRANULARITY 1
#define MAX_GRANULARITY 10

BOOL GetMouseButtonFromIndex(int index, char *button);
void HandleDelay(unsigned long delay);
void HandleKeyBuffer(BOOL force);
void ProcessEvent(struct record_event ev);
BOOL IsMouseMoveTooGranular(struct record_event ev);


#endif /* #ifndef MAIN_H */

