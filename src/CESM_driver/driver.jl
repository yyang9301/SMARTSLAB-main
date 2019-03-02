include("parseMsg.jl")

if isdir(wdir)
    cd(wdir)
else
    throw(ErrorException("Working directory [ " * wdir * " ] does not exist."))
end



stage = :INIT
mail = MailboxInfo()

map = NetCDFIO.MapInfo{Float64}(domain_file)
ncio = NetCDFIO.MapInfo{Float64}(domain_file)



time_i = 1 
wrap_time = i -> ((time_i-1) % output_record_length) + 1
output_filename = ""


beg_time = Base.time()
while true

    global stage, time_i, output_filename

    end_time = Base.time()

    println(format("Execution time: {:d}", floor(end_time - beg_time)))

    if wrap_time(time_i) == 1
        output_filename = format("SSM_output_{:03d}.nc", convert(Integer, 1+floor((time_i-1) / output_record_length)))
        
        NetCDFIO.createNCFile(map, output_filename)
    end

    println(format("# Time counter : {:d}", time_i))
    println(format("# Stage        : {}", String(stage)))

    msg = parseMsg(recv(mail))
    println("==== MESSAGE RECEIVED ====")
    print(json(msg, 4))
    println("==========================")

    # need to parse time

    if stage == :INIT && msg["MSG"] == "INIT"

        println("Calling initilizer")
        println("===== INITIALIZING MODEL: ", OM.name , " =====")
        OM.init()
        println("===== ", OM.name, " IS READY =====")

        writeBinary!(msg["SST"], OM.getSST(), buffer2d; endianess=:little_endian)
        send(mail, msg["SST"])

        time_i += 1

        stage = :RUN
        
    elseif stage == :RUN && msg["MSG"] == "RUN"

        for varname in needed_varnames 
            readBinary!(msg[varname],   needed_var_containers[varname], buffer2d; endianess=:little_endian, delete=false)
        end
       
        println("Calling ", OM.name, " to do MAGICAL calculations")
        OM.run(
            t  = CESM_time,
            Δt = parse(Float64, msg["DT"])
        ) 

        writeBinary!(msg["SST_NEW"], OM.getSST(), buffer2d; endianess=:little_endian)
        send(mail, msg["SST_NEW"])

        time_i += 1

    elseif stage == :RUN && msg["MSG"] == "END"

        println("Simulation ends peacefully.")
        break
    else
        send(mail, "CRASH")
        throw(ErrorException("Unknown status: stage " * stage * ", MSG: " * String(msg["MSG"])))
    end

end


