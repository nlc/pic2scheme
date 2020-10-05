def rel_lum(color_str_raw)
  color_str = color_str_raw.gsub(/[^0-9A-Fa-f]/, '')[0...6]
  unless color_str.length == 6
    raise 'Color string must be six hex digits long.'
  end
  r, g, b = \
  color_str.chars.each_slice(2).map do |x|
    srgb = (x.join.to_i(16) / 255.0)
    if srgb <= 0.03928
      srgb / 12.92
    else
      ((srgb + 0.055) / 1.055) ** 2.4
    end
  end

  0.2126 * r + 0.7152 * g + 0.0722 * b
end

def con_rat(rl1, rl2)
  dkr, ltr = [rl1, rl2].sort

  (ltr + 0.05) / (dkr + 0.05)
end

# # solarized
# colors = [
#   %w[base03 002b36],
#   %w[base02 073642],
#   %w[base01 586e75],
#   %w[base00 657b83],
#   %w[base0 839496],
#   %w[base1 93a1a1],
#   %w[base2 eee8d5],
#   %w[base3 fdf6e3],
#   %w[yellow b58900],
#   %w[orange cb4b16],
#   %w[red dc322f],
#   %w[magenta d33682],
#   %w[violet 6c71c4],
#   %w[blue 268bd2],
#   %w[cyan 2aa198],
#   %w[green 859900]
# ].to_h

colors = {}
fname = ARGV.shift
lines = File.readlines(fname)

lines.each_with_index do |line, i|
  colors[i] = line.chomp.gsub(/[^0-9A-Fa-f]/, '')
end

fmt_s = "%s," # no spacing
fmt_f = "%f," # no spacing

print fmt_s % 'X'
colors.each do |name, color|
  print fmt_s % "#{name} (##{color})"
end
puts

colors.each do |name1, color1|
  print fmt_s % "#{name1} (##{color1})"
  colors.each do |name2, color2|
    rl1 = rel_lum(color1)
    rl2 = rel_lum(color2)
    cr = con_rat(rl1, rl2)
    print fmt_f % cr
  end
  puts
end
