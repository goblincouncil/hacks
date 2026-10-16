# roman.sed: add two Roman numerals.
# Input: one pair per line, "NUMERAL NUMERAL", canonical form only.
# Output: the canonical sum, or "?" for any other input.
# Run: sed -E -f roman.sed

/^ | $|  /b bad
/^(M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})) (M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3}))$/!b bad

# expand subtractive pairs to additive letters
s/CM/DCCCC/g
s/CD/CCCC/g
s/XC/LXXXX/g
s/XL/XXXX/g
s/IX/VIIII/g
s/IV/IIII/g
s/ //

# sort into descending order (M D C L X V I) and carry while sorting
:l
s/IV/VI/
s/IX/XI/
s/IL/LI/
s/IC/CI/
s/ID/DI/
s/IM/MI/
s/VX/XV/
s/VL/LV/
s/VC/CV/
s/VD/DV/
s/VM/MV/
s/XL/LX/
s/XC/CX/
s/XD/DX/
s/XM/MX/
s/LC/CL/
s/LD/DL/
s/LM/ML/
s/CD/DC/
s/CM/MC/
s/DM/MD/
s/IIIII/V/
s/VV/X/
s/XXXXX/L/
s/LL/C/
s/CCCCC/D/
s/DD/M/
tl

# fold additive back to subtractive
s/DCCCC/CM/
s/CCCC/CD/
s/LXXXX/XC/
s/XXXX/XL/
s/VIIII/IX/
s/IIII/IV/
b

:bad
s/.*/?/
