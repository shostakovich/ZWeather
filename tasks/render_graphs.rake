task :render_graphs do
  def get_graph_command(key, key_name, label, period)
    command =  "rrdtool graph ./public/images/#{period}/#{key}.png -i "
    command += "--height=240 --width=889 --lazy -Y "
    command += "--alt-autoscale --disable-rrdtool-tag "
    command += "--color=BACK#FFFFFF --color=SHADEA#FFFFFF --color=SHADEB#FFFFFF "
    command += "--start end-#{period} "
    command += "--title \"#{key_name} #{label}\" "
    command += "DEF:#{key}AVG=./db/weatherdata.rrd:#{key}:AVERAGE "
    command += "LINE1:#{key}AVG#3366CC "

    if period != "1d"
      command += "DEF:#{key}min=./db/weatherdata.rrd:#{key}:MIN "
      command += "LINE2:#{key}min#7A9ED9 "
      command += "DEF:#{key}max=./db/weatherdata.rrd:#{key}:MAX "
      command += "LINE3:#{key}max#7A9ED9 "
    end
    command
  end

  periods = {
      "1d" => "letzte 24 Stunden",
      "1w" => "letzte Woche",
      "1m" => "letzter Monat",
      "1y" => "letztes Jahr"
  }
  graphs = {
      "voltage" => "Spannung",
      "temperature" => "Temperatur",
      "humidity" => "Luftfeuchtigkeit",
      "light" => "Licht",
      "wind" => "Wind",
      "pressure" => "Druck"
  }
  graphs.each do |key, key_name|
    periods.each do |period, label|
      command = get_graph_command(key,key_name, label, period)
      system(command)
    end
  end
end