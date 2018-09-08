DeclareModule Polygonizer
  Structure Point_t
    p.f[3]
    d.f
  EndStructure
  
  Structure Triangle_t
    p.Point_t[3]
  EndStructure
  
  Structure Cell_t
    *p.Point_t[8]
    *n.Cell_t[26]
  EndStructure
  
  Structure Grid_t
    resolution.i[3]
    Array points.Point_t(0)
    Array cells.Cell_t(0)
  EndStructure
  
  
  DataSection
    EDGE_TABLE:
      Data.i 0, 265, 515, 778, 1030, 1295, 1541, 1804
      Data.i 2060, 2309, 2575, 2822, 3082, 3331, 3593, 3840
      Data.i 400, 153, 915, 666, 1430, 1183, 1941, 1692
      Data.i 2460, 2197, 2975, 2710, 3482, 3219, 3993, 3728
      Data.i 560, 825, 51, 314, 1590, 1855, 1077, 1340
      Data.i 2620, 2869, 2111, 2358, 3642, 3891, 3129, 3376
      Data.i 928, 681, 419, 170, 1958, 1711, 1445, 1196
      Data.i 2988, 2725, 2479, 2214, 4010, 3747, 3497, 3232
      Data.i 1120, 1385, 1635, 1898, 102, 367, 613, 876
      Data.i 3180, 3429, 3695, 3942, 2154, 2403, 2665, 2912
      Data.i 1520, 1273, 2035, 1786, 502, 255, 1013, 764
      Data.i 3580, 3317, 4095, 3830, 2554, 2291, 3065, 2800
      Data.i 1616, 1881, 1107, 1370, 598, 863, 85, 348
      Data.i 3676, 3925, 3167, 3414, 2650, 2899, 2137, 2384
      Data.i 1984, 1737, 1475, 1226, 966, 719, 453, 204
      Data.i 4044, 3781, 3535, 3270, 3018, 2755, 2505, 2240
      Data.i 2240, 2505, 2755, 3018, 3270, 3535, 3781, 4044
      Data.i 204, 453, 719, 966, 1226, 1475, 1737, 1984
      Data.i 2384, 2137, 2899, 2650, 3414, 3167, 3925, 3676
      Data.i 348, 85, 863, 598, 1370, 1107, 1881, 1616
      Data.i 2800, 3065, 2291, 2554, 3830, 4095, 3317, 3580
      Data.i 764, 1013, 255, 502, 1786, 2035, 1273, 1520
      Data.i 2912, 2665, 2403, 2154, 3942, 3695, 3429, 3180
      Data.i 876, 613, 367, 102, 1898, 1635, 1385, 1120
      Data.i 3232, 3497, 3747, 4010, 2214, 2479, 2725, 2988
      Data.i 1196, 1445, 1711, 1958, 170, 419, 681, 928
      Data.i 3376, 3129, 3891, 3642, 2358, 2111, 2869, 2620
      Data.i 1340, 1077, 1855, 1590, 314, 51, 825, 560
      Data.i 3728, 3993, 3219, 3482, 2710, 2975, 2197, 2460
      Data.i 1692, 1941, 1183, 1430, 666, 915, 153, 400
      Data.i 3840, 3593, 3331, 3082, 2822, 2575, 2309, 2060
      Data.i 1804, 1541, 1295, 1030, 778, 515, 265
      
    TRI_TABLE:
      Data.i 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 1, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 8, 3, 9, 8, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 3, 1, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 2, 10, 0, 2, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 8, 3, 2, 10, 8, 10, 9, 8, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 11, 2, 8, 11, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 9, 0, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 11, 2, 1, 9, 11, 9, 8, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 10, 1, 11, 10, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 10, 1, 0, 8, 10, 8, 11, 10, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 9, 0, 3, 11, 9, 11, 10, 9, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 8, 10, 10, 8, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 3, 0, 7, 3, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 1, 9, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 1, 9, 4, 7, 1, 7, 3, 1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 10, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 4, 7, 3, 0, 4, 1, 2, 10, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 2, 10, 9, 0, 2, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, -1, -1, -1, -1
      Data.i 8, 4, 7, 3, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 11, 4, 7, 11, 2, 4, 2, 0, 4, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 0, 1, 8, 4, 7, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1, -1, -1, -1, -1
      Data.i 3, 10, 1, 3, 11, 10, 7, 8, 4, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4, -1, -1, -1, -1
      Data.i 4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3, -1, -1, -1, -1
      Data.i 4, 7, 11, 4, 11, 9, 9, 11, 10, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 5, 4, 0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 5, 4, 1, 5, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 5, 4, 8, 3, 5, 3, 1, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 10, 9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 0, 8, 1, 2, 10, 4, 9, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 2, 10, 5, 4, 2, 4, 0, 2, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, -1, -1, -1, -1
      Data.i 9, 5, 4, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 11, 2, 0, 8, 11, 4, 9, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 5, 4, 0, 1, 5, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5, -1, -1, -1, -1
      Data.i 10, 3, 11, 10, 1, 3, 9, 5, 4, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10, -1, -1, -1, -1
      Data.i 5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3, -1, -1, -1, -1
      Data.i 5, 4, 8, 5, 8, 10, 10, 8, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 7, 8, 5, 7, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 3, 0, 9, 5, 3, 5, 7, 3, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 7, 8, 0, 1, 7, 1, 5, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 7, 8, 9, 5, 7, 10, 1, 2, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3, -1, -1, -1, -1
      Data.i 8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2, -1, -1, -1, -1
      Data.i 2, 10, 5, 2, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 7, 9, 5, 7, 8, 9, 3, 11, 2, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11, -1, -1, -1, -1
      Data.i 2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7, -1, -1, -1, -1
      Data.i 11, 2, 1, 11, 1, 7, 7, 1, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11, -1, -1, -1, -1
      Data.i 5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0, -1
      Data.i 11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0, -1
      Data.i 11, 10, 5, 7, 11, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 3, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 0, 1, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 8, 3, 1, 9, 8, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 6, 5, 2, 6, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 6, 5, 1, 2, 6, 3, 0, 8, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 6, 5, 9, 0, 6, 0, 2, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, -1, -1, -1, -1
      Data.i 2, 3, 11, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 11, 0, 8, 11, 2, 0, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 1, 9, 2, 3, 11, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11, -1, -1, -1, -1
      Data.i 6, 3, 11, 6, 5, 3, 5, 1, 3, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6, -1, -1, -1, -1
      Data.i 3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, -1, -1, -1, -1
      Data.i 6, 5, 9, 6, 9, 11, 11, 9, 8, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 10, 6, 4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 3, 0, 4, 7, 3, 6, 5, 10, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 9, 0, 5, 10, 6, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4, -1, -1, -1, -1
      Data.i 6, 1, 2, 6, 5, 1, 4, 7, 8, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7, -1, -1, -1, -1
      Data.i 8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6, -1, -1, -1, -1
      Data.i 7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9, -1
      Data.i 3, 11, 2, 7, 8, 4, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11, -1, -1, -1, -1
      Data.i 0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6, -1, -1, -1, -1
      Data.i 9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6, -1
      Data.i 8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6, -1, -1, -1, -1
      Data.i 5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11, -1
      Data.i 0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7, -1
      Data.i 6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9, -1, -1, -1, -1
      Data.i 10, 4, 9, 6, 4, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 10, 6, 4, 9, 10, 0, 8, 3, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 0, 1, 10, 6, 0, 6, 4, 0, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10, -1, -1, -1, -1
      Data.i 1, 4, 9, 1, 2, 4, 2, 6, 4, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4, -1, -1, -1, -1
      Data.i 0, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 3, 2, 8, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 4, 9, 10, 6, 4, 11, 2, 3, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6, -1, -1, -1, -1
      Data.i 3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10, -1, -1, -1, -1
      Data.i 6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1, -1
      Data.i 9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3, -1, -1, -1, -1
      Data.i 8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1, -1
      Data.i 3, 11, 6, 3, 6, 0, 0, 6, 4, -1, -1, -1, -1, -1, -1, -1
      Data.i 6, 4, 8, 11, 6, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 7, 10, 6, 7, 8, 10, 8, 9, 10, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10, -1, -1, -1, -1
      Data.i 10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0, -1, -1, -1, -1
      Data.i 10, 6, 7, 10, 7, 1, 1, 7, 3, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, -1, -1, -1, -1
      Data.i 2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9, -1
      Data.i 7, 8, 0, 7, 0, 6, 6, 0, 2, -1, -1, -1, -1, -1, -1, -1
      Data.i 7, 3, 2, 6, 7, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7, -1, -1, -1, -1
      Data.i 2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7, -1
      Data.i 1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11, -1
      Data.i 11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1, -1, -1, -1, -1
      Data.i 8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6, -1
      Data.i 0, 9, 1, 11, 6, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0, -1, -1, -1, -1
      Data.i 7, 11, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 7, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 0, 8, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 1, 9, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 1, 9, 8, 3, 1, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 1, 2, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 10, 3, 0, 8, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 9, 0, 2, 10, 9, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8, -1, -1, -1, -1
      Data.i 7, 2, 3, 6, 2, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 7, 0, 8, 7, 6, 0, 6, 2, 0, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 7, 6, 2, 3, 7, 0, 1, 9, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, -1, -1, -1, -1
      Data.i 10, 7, 6, 10, 1, 7, 1, 3, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8, -1, -1, -1, -1
      Data.i 0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7, -1, -1, -1, -1
      Data.i 7, 6, 10, 7, 10, 8, 8, 10, 9, -1, -1, -1, -1, -1, -1, -1
      Data.i 6, 8, 4, 11, 8, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 6, 11, 3, 0, 6, 0, 4, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 6, 11, 8, 4, 6, 9, 0, 1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6, -1, -1, -1, -1
      Data.i 6, 8, 4, 6, 11, 8, 2, 10, 1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6, -1, -1, -1, -1
      Data.i 4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9, -1, -1, -1, -1
      Data.i 10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3, -1
      Data.i 8, 2, 3, 8, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8, -1, -1, -1, -1
      Data.i 1, 9, 4, 1, 4, 2, 2, 4, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1, -1, -1, -1, -1
      Data.i 10, 1, 0, 10, 0, 6, 6, 0, 4, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3, -1
      Data.i 10, 9, 4, 6, 10, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 9, 5, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 3, 4, 9, 5, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 0, 1, 5, 4, 0, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5, -1, -1, -1, -1
      Data.i 9, 5, 4, 10, 1, 2, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5, -1, -1, -1, -1
      Data.i 7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2, -1, -1, -1, -1
      Data.i 3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6, -1
      Data.i 7, 2, 3, 7, 6, 2, 5, 4, 9, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7, -1, -1, -1, -1
      Data.i 3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0, -1, -1, -1, -1
      Data.i 6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8, -1
      Data.i 9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7, -1, -1, -1, -1
      Data.i 1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4, -1
      Data.i 4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10, -1
      Data.i 7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10, -1, -1, -1, -1
      Data.i 6, 9, 5, 6, 11, 9, 11, 8, 9, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5, -1, -1, -1, -1
      Data.i 0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11, -1, -1, -1, -1
      Data.i 6, 11, 3, 6, 3, 5, 5, 3, 1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6, -1, -1, -1, -1
      Data.i 0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10, -1
      Data.i 11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5, -1
      Data.i 6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3, -1, -1, -1, -1
      Data.i 5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, -1, -1, -1, -1
      Data.i 9, 5, 6, 9, 6, 0, 0, 6, 2, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8, -1
      Data.i 1, 5, 6, 2, 1, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6, -1
      Data.i 10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0, -1, -1, -1, -1
      Data.i 0, 3, 8, 5, 6, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 5, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 11, 5, 10, 7, 5, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 11, 5, 10, 11, 7, 5, 8, 3, 0, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 11, 7, 5, 10, 11, 1, 9, 0, -1, -1, -1, -1, -1, -1, -1
      Data.i 10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1, -1, -1, -1, -1
      Data.i 11, 1, 2, 11, 7, 1, 7, 5, 1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11, -1, -1, -1, -1
      Data.i 9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7, -1, -1, -1, -1
      Data.i 7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2, -1
      Data.i 2, 5, 10, 2, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5, -1, -1, -1, -1
      Data.i 9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2, -1, -1, -1, -1
      Data.i 9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2, -1
      Data.i 1, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 7, 0, 7, 1, 1, 7, 5, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 0, 3, 9, 3, 5, 5, 3, 7, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 8, 7, 5, 9, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 8, 4, 5, 10, 8, 10, 11, 8, -1, -1, -1, -1, -1, -1, -1
      Data.i 5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0, -1, -1, -1, -1
      Data.i 0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5, -1, -1, -1, -1
      Data.i 10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4, -1
      Data.i 2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8, -1, -1, -1, -1
      Data.i 0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11, -1
      Data.i 0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5, -1
      Data.i 9, 4, 5, 2, 11, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4, -1, -1, -1, -1
      Data.i 5, 10, 2, 5, 2, 4, 4, 2, 0, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9, -1
      Data.i 5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2, -1, -1, -1, -1
      Data.i 8, 4, 5, 8, 5, 3, 3, 5, 1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 4, 5, 1, 0, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5, -1, -1, -1, -1
      Data.i 9, 4, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 11, 7, 4, 9, 11, 9, 10, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11, -1, -1, -1, -1
      Data.i 1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11, -1, -1, -1, -1
      Data.i 3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4, -1
      Data.i 4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2, -1, -1, -1, -1
      Data.i 9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3, -1
      Data.i 11, 7, 4, 11, 4, 2, 2, 4, 0, -1, -1, -1, -1, -1, -1, -1
      Data.i 11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4, -1, -1, -1, -1
      Data.i 2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9, -1, -1, -1, -1
      Data.i 9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7, -1
      Data.i 3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10, -1
      Data.i 1, 10, 2, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 9, 1, 4, 1, 7, 7, 1, 3, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1, -1, -1, -1, -1
      Data.i 4, 0, 3, 7, 4, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 4, 8, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 10, 8, 10, 11, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 0, 9, 3, 9, 11, 11, 9, 10, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 1, 10, 0, 10, 8, 8, 10, 11, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 1, 10, 11, 3, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 2, 11, 1, 11, 9, 9, 11, 8, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9, -1, -1, -1, -1
      Data.i 0, 2, 11, 8, 0, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 3, 2, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 3, 8, 2, 8, 10, 10, 8, 9, -1, -1, -1, -1, -1, -1, -1
      Data.i 9, 10, 2, 0, 9, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8, -1, -1, -1, -1
      Data.i 1, 10, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 1, 3, 8, 9, 1, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 9, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i 0, 3, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
      Data.i -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

    EndDataSection
    
  Declare CreateGrid(*box.Geometry::Box_t, cellSize.f)
  Declare PolygonizeCell(*grid.Cell_t, isolevel.f, *triangles)
  Declare Interpolate(*io.Point_t, isolevel.f,*p1.Point_t,*p2.Point_t)
  Declare Polygonize(*grid.Grid_t, *mesh.Geometry::PolymeshGeometry_t)
