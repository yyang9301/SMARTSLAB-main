

module TBIO

    using Formatting
    export readTB!, writeTB

    function readTB!(
        filename   :: AbstractString,
        txt_nchars :: Integer,
        arrs       :: AbstractArray{T};
        endianess  :: Symbol = :LITTLE,   # Small: 0x04030201,  Big: 0x01020304
        trim       :: Bool   = true,
    ) where T <: AbstractArray{Float64}

        if endianess != :LITTLE && endianess != :BIG
            throw(ErrorException("Unknown symbol: " * string(endianess)))
        end

        if txt_nchars < 0
            throw(ErrorException("txt_nchars cannot be negative."))
        end

        msg = nothing
        if isfile(filename)

            get_filesize = filesize(filename)
            expect_filesize = sum(length.(arrs)) * 8 + txt_nchars
            if get_filesize == expect_filesize 

                open(filename, "r") do io
                    msg = String(read(io, txt_nchars))
                    
                    trim && (msg = strip(msg))
                    
                    for i = 1:length(arrs)
                        read!(io, arrs[i])
                    end

                    if     endianess == :LITTLE && Base.ENDIAN_BOM == 0x01020304
                        for i = 1:length(arrs)
                            arrs[i][:] = ltoh.(arrs[i])
                        end
                    elseif endianess == :BIG && Base.ENDIAN_BOM == 0x04030201
                        for i = 1:length(arrs)
                            arrs[i][:] = ntoh.(arrs[i])
                        end
                    end
                end
            else 
                println(format("[readTB!] Expecting filesize: {} bytes, but got {} bytes", expect_filesize, get_filesize))
            end
        else
            println(format("[readTB!] File {} does not exist.", filename))
        end

        return msg
    end


    function writeTB(
        filename   :: AbstractString,
        msg        :: AbstractString,
        txt_nchars :: Integer,
        arrs       :: AbstractArray{T};
        endianess  :: Symbol = :LITTLE,
    ) where T <: AbstractArray{Float64}


        if endianess != :LITTLE && endianess != :BIG
            throw(ErrorException("Unknown symbol: " * string(endianess)))
        end

        if length(msg) > txt_nchars
            throw(ErrorException("Message length exceeds txt_nchars."))
        end

        if txt_nchars < 0
            throw(ErrorException("txt_nchars cannot be negative."))
        end

        open(filename, "w") do io
            write(io, msg)
            
            for i = 1:(txt_nchars - length(msg))
                write(io, " ")
            end

            if     endianess == :LITTLE && Base.ENDIAN_BOM == 0x01020304
                for i = 1:length(arrs)
                    write(io, htol.(arrs[i]))
                end
            elseif endianess == :BIG && Base.ENDIAN_BOM == 0x04030201
                for i = 1:length(arrs)
                    write(io, hton.(arrs[i]))
                end
            else
                for i = 1:length(arrs)
                    write(io, arrs[i])
                end
            end
        end
    end

end

