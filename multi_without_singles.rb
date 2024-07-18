require 'bet'
require 'csv'

MONTH = 'aug23'

def win_format_array(day_array)
  new_day_array = []
  day_array.each do |day|
    bet = []
    case day['result']
    when 'L', 'P', 'EP'
      bet.push(0)
      bet.push(:loss)
    when 'W'
      bet.push(day['odds'].to_f * day['r4'].to_f)
      bet.push(:win)
    when 'NR'
      bet.push(1)
      bet.push(:nr)
    else
      return nil
    end
    new_day_array.append(bet)
  end
  return new_day_array
end

def place_format_array(day_array)
  new_day_array = []
  day_array.each do |day|
    bet = []
    case day['result']
    when 'L'
      bet.push(1)
      bet.push(:loss)
    when 'W', 'P', 'EP'
      odds = ((((day['odds'].to_f - 1) * day['r4'].to_f) / 5 ) + 1 ).round(2)
      bet.push(odds)
      bet.push(:win)
    when 'NR'
      bet.push(1)
      bet.push(:nr)
    else
      return new_day_array
    end
    new_day_array.append(bet)
  end
  return new_day_array
end

file = CSV.parse(File.read(MONTH + ".csv"), headers: true)
days = []
day = ''
day_list=[]
file.each do |row|
  if day != row['Date']
    day = row['Date']
    if day_list.length > 0
      days.append(day_list)
    end
    day_list = []
  end
  bet = {}
  bet['date'] = row['Date']
  bet['r4'] = row['R4']
  bet['odds'] = row['Odds']
  bet['terms'] = row['Terms']
  bet['result'] = row['Result']
  day_list.append(bet)
end
days.append(day_list)

results = []
days.each { |day|
  p day[0]['date']
  w_arr = win_format_array(day)
  p_arr = place_format_array(day)
  if w_arr.nil? or p_arr.nil?
    p 'Not processed'
    result = {}
    result['date'] = day[0]['date']
    result['type'] = ''
    result['return'] = 0
    result['profit'] = 0
    results.push(result)
    next
  end

  case day.length
  when 2
    type = 'double'
    wb = Bet::Calc.double(w_arr, stake: 0.05)
    eb = Bet::Calc.double(p_arr, stake: 0.05)
  when 3
    type = 'trixie'
    wb = Bet::Calc.trixie(w_arr, stake: 0.05)
    eb = Bet::Calc.trixie(p_arr, stake: 0.05)
  when 4
    type = 'yankee'
    wb = Bet::Calc.yankee(w_arr, stake: 0.05)
    eb = Bet::Calc.yankee(p_arr, stake: 0.05)
  when 5
    type = 'canadian'
    wb = Bet::Calc.canadian(w_arr, stake: 0.05)
    eb = Bet::Calc.canadian(p_arr, stake: 0.05)
  when 6
    type = 'heinz'
    wb = Bet::Calc.heinz(w_arr, stake: 0.05)
    eb = Bet::Calc.heinz(p_arr, stake: 0.05)
  when 7
    type = 'super-heinz'
    wb = Bet::Calc.super_heinz(w_arr, stake: 0.05)
    eb = Bet::Calc.super_heinz(p_arr, stake: 0.05)
  else
    result = {}
    result['date'] = day[0]['date']
    result['type'] = 'unknown'
    result['return'] = 0
    result['profit'] = 0
    results.push(result)
    next
  end

  p "The %s outlay is £%0.2f" % [type, (wb[:outlay] + eb[:outlay]).round(2)]
  p "The %s return is £%0.2f" % [type, (wb[:returns] + eb[:returns]).round(2)]
  p "The %s profit is £%0.2f" % [type, (wb[:profit] + eb[:profit]).round(2)]
  p "The %s points is %0.2f" % [type, (wb[:points] + eb[:points]).round(2)]
  result = {}
  result['date'] = day[0]['date']
  result['type'] = type
  result['outlay'] = (wb[:outlay] + eb[:outlay]).round(2)
  result['return'] = (wb[:returns] + eb[:returns]).round(2)
  result['profit'] = (wb[:profit] + eb[:profit]).round(2)
  result['points'] = (-1 + (result['return'] / result['outlay'])).round(2)
  results.push(result)
}

CSV.open("results_" + MONTH + ".csv", "wb") do |csv|
  csv << results.first.keys # adds the attributes name on the first line
    results.each do |hash|
    csv << hash.values
  end
end