;   Declare New()
;   Declare Delete(*polygonizer.Polygonizer_t)
  
EndDeclareModule

Module Polygonizer
  Procedure EdgeTable(index.i)
    ProcedureReturn PeekI(?EDGE_TABLE + index * SizeOf(index)) 
  EndProcedure
  
  Procedure TriTable(cubeindex.i, index.i)
    ProcedureReturn PeekI(?TRI_TABLE + (cubeindex * 16 + index) * SizeOf(index))
  EndProcedure
  
  Procedure CreateGrid(*box.Geometry::Box_t, cellSize.f)
    Protected *grid.Grid_t = AllocateMemory(SizeOf(Grid_t))
    InitializeStructure(*grid, Grid_t)
    Protected size.Math::v3f32
    Vector3::Scale(@size, *box\extend, 2.0)
    
    *grid\resolution[0] = Math::Max(1, Math::Min(size\x / cellSize, 128))
    *grid\resolution[1] = Math::Max(1, Math::Min(size\y / cellSize, 128))
    *grid\resolution[2] = Math::Max(1, Math::Min(size\z / cellSize, 128))
    

    ReDim *grid\cells(*grid\resolution[0] * *grid\resolution[1] * *grid\resolution[2])
    ReDim *grid\points((*grid\resolution[0]+1) * (*grid\resolution[1]+1) * (*grid\resolution[2]+1))
    Protected cs.Math::v3f32
    cs\x = size\x / (*grid\resolution[0] -1)
    cs\y = size\y / (*grid\resolution[1] -1)
    cs\z = size\z / (*grid\resolution[2] -1)
    
    ; setup points
    Protected x, y, z
    Protected i
    Protected line.i = *grid\resolution[0]
    Protected slice.i = *grid\resolution[0] * *grid\resolution[1]
    Protected line_ext = *grid\resolution[0] + 1
    Protected slice_ext = (*grid\resolution[0] +1 ) * ( *grid\resolution[1] + 1)
    Protected *p.Point_t
    For z = 0 To *grid\resolution[2]
      For y = 0 To *grid\resolution[1]
        For x = 0 To *grid\resolution[0]
          *p = *grid\points(z * slice_ext + y * line_ext + x)
          *p\p[0] = *box\origin\x - *box\extend\x  + x * cs\x
          *p\p[1] = *box\origin\y - *box\extend\y  + y * cs\y
          *p\p[2] = *box\origin\z - *box\extend\z  + z * cs\z
          *p\d = *p\p[1]  + Sin(*p\p[0] * 3)*0.4 * Cos(*p\p[2]*3) * 0.75
        Next
      Next
    Next
    
    ; setup cells
    Protected *c.Cell_t
    
    
    For z = 0 To *grid\resolution[2] -1
      For y = 0 To *grid\resolution[1] -1
        For x = 0 To *grid\resolution[0] -1
          *c = *grid\cells(z * slice + y * line+ x)
          
          *c\p[0] = @*grid\points(z     * slice_ext + y     * line_ext + x     )
          *c\p[1] = @*grid\points(z     * slice_ext + y     * line_ext + x + 1 )
          *c\p[2] = @*grid\points((z+1) * slice_ext + y     * line_ext + x + 1 )
          *c\p[3] = @*grid\points((z+1) * slice_ext + y     * line_ext + x     ) 
          *c\p[4] = @*grid\points(z     * slice_ext + (y+1) * line_ext + x     )
          *c\p[5] = @*grid\points(z     * slice_ext + (y+1) * line_ext + x + 1 )
          *c\p[6] = @*grid\points((z+1) * slice_ext + (y+1) * line_ext + x + 1 )
          *c\p[7] = @*grid\points((z+1) * slice_ext + (y+1) * line_ext + x     )   
          Debug "CELL ID "+Str(z * slice + y * line+ x)
          Protected s.s
          s = Str(z     * slice_ext + y     * line_ext + x     )+", "
          s + Str(z     * slice_ext + y     * line_ext + x + 1 )+", "
          s + Str((z+1) * slice_ext + y     * line_ext + x + 1 )+", "
          s + Str((z+1) * slice_ext + y     * line_ext + x     )+", "
          s + Str(z     * slice_ext + (y+1) * line_ext + x     )+", "
          s + Str(z     * slice_ext + (y+1) * line_ext + x + 1 )+", "
          s + Str((z+1) * slice_ext + (y+1) * line_ext + x + 1 )+", "
          s + Str((z+1) * slice_ext + (y+1) * line_ext + x     ) 
          Debug s
        Next
      Next
    Next


    ProcedureReturn *grid
  EndProcedure
  
  ;    Given a grid cell And an isolevel, calculate the triangular
  ;    facets required To represent the isosurface through the cell.
  ;    Return the number of triangular facets, the Array "triangles"
  ;    will be loaded up With the vertices at most 5 triangular facets.
  ; 	0 will be returned If the grid cell is either totally above
  ;    of totally below the isolevel.
  Procedure PolygonizeCell(*grid.Cell_t,isolevel.f, *triangles)
    Protected i, ntri
    Protected cubeindex.i
    Dim vertlist.Point_t(12)

    ;       Determine the index into the edge table which
    ;       tells us which vertices are inside of the surface
   cubeindex = 0;
   If (*grid\p[0]\d < isolevel) : cubeindex | 1 : EndIf
   If (*grid\p[1]\d < isolevel) : cubeindex | 2 : EndIf
   If (*grid\p[2]\d < isolevel) : cubeindex | 4 : EndIf
   If (*grid\p[3]\d < isolevel) : cubeindex | 8 : EndIf
   If (*grid\p[4]\d < isolevel) : cubeindex | 16 : EndIf
   If (*grid\p[5]\d < isolevel) : cubeindex | 32 : EndIf
   If (*grid\p[6]\d < isolevel) : cubeindex | 64 : EndIf
   If (*grid\p[7]\d < isolevel) : cubeindex | 128 : EndIf

   ; Cube is entirely in/out of the surface
   If EdgeTable(cubeindex)  = 0 : ProcedureReturn(0) : EndIf

   ; Find the vertices where the surface intersects the cube
   If EdgeTable(cubeindex) & 1
     Interpolate(vertlist(0), isolevel,*grid\p[0],*grid\p[1])
   EndIf
   
   If EdgeTable(cubeindex) & 2
     Interpolate(vertlist(1), isolevel,*grid\p[1],*grid\p[2])
   EndIf
   
   If EdgeTable(cubeindex) & 4
     Interpolate(vertlist(2), isolevel,*grid\p[2],*grid\p[3])
   EndIf
   
   If EdgeTable(cubeindex) & 8
     Interpolate(vertlist(3), isolevel,*grid\p[3],*grid\p[0])
   EndIf
   
   If EdgeTable(cubeindex) & 16
     Interpolate(vertlist(4), isolevel,*grid\p[4],*grid\p[5])
   EndIf
   
   If EdgeTable(cubeindex) & 32
     Interpolate(vertlist(5), isolevel,*grid\p[5],*grid\p[6])
   EndIf
   
   If EdgeTable(cubeindex) & 64
     Interpolate(vertlist(6), isolevel,*grid\p[6],*grid\p[7])
   EndIf
   
   If EdgeTable(cubeindex) & 128
     Interpolate(vertlist(7), isolevel,*grid\p[7],*grid\p[4])
   EndIf
   
   If EdgeTable(cubeindex) & 256
     Interpolate(vertlist(8), isolevel,*grid\p[0],*grid\p[4])
   EndIf
   
   If EdgeTable(cubeindex) & 512
     Interpolate(vertlist(9), isolevel,*grid\p[1],*grid\p[5])
   EndIf
   
   If EdgeTable(cubeindex) & 1024
     Interpolate(vertlist(10), isolevel,*grid\p[2],*grid\p[6])
   EndIf
   
   If EdgeTable(cubeindex) & 2048
     Interpolate(vertlist(11), isolevel,*grid\p[3],*grid\p[7])
   EndIf

   ; Create the triangles
   ntriang = 0
   Protected *t.Triangle_t
   Protected running.b = #True
   i = 0
   Protected tt
   While running
     tt = TriTable(cubeindex, i)
     If tt > -1
       *t = *triangles + ntriang * SizeOf(Triangle_t)
       CopyMemory(vertlist(TriTable(cubeindex, i  )), *t\p[0], SizeOf(Point_t))
       CopyMemory(vertlist(TriTable(cubeindex, i+1)), *t\p[1], SizeOf(Point_t))
       CopyMemory(vertlist(TriTable(cubeindex, i+2)), *t\p[2], SizeOf(Point_t))
       i + 3
       ntriang + 1
     Else
       running= #False
     EndIf
     
   Wend
 

   ProcedureReturn ntriang
 EndProcedure
 
 ;  Linearly interpolate the position where an isosurface cuts
 ;  an edge between two vertices, each With their own scalar value
  Procedure Interpolate(*io.Point_t, isolevel.f,*p1.Point_t,*p2.Point_t)
   If Abs(isolevel-*p1\d) < 0.00001
     CopyMemory(*p1, *io, SizeOf(Point_t))
     ProcedureReturn
   EndIf
   
   If Abs(isolevel-*p2\d) < 0.00001
     CopyMemory(*p2, *io, SizeOf(Point_t))
     ProcedureReturn
   EndIf
   
   If Abs(*p1\d-*p2\d) < 0.00001
     CopyMemory(*p1, *io, SizeOf(Point_t))
     ProcedureReturn
   EndIf
   
   Protected mu.f
   mu = (isolevel - *p1\d) / (*p2\d - *p1\d)
   *io\p[0] = *p1\p[0] + mu * (*p2\p[0] - *p1\p[0])
   *io\p[1] = *p1\p[1] + mu * (*p2\p[1] - *p1\p[1])
   *io\p[2] = *p1\p[2] + mu * (*p2\p[2] - *p1\p[2]);

   ProcedureReturn
   
 EndProcedure
 
  Procedure Init()
  EndProcedure
  
  Procedure Polygonize(*grid.Grid_t, *geom.Geometry::PolymeshGeometry_t)
    
    Define *triangles = AllocateMemory(5 * SizeOf(Triangle_t))
    Define numCells.i = ArraySize(*grid\cells())
    Define c.i
    Define numVertices.i = 0
    Define numFaces.i = 0
    Define *vertices.CArray::CArrayV3F32 = CArray::newCArrayV3F32()
    Define *faces.CArray::CArrayLong = CArray::newCArrayLong()
    Define *t.Polygonizer::Triangle_t
    Define i
    
    For c=0 To numCells - 1
      Define numTris = PolygonizeCell(*grid\cells(c), 0.1, *triangles)
      If numTris
        CArray::SetCount(*vertices, numVertices + numTris * 3)
        CArray::SetCount(*faces, numFaces + numTris * 4)
        For i=0 To numTris - 1
          *t = *triangles + i * SizeOf(Polygonizer::Triangle_t)
          CArray::SetValue(*vertices, numVertices + i*3, *t\p[0])
          CArray::SetValue(*vertices, numVertices + i*3+1, *t\p[1])
          CArray::SetValue(*vertices, numVertices + i*3+2, *t\p[2])
          CArray::SetValueL(*faces, numFaces + i*4, numVertices + i*3+2)
          CArray::SetValueL(*faces, numFaces + i*4+1, numVertices + i*3+1)
          CArray::SetValueL(*faces, numFaces + i*4+2, numVertices + i*3)
          CArray::SetValueL(*faces, numFaces + i*4+3, -2)
        Next
        
        numVertices + numTris * 3
        numFaces + numTris * 4
        
      EndIf
    Next
   
    PolymeshGeometry::Set(*geom, *vertices, *faces)
    CArray::Delete(*vertices)
    CArray::Delete(*faces)

  EndProcedure

  
