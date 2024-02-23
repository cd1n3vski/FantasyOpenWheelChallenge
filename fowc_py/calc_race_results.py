def calc_race_results(race_picks, indycar_results, race):
    
    import pandas as pd
    
    race_picks_sub = race_picks[race_picks['race'] == race]
    
    race_picks_sub['points'] = 0
    
    fowc_race_results = pd.DataFrame(columns = ['Contestant', 'Pick_1', 'Pick_2', 'Pick_3', 'Pick_4', 'Pick_5'
                                                ,'Pick_1_Points', 'Pick_2_Points', 'Pick_3_Points', 'Pick_4_Points'
                                                ,'Pick_5_Points'])
    
    for i in range(0, len(race_picks_sub)):
        race_picks_sub['points'][i] =  list(indycar_results['points']\
                                            [(indycar_results['race'] == race) &\
                                             (indycar_results['driver'] == race_picks_sub['pick'].loc[i])])[0]
    
    race_picks_sub = race_picks_sub.sort_values(by = ['name', 'points'], ascending = [True, False])
    
    contestants = list(race_picks_sub['name'].unique())
    
    for contestant in contestants:
        
        temp_race_picks_sub = race_picks_sub[race_picks_sub['name'] == contestant]
        
        temp_fowc_race_results = {
                                     'Contestant': [contestant],
                                     'Pick_1_Name': [list(temp_race_picks_sub['pick'])[0]],
                                     'Pick_2_Name': [list(temp_race_picks_sub['pick'])[1]],
                                     'Pick_3_Name': [list(temp_race_picks_sub['pick'])[2]],
                                     'Pick_4_Name': [list(temp_race_picks_sub['pick'])[3]],
                                     'Pick_5_Name': [list(temp_race_picks_sub['pick'])[4]],
                                     'Pick_1_Points': [list(temp_race_picks_sub['points'])[0]],
                                     'Pick_2_Points': [list(temp_race_picks_sub['points'])[1]],
                                     'Pick_3_Points': [list(temp_race_picks_sub['points'])[2]],
                                     'Pick_4_Points': [list(temp_race_picks_sub['points'])[3]],
                                     'Pick_5_Points': [list(temp_race_picks_sub['points'])[4]],
                                     'Total_Points': [list(temp_race_picks_sub['points'])[0] +\
                                                      list(temp_race_picks_sub['points'])[1] +\
                                                      list(temp_race_picks_sub['points'])[2] +\
                                                      list(temp_race_picks_sub['points'])[3] +\
                                                      list(temp_race_picks_sub['points'])[4]]
                                 }
        
        temp_fowc_race_results = pd.DataFrame.from_dict(temp_fowc_race_results)
        
        if fowc_race_results.empty:
            fowc_race_results = temp_fowc_race_results
        else:
            fowc_race_results = pd.concat([fowc_race_results, temp_fowc_race_results], ignore_index = True)
            
    fowc_race_results = fowc_race_results.sort_values(by = ['Total_Points', 'Pick_1_Points', 'Pick_1_Points'
                                                            ,'Pick_3_Points', 'Pick_4_Points', 'Pick_5_Points']
                                                      ,ascending = [False, False, False, False, False, False])
    
    fowc_race_results = fowc_race_results.reset_index()
    
    fowc_race_results['Position'] = 0
    fowc_race_results['Pick_1'] = 0
    fowc_race_results['Pick_2'] = 0
    fowc_race_results['Pick_3'] = 0
    fowc_race_results['Pick_4'] = 0
    fowc_race_results['Pick_5'] = 0
    
    for i in range(0, len(fowc_race_results)):
        fowc_race_results['Position'].loc[i] = i + 1
        fowc_race_results['Pick_1'].loc[i] = f"{fowc_race_results['Pick_1_Name'][i]} - {fowc_race_results['Pick_1_Points'][i]}"
        fowc_race_results['Pick_2'].loc[i] = f"{fowc_race_results['Pick_2_Name'][i]} - {fowc_race_results['Pick_2_Points'][i]}"
        fowc_race_results['Pick_3'].loc[i] = f"{fowc_race_results['Pick_3_Name'][i]} - {fowc_race_results['Pick_3_Points'][i]}"
        fowc_race_results['Pick_4'].loc[i] = f"{fowc_race_results['Pick_4_Name'][i]} - {fowc_race_results['Pick_4_Points'][i]}"
        fowc_race_results['Pick_5'].loc[i] = f"{fowc_race_results['Pick_5_Name'][i]} - {fowc_race_results['Pick_5_Points'][i]}"
        
    fowc_race_results_final = fowc_race_results[['Position', 'Contestant', 'Pick_1', 'Pick_2', 'Pick_3', 'Pick_4', 'Pick_5'\
                                                 ,'Total_Points']]
            
    return fowc_race_results_final