-- load the smtps support
local smtps = require("smtps")

-- Connects to server "smtp.example.com" on port 465 with the username 
-- "fulano@example.com" and password "TheCrowFlysAtMidnight" 
-- sends a message to users  "fulano@example.com",  "beltrano@example.com", 
-- and "sicrano@example.com".
-- Note that "fulano" is the primary recipient, "beltrano" receives a
-- carbon copy and neither of them knows that "sicrano" received a blind
-- carbon copy of the message.
from = "<luasocket@example.com>"

rcpt = { "<fulano@example.com>",
         "<beltrano@example.com>",
         "<sicrano@example.com>"
 }

mesgt = {
  headers = {
    to = "Fulano da Silva <fulano@example.com>",
    cc = '"Beltrano F. Nunes" <beltrano@example.com>',
    subject = "My first message"
  },
  body = "I hope this works. If it does, I can send you another 1000 copies."
}

r, e = smtp.send{
  from = from,
  rcpt = rcpt, 
  source = smtp.message(mesgt),
  server = "smtp.example.com",
  user = "fulano@example.com",
  password = "theCrowFlysAtMidnight"

}