EndModule

; typedef struct {
;    double x,y,z;
; } XYZ;
; typedef struct {
;    XYZ p[3];
; } TRIANGLE;
; typedef struct {
;    XYZ p[8];
;    double val[8];
; } GRIDCELL;


;    Polygonise a tetrahedron given its vertices within a cube
;    This is an alternative algorithm To polygonisegrid.
;    It results in a smoother surface but more triangular facets.
; 
;                       + 0
;                      /|\
;                     / | \
;                    /  |  \
;                   /   |   \
;                  /    |    \
;                 /     |     \
;                +-------------+ 1
;               3 \     |     /
;                  \    |    /
;                   \   |   /
;                    \  |  /
;                     \ | /
;                      \|/
;                       + 2
; 
;    It's main purpose is still to polygonise a gridded dataset and
;    would normally be called 6 times, one For each tetrahedron making
;    up the grid cell.
;    Given the grid labelling As in PolygniseGrid one would call
;       PolygoniseTri(grid,iso,triangles,0,2,3,7);
;       PolygoniseTri(grid,iso,triangles,0,2,6,7);
;       PolygoniseTri(grid,iso,triangles,0,4,6,7);
;       PolygoniseTri(grid,iso,triangles,0,6,1,2);
;       PolygoniseTri(grid,iso,triangles,0,6,1,4);
;       PolygoniseTri(grid,iso,triangles,5,6,1,4);

