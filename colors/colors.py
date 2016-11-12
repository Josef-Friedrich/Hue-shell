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
		print('')
		name = color[0]
		name = name.lower().replace(' ', '-')
		print('name: ' + name)
		rgb = color[1]
		print('rgb: ' + rgb)


		gamut_A = color[2]
		print('gamut_A: ' + gamut_A)
		ax, ay = grab_xy(gamut_A)
		print('ax: ' + ax)
		print('ay: ' + ay)


		gamut_B = color[3]
		print('gamut_B: ' + gamut_B)
		bx, by = grab_xy(gamut_B)
		print('bx: ' + bx)
		print('by: ' + by)

		gamut_C = color[4]
		print('gamut_C: ' + gamut_C)
		cx, cy = grab_xy(gamut_C)
		print('cx: ' + cx)
		print('cy: ' + cy)

