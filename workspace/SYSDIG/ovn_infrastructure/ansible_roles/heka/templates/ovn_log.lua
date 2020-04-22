-- Open VisaNet   March 2016
-- We started with the linux_netstat.lua and replaced most parts of it to parse a simple key value payload.

--[[

Parses a payload containing the ovn_log format  (key value pairs)
as produced by the ovn_log API (which uses lager logging, the data of which is sent to HEKA using lager-syslog)

*Example Heka Configuration*

.. code-block:: ini

    [SYSLOG_UdpInput]
    type="UdpInput"
    address = "127.0.0.1:10514"
    decoder = "SYSLOG_decoder"

    [SYSLOG_decoder]
    type = "MultiDecoder"
    subs = ['OVN_decoder_header', 'OVNlog_decoder']
    cascade_strategy = "all"

    [OVNlog_Decoder]
    type = "SandboxDecoder"
    filename = "lua_decoders/ovn_log.lua"

*Example Heka Message*

:Timestamp: 2015-08-28 15:52:00 +0000 UTC
:Type: ovnswitch
:Hostname: sl73ovnapd012
:Pid: 0
:Uuid: 90c202d1-1375-4ec2-ac8c-eb53b2850d19
:Logger: UdpSyslog
:Payload: error while validating eas stations for access point 314515: timeout
:EnvVersion:
:Severity: 3
:Fields:
    | name:"mti_in" type:integer value:800
    | name:"mti_out" type:integer value:800
    | name:"rrn" type:string value:"<<\"608863676197\">>"
    | name:"erlangPid" type:string value:"<0.4770.2>"

--]]

local l = require 'lpeg'
l.locale(l)
local sp           = l.P(" ")
local key          = l.C((l.alnum * (1 - l.S('= '))^1))
local rawString    = l.C((1 - l.S(", \n"))^1)
local quotedString = l.C((l.P('\\"') + (1 - l.P('"')))^0)
local erlangtuple  = l.C(l.P{ "{" * ((1 - l.S"{}") + l.V(1))^0 * "}" })
local erlanglist   = l.C(l.P{ "[" * ((1 - l.S"[]") + l.V(1))^0 * "]" })
local erlangmap    = l.C(l.P{ "#{" * ((1 - l.S"{}") + l.V(1))^0 * "}" })
local erlangbinary = l.C(l.P{ "<<" * l.S("0123456789,")^1 * ">>" })
local erlangbinstr = l.C(l.P{ '<<"'* ((1 - l.P('"'))^1) * '">>' })
local integer      = l.digit^1 / tonumber
local double       = l.digit^1 * "." * l.digit^1 / tonumber
-- Order of value types is important. Basic should follow composite types
local value        = erlangtuple + erlanglist + erlangmap + erlangbinary + erlangbinstr +
                        '"' * quotedString * '"' + double + integer + rawString
local eol          = l.P("\r\n") + l.P("\n\r") + l.P("\n") + l.P("\r")
local datadelim    = l.P("; ") + eol
local kvdelim      = l.P(", ")
local mapkvdelim   = l.P("}") + l.P(",") + eol + sp

local pair = (l.Cg(key * "=" * value)) * kvdelim^0

local mappair = (l.Cg(key * " => " * value)) * mapkvdelim^0

local msgTimestamp = l.Cg(l.Cc("msgTimestamp") * l.C(
    l.digit^(4) * '-' * l.digit^(2) * '-' * l.digit^(2) * 'T' *
    l.digit^(2) * ':' * l.digit^(2) * ':' * l.digit^(2) * ('.' * (l.digit^(6) + l.digit^(3)))^0 * "Z"))
local loggedBy    = l.Cg(l.Cc("loggedBy") * l.P("\@") * l.C((1 - sp)^1))
local erlangPid   = l.Cg(l.Cc("erlangPid") * l.C(l.P{ "<" * l.digit^1 * '.' * l.digit^1 * '.' * l.digit^1 * ">" }))
local basepayload = l.Cg(l.Cc("basepayload") * l.C((1 - l.P(";"))^0))
local remainder   = l.Cg(l.Cc("remainder") * l.C((1 - l.P("\n\n"))^0))

