# race picks
def pivot_race_picks(race_picks, race):
    
    import pandas as pd
    
    contestants = list(race_picks['name'].unique())
    
    race_picks_wide = pd.DataFrame(columns = ['Contestant', 'Pick_1', 'Pick_3', 'Pick_3', 'Pick_4', 'Pick_5'])
    
    for contestant in contestants:
        
        #temp_race_picks_wide = pd.DataFrame(columns = ['Contestant', 'Pick_1', 'Pick_3', 'Pick_3', 'Pick_4', 'Pick_5'])
        
        temp_race_picks = race_picks[(race_picks['name'] == contestant) & (race_picks['race'] == race)]
        
        temp_race_picks = temp_race_picks.sort_values(by = ['Car_Number'])
        
        #test_df = temp_race_picks.pivot(columns = 'Car_Number', index = 'Contestant')
        #temp_race_picks.pivot(columns = 'Car_Number')
        
        temp_race_picks_dict = {
                                   'Contestant': [contestant],
                                   'Pick_1': [list(temp_race_picks['pick'])[0]],
                                   'Pick_2': [list(temp_race_picks['pick'])[1]],
                                   'Pick_3': [list(temp_race_picks['pick'])[2]],
                                   'Pick_4': [list(temp_race_picks['pick'])[3]],
                                   'Pick_5': [list(temp_race_picks['pick'])[4]]
                               }
        
        temp_race_picks_wide = pd.DataFrame.from_dict(temp_race_picks_dict)
        
        if race_picks_wide.empty:
            race_picks_wide = temp_race_picks_wide
        else:
            race_picks_wide = pd.concat([race_picks_wide, temp_race_picks_wide])
            
        race_picks_wide = race_picks_wide.sort_values(by = ['Contestant'])
    
    return race_picks_wide