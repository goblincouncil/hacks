/* moonrot: moon phase for any date, from the mean synodic month. */
#include <math.h>
#include <stdio.h>
#include <time.h>

#define SYNODIC 29.530588853
#define PI_VAL 3.14159265358979323846
#define REF_JDN 2451550L /* noon UTC, 2000-01-06 */
#define REF_FRAC 0.26    /* that day's new moon falls at 18:14 UTC */

static long jdn(int y, int m, int d)
{
    int a = (14 - m) / 12;
    long yy = y + 4800 - a;
    int mm = m + 12 * a - 3;
    return d + (153 * mm + 2) / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32045;
}

/* names[i] covers ages from cut[i-1] up to cut[i] days into the month */
static const char *names[8] = {
    "new moon", "waxing crescent", "first quarter", "waxing gibbous",
    "full moon", "waning gibbous", "last quarter", "waning crescent"
};
static const double cut[8] = {1.85, 7.38, 9.23, 14.77, 16.61, 22.15, 24.00, 27.68};
static const char *verdict[8] = {
    "no moon tonight, the sky keeps its own counsel",
    "a fingernail of light, leave it be",
    "half lit and growing, stop complaining about the dark",
    "nearly round, the dogs have opinions",
    "fully lit, everyone is awake now",
    "still bright, going soft at the edges",
    "half lit and shrinking, the good half is leaving",
    "a thin sliver before the reset, do something useful"
};

int main(int argc, char **argv)
{
    int y = 0, m = 0, d = 0, i, idx = 7; /* ages past the last cut stay waning crescent */
    double age, lit;
    if (argc == 2) {
        if (sscanf(argv[1], "%d-%d-%d", &y, &m, &d) != 3 || m < 1 || m > 12 || d < 1 || d > 31) {
            fprintf(stderr, "usage: moonrot [YYYY-MM-DD]\n");
            return 2;
        }
    } else if (argc == 1) {
        time_t t = time(NULL);
        struct tm *g = gmtime(&t);
        y = g->tm_year + 1900;
        m = g->tm_mon + 1;
        d = g->tm_mday;
    } else {
        fprintf(stderr, "usage: moonrot [YYYY-MM-DD]\n");
        return 2;
    }
    age = fmod((double)(jdn(y, m, d) - REF_JDN) - REF_FRAC, SYNODIC);
    if (age < 0)
        age += SYNODIC;
    for (i = 0; i < 8; i++) {
        if (age < cut[i]) {
            idx = i;
            break;
        }
    }
    if (age >= SYNODIC - cut[0])  /* the new moon window wraps past the end of the month */
        idx = 0;
    lit = (1 - cos(2 * PI_VAL * age / SYNODIC)) / 2 * 100;
    printf("%04d-%02d-%02d  %s  age %.2f d  lit %.0f%%\n", y, m, d, names[idx], age, lit);
    printf("%s\n", verdict[idx]);
    return 0;
}