grammar = l.Cf(l.Ct("") * sp^0 * msgTimestamp^0 * erlangPid^0 * loggedBy^0 * sp^0 * basepayload * datadelim^0 * pair^0 * eol^0 * remainder, rawset)
local mapgrammar = l.Cf(l.Ct("") * sp^0 * mappair^0 * remainder, rawset)

local msg = {
    Payload = nil,
    Fields = nil
}

function map_elements()
    return {acquiring_institution_id_code=0,
            acquiring_institution_country_code=0,
            card_authentication_results_code=0,
            card_issuer_routing_id=0,
            cvv_results_code=0,
            date_settlement=0,
            destination_issuer_routing_id=0,
            destination_pcr_id=0,
            destination_station_id_out=0,
            merchant_type=0,
            primary_account_number=0,
            processing_code_transaction_type=0,
            reject_code=0,
            response_code=0,
            response_source_reason_code=0
           }
end

function process_map(fields, mapmessage)
    local mapfields = mapgrammar:match(mapmessage)
    local elements = map_elements()
    for k,v in pairs(mapfields) do
        if elements[k] ~= nil then
            fields[k] = v
        end
    end
    fields.remainder=nil
    return fields
end

function process_mask(iso_message_in)
    iso, _, iso_message = iso_message_in:match('(.*)Bin=(.*)Hex=(.*)')
    local masks = iso_message:match('Masked=%[(.*)%]')
    if not masks then
        return iso_message_in
    end
    local mask_pair = (l.Cg("{" * integer * "," * integer * "}")) * l.P(",")^0
    local maskgrammar = l.Cf(l.Ct("") * mask_pair^0, rawset)
    local mask_map = maskgrammar:match(masks)
    for offset, length in pairs(mask_map) do
        offset = (tonumber(offset) * 2)
        length = (tonumber(length) * 2)
        iso_message = string.sub(iso_message, 1, offset) .. string.rep("F", length) ..
                        string.sub(iso_message, offset + 1 + length, -1)
    end
    return iso_message
end

function process_log_message(log_message)

    local newfields = grammar:match(log_message)
    
    if not newfields then
        error("Failed to match grammar")
    end

    -- Add  the crc32  field here
    local crc32 = require 'CRC32'
    local crc32hash = nil
    local p1, p2 = newfields.basepayload:match("([^:]+):([^:]+)")
    if p1 then
        crc32hash = string.format("OVN-%4X",crc32.Hash(p1))
    else
        crc32hash = string.format("OVN-%4X",crc32.Hash(newfields.basepayload))
    end

    if newfields.remainder then
        newfields.remainder = newfields.remainder:gsub("#012","\n")
        newfields.remainder = newfields.remainder:gsub("#011","\t")
    end

    -- if there is a one time contextmap or messagemap or an iso message in the remainder then capture it
    if newfields.remainder then
        local iso_message = newfields.remainder:match('IsoMessage(.*)')
        if iso_message then
            newfields.iso_message = process_mask(iso_message)
            newfields.remainder = nil
        end
    end

    if newfields.remainder then
        local message = newfields.remainder:match('Message=(.*)')
        if message then
            local messagemap = message:match('#{(.*)}')
            if messagemap then
                newfields = process_map(newfields, messagemap)
                newfields.messagemap = message
            else
                newfields.message = message
                newfields.remainder = nil
            end
        end
    end

    if newfields.remainder then
        local contextmap = newfields.remainder:match('Context=(.*)')
        if contextmap then
            newfields = process_map(newfields, contextmap:match('context,#{(.*)}(.*)}'))
            newfields.contextmap = contextmap
        end
    end

    msg.Payload = newfields.basepayload            -- here is the new payload
    msg.Timestamp = read_message("Timestamp")      -- :-(  a pity ESJsonencoder still loses the milliseconds on the timestamp
    newfields.logTimestamp = read_message("Fields[logTimestamp]")
    newfields.basepayload = nil
    newfields.msghash=crc32hash
    msg.Fields = newfields
    return 0
end

function process_message()
    local payload = read_message("Payload")
    local status, reason = pcall(process_log_message, payload)
    if not status then
        -- print(err.code)  -->  121
        msg.Payload = payload
        msg.Fields = {reason=reason, error="log parsing failed"}
    end
    inject_message(msg)
    return 0
end
