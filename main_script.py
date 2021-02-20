#!/home/fran/miniconda3/envs/cs_python/bin/python

from package1.acquire import acquire_wrangle
from package1.load import load


def main():

    avg_time, user_timings, conversion_rates = acquire_wrangle()
    load(avg_time, user_timings)


if __name__ == '__main__':
    main()
