PRO Ch5_5aHw

Precip = [4.17, 5.61, 3.88, 1.55, 2.30, 5.58, 5.58, 5.14, 4.52, $
1.53, 4.24, 1.18, 3.17, 4.72, 2.17, 2.17, 3.94, 0.95, 1.48, $
5.68, 4.25, 3.66, 2.12, 1.24, 3.64, 8.44, 5.20, 2.33, 2.18, 3.43]

ResultPrecip = Sort(Precip)		;Sorting the values
SortPrecip = Precip[Sort(Precip)]	;Putting the sorted values into an array
SizePrecip = Size(Precip)		;Implementing the size function of the array
n = SizePrecip[1]			;Getting the size of the array

z = (SortPrecip - Mean(Precip))/(stddev(Precip))
zPositive = Where(z GT 0)
zNegative = Where(z LT 0)

CDFpos = (0.5) * (1 + SQRT(1-(2.71828^((-2*(z(zPositive))^(2.0))/!pi))))
CDFneg = (0.5) * (1 - SQRT(1-(2.71828^((-2*(z(zNegative))^(2.0))/!pi))))

;K-S (Lilliefors) test
Dneg = Abs((zNegative+1.0)/n - CDFneg)
Dpos = Abs((zPositive+1.0)/n - CDFpos)


Print, "pos ", Max(Dpos)
Print, "neg ", Max(Dneg)


END
