require_relative 'lib/sml/sml_reader'

# Start PV-Reader
def start_pv
  pid_pv = fork do
    reader_pv = SmlReader.new(device: '/dev/lesekopfPV', device_id: 'pv')
    reader_pv.start
  end

  Process.detach(pid_pv)
  pid_pv
end

# Start EVS-Reader
def start_evs
  pid_evs = fork do
    reader_evs = SmlReader.new(device: '/dev/lesekopfEVS', device_id: 'evs')
    reader_evs.start
  end

  Process.detach(pid_evs)
  pid_evs
end

# Is process with pid running
def running?(pid)
  begin
    Process.getpgid(pid)
  rescue StandardError
    return false
  end
  true
end

pid_evs = start_evs
pid_pv = start_pv

# Check if processes are running in background
# and restart if nescessary
Kernel.loop do
  start_evs unless running?(pid_evs)
  start_pv unless running?(pid_pv)
  sleep 10
end

# 1. Pro Device einen eigenen Prozess erstellen
# 2. Jeder Prozess sendet sein Ergebnis per http an einen "Webservice"
# 3. Dieser Webservice sorgt für die Weiterverarbeitung


