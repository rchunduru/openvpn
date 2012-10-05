# validation is used by other modules
validate = require('json-schema').validate
vpnlib = require './vpnlib'
uuid = require 'node-uuid'
@include = ->

    vpn = new vpnlib
    configpath = "/config/openvpn"
  
    validateClientSchema = ->
        result = validate @body, vpn.clientSchema
        console.log result
        return @next new Error "Invalid openvpn client configuration posting!: #{result.errors}" unless result.valid
        @next()

    validateServerSchema = ->
        result = validate @body, vpn.serverSchema
        console.log result
        return @next new Error "Invalid openvpn server configuration posting!: #{result.errors}" unless result.valid
        @next()

    validateUser = ->
        result = validate @body, vpn.userSchema
        console.log result
        return @next new Error "Invalid openvpn user configuration posting!: #{result.errors}" unless result.valid
        @next()

    @post '/openvpn/client', validateClientSchema, ->
        id = uuid.v4()
        filename = configpath + "\#{id}.conf"
        vpn.configvpn @body, id, filename, (res) =>
            @send res

    @del '/openvpn/client/:client': ->
        vpn.delInstance @params.client, (res) =>
            @send res


    @post '/openvpn/server', validateServerSchema, ->
        id = uuid.v4()
        filename = configpath + "\server.conf"
        #only one server instance, identified by "server" as id in the database
        vpn.configvpn @body, id, filename, (res) =>
            @send res
    
    @del '/openvpn/server/:server': ->
        vpn.delInstance @params.server , (res) =>
            @send res


    @post '/openvpn/server/:id/users', validateUser, ->
        file =  if @body.email then @body.email else @body.cname
        #get ccdpath from the DB
        ccdpath = vpn.getCcdPath @params.id
        filename = ccdpath + "\#{file}"
        vpn.addUser @body, filename, (res) =>
            @send res

    @del '/openvpn/server/:id/users/:user': ->
        #get ccdpath from the DB
        ccdpath = vpn.getCcdPath @params.id
        vpn.delUser @params.user, ccdpath, (res) =>
            @send res

            
    @get '/openvpn/server/:id': ->
        #get vpnmgmtport from DB for this given @params.id
        vpnmgmtport = vpn.getMgmtPort @params.id
        vpn.getInfo vpnmgmtport, serverstatus, @params.id, (result) ->
            vpn.send result

    @get '/openvpn/client': ->
        #get list of client instances from the DB
        @send 'yet to implement /openvpn/client'

    @get '/openvpn/server': ->
        #get list of server instances from the DB
        @send 'yet to implement /openvpn/server'
