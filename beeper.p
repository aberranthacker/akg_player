set title "low-pass filter"
set xlabel "Frequency"
set xrange [40:14000]
set yrange [0.2:0.41]
set logscale

rc1(x) = 1 / (2 * pi * x * c1)
r2(x) = (510 * rc1(x)) / (510 + rc1(x))
beeper(x) = r2(x) / (2530 + r2(x))

rc2(x) = 1/(2 * pi * x * c2)
r3 = 100e3
r4(x) = (24e3 * rc2(x)) / (24e3 + rc2(x))
mixer(x) = r4(x) / r3

combined(x) = beeper(x) * mixer(x) * 10

# plot c1 = 0.1e-6, beeperf(x), \
#      c1 = 0.068e-6, beeperf(x), \
#      c1 = 0.056e-6, beeperf(x), \
#      c1 = 0.047e-6, beeperf(x), \
#      c1 = 0.033e-6, beeperf(x), \
#      c1 = 0.015e-6, beeperf(x)

plot c1 = 0.0075e-6, c2 = 200e-12, combined(x), \
     c1 = 0.0075e-6, c2 = 200e-22, combined(x)

