# validation is used by other modules
validate = require('json-schema').validate
cfile = new require './fileops.coffee'
@include = ->
    vpnlib = require './vpnlib'

    @post '/openvpn/client': ->
        vpn = new vpnlib @request, @send, @params, @body, @next
        result = vpn.validateOpenvpnClient()
        if result instanceof Error
            return @next result
        else
            console.log 'schema is good'
            vpn.configClient (res) ->
                vpn.send res

    @post '/openvpn/server': ->
        vpn = new vpnlib @request, @send, @params, @body, @next
        result = vpn.validateOpenvpnServer()
        if result instanceof Error
            return @next result
        else
            vpn.configServer (res) ->
                vpn.send res
    
    @post '/openvpn/users': ->
        vpn = new vpnlib @request, @send, @params, @body, @next
        result = vpn.validateUser()
        if result instanceof Error
            return @next result
        else
            vpn.addUser (res) ->
                vpn.send res

    @del '/openvpn/users/:user': ->
        vpn = new vpnlib @request, @send, @params, @body, @next
        vpn.delUser (res) ->
            vpn.send res

            
    @get '/openvpn': ->
        vpn = new vpnlib @request, @send, @params, @body, @next
        vpn.getInfo 2020,"/var/log/server-status.log", "openvpn", (result) ->
            vpn.send result
