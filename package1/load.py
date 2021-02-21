import pandas as pd
import matplotlib.pyplot as plt


def create_df(timings_list):

    data = timings_list
    cols = ['user', 'submission_time', 'registration_time', 'days_difference']
    df_user_timings = pd.DataFrame(data, columns=cols)
    df_user_timings['user'] = df_user_timings['user'].astype('category')

    return df_user_timings


def create_viz(df, constant):

    mean_days = constant

    series_user_timing = df['days_difference']
    # print(series_user_timing.describe())
    data_viz = series_user_timing.plot.hist(
        bins=60, figsize=(18, 8), xlabel='days', title='Histogram of Days to Submission'
    )
    # Plot mean dashed line
    data_viz.axvline(mean_days, color='k', linestyle='dashed', linewidth=1)

    # Add text to line
    min_ylim, max_ylim = plt.ylim()
    data_viz.text(mean_days * 1.03, max_ylim * 0.9, f'Mean: {mean_days} days')

    # Export viz to .png file
    data_viz.figure.savefig("data/output/avg_sub_time_user_3.png", facecolor='w')

    return None


def load(avg_integer, timings_list):

    df_user_timings = create_df(timings_list)
    create_viz(df_user_timings, avg_integer)
