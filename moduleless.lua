------------------------------------------------------------------------
-- Copyright (C) 2012 Jay Kline
--
-- Adopted from LuaSec's https module
--
-- Author: Jay Kline
------------------------------------------------------------------------


local socket = require("socket")
local ssl    = require("ssl")
local smtp   = require("socket.smtp")
local try    = socket.try

-- Default Settings
PORT = 465 

local cfg = {
  protocol = "tlsv1",
  options  = "all",
  verify   = "none",
  port     = PORT
}

-- Forward calls to the real connection object.
local function reg(conn)
   local mt = getmetatable(conn.sock).__index
   for name, method in pairs(mt) do
      if type(method) == "function" then
         conn[name] = function (self, ...)
                         return method(self.sock, ...)
                      end
      end
   end
end

-- Return a function which performs the SSL/TLS connection.
local function tcp(params)
  params = params or {}
  -- Default settings
  for k, v in pairs(cfg) do
    params[k] = params[k] or v
  end
  -- Force client mode
  params.mode = "client"
  -- 'create' function for LuaSocket
  return function()
    local conn = {}
    conn.sock = try(socket.tcp())
    local st = getmetatable(conn.sock).__index.settimeout
    function conn:settimeout(...)
      return st(self.sock, ...)
    end
    function conn:connect(host, port)
      try(self.sock:connect(host, port))
      self.sock = try(ssl.wrap(self.sock, params))
      try(self.sock:dohandshake())
      reg(self, getmetatable(self.sock))
      return 1
    end
    return conn
  end
end  

------------------------------------------------------------------------
-- Main Functions
------------------------------------------------------------------------

function send(mailt)
  local mailt = mailt or {}
  mailt.create = tcp(mailt)
  return smtp.send(mailt)
end

function message(mesgt)
  return smtp.message(mesgt)
end





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

r, e = send{
  from = from,
  rcpt = rcpt, 
  source = smtp.message(mesgt),
  server = "smtp.example.com",
  user = "fulano@example.com",
  password = "theCrowFlysAtMidnight"

}
