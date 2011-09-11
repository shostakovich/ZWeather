task :fetch_serial_data do
  require 'rubygems'
  require 'serialport'
  require 'sqlite3'

  sp = SerialPort.new("/dev/tty.usbserial-00201124", 9600, 8, 1, SerialPort::NONE)

  def save_sample(raw_sample)
    all, pressure, temperature, humidity, light, wind, millivolts = parse_sample(raw_sample)

    voltage = millivolts.to_f / 1000
    begin
      db = SQLite3::Database.new( "./db/development.sqlite3" )
      db.execute("INSERT INTO data_sets
                (pressure, temperature, humidity, light, wind, voltage,created_at,updated_at)
                VALUES (?,?,?,?,?,?, datetime('now'), datetime('now'))",
               pressure, temperature, humidity, light, wind, voltage)
    rescue Exception => e
      puts e
    end
    rrd_command ='rrdupdate ./db/weatherdata.rrd'
    rrd_command += " N:#{temperature}:#{voltage}:#{humidity}:#{light}:#{wind}:#{pressure}"
    system(rrd_command)
  end

  def parse_sample(raw_sample)
    regex = /p: ([0-9]+); t: ([0-9.]+); h: ([0-9.]+); l: ([0-9]+); w: ([0-9]+); v: ([0-9]+);/
    raw_sample.split(regex)
  end

  loop do
    line = sp.gets
    if line
      save_sample(line)
    else
      sleep 5
      next
    end
    sp.puts line rescue exit 1
  end
end