; int PolygoniseTri(GRIDCELL g,double iso,
;    TRIANGLE *tri,int v0,int v1,int v2,int v3)
; {
;    int ntri = 0;
;    int triindex;
; 
;    /*
;       Determine which of the 16 cases we have given which vertices
;       are above Or below the isosurface
;    */
;    triindex = 0;
;    If (g.val[v0] < iso) triindex |= 1;
;    If (g.val[v1] < iso) triindex |= 2;
;    If (g.val[v2] < iso) triindex |= 4;
;    If (g.val[v3] < iso) triindex |= 8;
; 
;    /* Form the vertices of the triangles For each Case */
;    switch (triindex) {
;    Case 0x00:
;    Case 0x0F:
;       Break;
;    Case 0x0E:
;    Case 0x01:
;       tri[0].p[0] = VertexInterp(iso,g.p[v0],g.p[v1],g.val[v0],g.val[v1]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v0],g.p[v2],g.val[v0],g.val[v2]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v0],g.p[v3],g.val[v0],g.val[v3]);
;       ntri++;
;       Break;
;    Case 0x0D:
;    Case 0x02:
;       tri[0].p[0] = VertexInterp(iso,g.p[v1],g.p[v0],g.val[v1],g.val[v0]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v1],g.p[v3],g.val[v1],g.val[v3]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v1],g.p[v2],g.val[v1],g.val[v2]);
;       ntri++;
;       Break;
;    Case 0x0C:
;    Case 0x03:
;       tri[0].p[0] = VertexInterp(iso,g.p[v0],g.p[v3],g.val[v0],g.val[v3]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v0],g.p[v2],g.val[v0],g.val[v2]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v1],g.p[v3],g.val[v1],g.val[v3]);
;       ntri++;
;       tri[1].p[0] = tri[0].p[2];
;       tri[1].p[1] = VertexInterp(iso,g.p[v1],g.p[v2],g.val[v1],g.val[v2]);
;       tri[1].p[2] = tri[0].p[1];
;       ntri++;
;       Break;
;    Case 0x0B:
;    Case 0x04:
;       tri[0].p[0] = VertexInterp(iso,g.p[v2],g.p[v0],g.val[v2],g.val[v0]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v2],g.p[v1],g.val[v2],g.val[v1]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v2],g.p[v3],g.val[v2],g.val[v3]);
;       ntri++;
;       Break;
;    Case 0x0A:
;    Case 0x05:
;       tri[0].p[0] = VertexInterp(iso,g.p[v0],g.p[v1],g.val[v0],g.val[v1]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v2],g.p[v3],g.val[v2],g.val[v3]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v0],g.p[v3],g.val[v0],g.val[v3]);
;       ntri++;
;       tri[1].p[0] = tri[0].p[0];
;       tri[1].p[1] = VertexInterp(iso,g.p[v1],g.p[v2],g.val[v1],g.val[v2]);
;       tri[1].p[2] = tri[0].p[1];
;       ntri++;
;       Break;
;    Case 0x09:
;    Case 0x06:
;       tri[0].p[0] = VertexInterp(iso,g.p[v0],g.p[v1],g.val[v0],g.val[v1]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v1],g.p[v3],g.val[v1],g.val[v3]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v2],g.p[v3],g.val[v2],g.val[v3]);
;       ntri++;
;       tri[1].p[0] = tri[0].p[0];
;       tri[1].p[1] = VertexInterp(iso,g.p[v0],g.p[v2],g.val[v0],g.val[v2]);
;       tri[1].p[2] = tri[0].p[2];
;       ntri++;
;       Break;
;    Case 0x07:
;    Case 0x08:
;       tri[0].p[0] = VertexInterp(iso,g.p[v3],g.p[v0],g.val[v3],g.val[v0]);
;       tri[0].p[1] = VertexInterp(iso,g.p[v3],g.p[v2],g.val[v3],g.val[v2]);
;       tri[0].p[2] = VertexInterp(iso,g.p[v3],g.p[v1],g.val[v3],g.val[v1]);
;       ntri++;
;       Break;
;    }
; 
;    Return(ntri);
; }

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 368
; FirstLine = 361
; Folding = --
; EnableXP