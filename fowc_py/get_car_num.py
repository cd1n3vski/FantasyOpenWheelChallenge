# get car number
def get_car_num(race_picks, entry_list):
    
    race_picks['Car_Number'] = 0

    for i in range(0, len(race_picks)):
        race_picks['Car_Number'][i] = list(entry_list['Car_Number'][entry_list['Driver'] == race_picks['pick'].loc[i]])[0]
        
    return race_picks