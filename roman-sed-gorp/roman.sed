#!/bin/sed -E -f
# roman-sed: decimal <-> Roman, 1..3999. one number per line, bad input prints ?
/^[1-3]?[0-9]{1,3}$/{
/^[0-9]{1,4}$/!b bad
/^0*$/b bad
/^[4-9][0-9]{3}$/b bad
/^[0-9]{5}/b bad
s/^/000/
s/^0*([0-9]{4})$/\1/
s/^(.)(.)(.)(.)$/\1m\2c\3x\4i/
s/0i//
s/1i/I/
s/2i/II/
s/3i/III/
s/4i/IV/
s/5i/V/
s/6i/VI/
s/7i/VII/
s/8i/VIII/
s/9i/IX/
s/0x//
s/1x/X/
s/2x/XX/
s/3x/XXX/
s/4x/XL/
s/5x/L/
s/6x/LX/
s/7x/LXX/
s/8x/LXXX/
s/9x/XC/
s/0c//
s/1c/C/
s/2c/CC/
s/3c/CCC/
s/4c/CD/
s/5c/D/
s/6c/DC/
s/7c/DCC/
s/8c/DCCC/
s/9c/CM/
s/0m//
s/1m/M/
s/2m/MM/
s/3m/MMM/
s/4m/M/
s/5m//
s/6m/M/
s/7m/MM/
s/8m/MMM/
b done
}
/^M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/!b bad
/^$/b bad
s/CM/DCCCC/;s/CD/CCCC/;s/XC/LXXXX/;s/XL/XXXX/;s/IX/VIIII/;s/IV/IIII/
s/D/CCCCC/;s/L/XXXXX/;s/V/IIIII/
s/^(M*)(C*)(X*)(I*)$/\1|\2|\3|\4/
s/[MCXI]/a/g
s/a{9}/9/g
s/a{8}/8/g
s/a{7}/7/g
s/a{6}/6/g
s/a{5}/5/g
s/a{4}/4/g
s/a{3}/3/g
s/a{2}/2/g
s/a{1}/1/g
s/\|\|/|0|/;s/\|\|/|0|/;s/\|$/|0/;s/^\|/0|/
s/\|//g
s/^0+([1-9])/\1/
b done
:bad
s/.*/?/
:done
