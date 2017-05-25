require "resources/essentialmode/lib/MySQL"

--Configuration de la connexion vers la DB MySQL
MySQL:open("127.0.0.1", "fivem", "root", "florent")

RegisterServerEvent("medics:printConsole")
AddEventHandler('medics:printConsole', function(data)
  print("from client :", data)
end)
