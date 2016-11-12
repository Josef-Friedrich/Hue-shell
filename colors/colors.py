#! /usr/bin/env python

#http://www.developers.meethue.com/documentation/hue-xy-values

import csv
import re

def grab_xy(string):
	xy = re.findall(r'\[(.*),(.*)\]', string)
	return xy[0]


with open('colors.csv', 'r') as csvfile:
	colors = csv.reader(csvfile)
	for color in colors:
		name = color[0]
		name = name.lower().replace(' ', '-')
		rgb = color[1]

		gamut_A = color[2]
		ax, ay = grab_xy(gamut_A)


		gamut_B = color[3]
		bx, by = grab_xy(gamut_B)

		gamut_C = color[4]
		cx, cy = grab_xy(gamut_C)
		print(name + ') echo \'-x ' + cx + ' -y ' + cy + '\' ;;')
