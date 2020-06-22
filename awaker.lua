local STANZA = require "util.stanza";
local users = {
    {jid = "", name = "", mac = ""},
}

            
--thanks to https://gist.github.com/maiconio/2865500
function split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--thanks to https://gist.github.com/maiconio/2865500
function wake(mac)
    mac_dest = mac

    socket = require("socket")
    ip="255.255.255.255"
    port=9
    udp = assert(socket.udp())
    udp:setoption('broadcast', true)

    mac_array=split(mac_dest, ":")
    mac = ""
    for i,v in ipairs(mac_array) do mac = mac..string.char(tonumber("0x"..v));  end
    mac1=""
    for i=1,16 do
    mac1 = mac1..mac
    end
    mac2 = string.char(0xff,0xff,0xff,0xff,0xff,0xff)..mac1
    assert(udp:sendto(mac2, ip, port))
end


function riddim.plugins.awaker(bot)
    local function process_message(msg)
        local body = msg.body
        if body then
            if body:lower():match("awake") then
                i = 1
                found = false
                while i <= #users and not found do
                    if body:lower():match(users[i].name) or msg.sender.jid:match(users[i].jid) then
                        wake(users[i].mac)
                        found = true
                    end
                    i = i +1
                end
            end
        end
    end
    
    bot:hook("message", process_message);
end
