include("BinaryIO.jl")
include("MailboxPipe2.jl")


using Formatting

MI = MailboxPipe2.MailboxInfo(".")
MailboxPipe2.reverseRole!(MI)

data = rand(Float64, 8)
buffer = zeros(UInt8, length(data) * 8)

MailboxPipe2.sendText(MI, format("{:d}", length(data)))

println("Going to send: ", data)

MailboxPipe2.sendBinary!(MI, data, buffer)



