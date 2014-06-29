/*
 * clock.vala
 * 
 * Copyright 2014
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */
using Gtk;

public class Clock : Gtk.Window {

	// Variable to save the current time
	GLib.DateTime now;
	
	// Constructor function
	public Clock () {
		
		// Create a GTK window
		this.title = "Clock";
		this.window_position = Gtk.WindowPosition.CENTER;
		this.destroy.connect (Gtk.main_quit);
		this.set_default_size (400, 400);

		// Update the time
		update_time();

		// Add the clock to the window
		var drawing_area = new DrawingArea ();
		drawing_area.draw.connect (draw_clock);
		add (drawing_area);
			
	}
	
	// Function to draw the clock itself
	private bool draw_clock (Widget da, Cairo.Context ctx) {
			int hours = now.get_hour();
      int minutes = now.get_minute();
      int seconds = now.get_second();		
			int height = get_allocated_height ();
			int width = get_allocated_width ();

			// Do some calculation for the background
			double x = width / 2.0;
			double y = height / 2.0;
			double radius = int.min (width, height) / 2.0;
			double angle1 = 0;
			double angle2 = 2*Math.PI;
			
			// Draw the background of the clock
            ctx.arc (x, y, radius, angle1,  angle2);
            ctx.set_source_rgb (1, 1, 1);
            ctx.fill_preserve ();
            ctx.set_source_rgb (0, 0, 0);
            ctx.stroke ();
                        
            // Draw the hour hand
            // The hour hand is rotated 30 degrees (pi/6 r) per hour +
            // 1/2 a degree (pi/360 r) per minute
            ctx.save ();
            ctx.set_line_width (2.5 * ctx.get_line_width ());
            ctx.move_to (x, y);
            ctx.line_to (x + radius / 2 * Math.sin (Math.PI / 6 * hours
                                                 + Math.PI / 360 * minutes),
                         y + radius / 2 * -Math.cos (Math.PI / 6 * hours
                                                  + Math.PI / 360 * minutes));
            ctx.stroke ();
            ctx.restore ();

            // Draw the minute hand
            // the minute hand is rotated 6 degrees (pi/30 r) per minute
            ctx.move_to (x, y);
            ctx.line_to (x + radius * 0.8 * Math.sin (Math.PI / 30 * minutes),
                         y + radius * 0.8 * -Math.cos (Math.PI / 30 * minutes));
            ctx.stroke ();
                        
            // Draw the cesond hand
            // operates identically to the minute hand
            ctx.save ();
            ctx.set_source_rgb (1, 0, 0); // red
            ctx.move_to (x, y);
            ctx.line_to (x + radius * 0.75 * Math.sin (Math.PI / 30 * seconds),
                         y + radius * 0.75 * -Math.cos (Math.PI / 30 * seconds));
            ctx.stroke ();
            ctx.restore ();

			return true;		
	}
	
	// Function to update the current time
	private bool update_time () {		
		now = new GLib.DateTime.now_local();
		stdout.printf("Hour: %d Minutes: %d Second: %d\n", now.get_hour(), now.get_minute(), now.get_second());           
		return true;
    }
    
    private void update_clock () {
		update_time();
		var window = get_window ();
		if (null == window) {
			return;
		}

		var region = window.get_clip_region ();
		// Redraw the the clock completely by exposing it
		window.invalidate_region (region, true);
		window.process_updates (true);
	}

	// Main function
	public static int main (string[] args) 
	{
		Gtk.init (ref args);

		var clock = new Clock ();
		clock.show_all ();

        // Timeout to update once a second everything
        Timeout.add_seconds (1, () => {
            clock.update_clock ();
            return true;
        });
		
		Gtk.main();
		return 0;
	}
}
