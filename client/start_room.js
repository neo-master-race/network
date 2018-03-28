// all what we need to import
const net = require("net");
const messages = require("./messages_pb");

const client = new net.Socket();
client.setEncoding("utf-8");

client.connect(4242, "localhost", () => {
  send_msg();
  client.end();
});

function send_msg() {
  const message = msgEncode();
  const buff = Buffer.from(message);
  const len = Buffer.alloc(4); // size of a uint32
  len.writeUInt32LE(buff.length);
  const data = Buffer.concat([len, buff]);
  client.write(data);
}

// encode a message
function msgEncode() {
  const message = new messages.Message();
  const startRoom = new messages.StartRoom();
  message.setStartRoom(startRoom);
  return message.serializeBinary();
}
