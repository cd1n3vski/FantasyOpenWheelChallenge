import pandas as pd
from get_car_num import get_car_num
from pivot_race_picks import pivot_race_picks
from calc_race_results import calc_race_results

entry_list = pd.read_csv("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/Fantasy Open Wheel Challenge/2024/indycar_entry_list_2024.csv")
race_picks = pd.read_csv("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/Fantasy Open Wheel Challenge/2024/fantasy_owc_picks_2024.csv")
indycar_results = pd.read_csv("/Users/cd1n3vski/Desktop/Racing Material/IndyCar Data Materials/Data Sets/IRL:IndyCar/INDY_23.csv")

# assign value to race
race = 'St. Petersburg'


if race in list(entry_list['Race'].unique()):
    race_picks = get_car_num(race_picks, entry_list)
    race_picks_wide = pivot_race_picks(race_picks, race)
    race_results = calc_race_results(race_picks, indycar_results, race)
    print('Calculations were successful!')
else:
    print('The race you entered is not valid.')




























