require_relative 'lib/sml/sml_reader'

# Start PV-Reader
def start_pv
  pid_pv = fork do
    reader_pv = SmlReader.new(device: '/dev/lesekopf0')
    reader_pv.start
  end

  Process.detach(pid_pv)
  pid_pv
end

# Start EVS-Reader
def start_evs
  pid_evs = fork do
    reader_evs = SmlReader.new(device: '/dev/lesekopf1')
    reader_evs.start
  end

  Process.detach(pid_evs)
  pid_evs
end

start_pv

# 1. Pro Device einen eigenen Prozess erstellen
# 2. Jeder Prozess sendet sein Ergebnis per http an einen "Webservice"
# 3. Dieser Webservice sorgt für die Weiterverarbeitung


