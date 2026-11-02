#!/usr/bin/bash
sudo systemctl restart gpd.service          # system daemon (PanGPS)
systemctl --user restart gpa.service        # user agent (PanGPA) — reconnects the tunnel
