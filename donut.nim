import std/[os, math, sequtils]

const chars = ".,-~:;=!*#$@"
const (theta_spacing, phi_spacing) = (0.07'd, 0.02'd)
const (r1, r2, k2) = (1'd, 2'd, 5'd)
const (columns, lines) = (70, 30)
const k1 = columns.toFloat() * k2 * 3'd / (20'd * (r1 + r2))

#!fmt: off
proc render_donut(a, b: float) =
  
  let
    (cos_a, sin_a) = (cos(a), sin(a))
    (cos_b, sin_b) = (cos(b), sin(b))
  var
    output = newSeqWith(columns, newSeqWith(lines, ' '))
    z_buffer = newSeqWith(columns, newSeqWith(lines, 0'd))

  # calc output
  var theta = 0'd
  while theta < 2 * PI:
    let (cos_theta, sin_theta) = (cos(theta), sin(theta))
    var phi = 0'd
    while phi < 2 * PI:
      let
        (cos_phi, sin_phi) = (cos(phi), sin(phi))
        (circle_x, circle_y) = (r2 + r1 * cos_theta, r1 * sin_theta)
      let
        x = circle_x * (cos_b * cos_phi + sin_a * sin_b * sin_phi) - circle_y * cos_a * sin_b
        y = circle_x * (sin_b * cos_phi - sin_a * cos_b * sin_phi) + circle_y * cos_a * cos_b
        z = k2 + cos_a * circle_x * sin_phi + circle_y * sin_a
      let
        ooz = 1 / z
        xp = (columns / 2 + k1 * ooz * x).toInt()
        yp = (lines / 2 - k1 * ooz * y).toInt()
        l = cos_phi * cos_theta * sin_b - cos_a * cos_theta * sin_phi - sin_a * sin_theta + 
          cos_b * (cos_a * sin_theta - cos_theta * sin_a * sin_phi)
      if l > 0:
        if xp < 0 or yp < 0 or xp >= columns or yp >= lines: continue
        if ooz > z_buffer[xp][yp]:
          z_buffer[xp][yp] = ooz
          output[xp][yp] = chars[(l * 8).toInt()]
      phi += phi_spacing
    theta += theta_spacing

  # print output
  stdout.write "\e[H"
  for j in 0..<lines:
    for i in 0..<columns: stdout.write output[i][j]
    stdout.writeline ""
    
#!fmt: on

proc main() =
  var a, b = 0'd
  while true:
    render_donut(a, b)
    a += 0.07'd
    b += 0.03'd
    sleep(24)

main()
