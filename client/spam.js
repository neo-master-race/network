// all what we need to import
const net = require('net');
const messages = require('./messages_pb');

const client = new net.Socket();
client.setEncoding('utf-8');

client.connect(4242, 'localhost', () => {
  for (i = 0; i < 1000000; i++) {
    send_msg('SPAM ' + i);
  }
  client.end();
});

function send_msg(msg) {
  const message = msgEncode(msg, 'SPAM');
  const buff = Buffer.from(message);
  const len = Buffer.alloc(4); // size of a uint32
  len.writeUInt32LE(buff.length);
  const data = Buffer.concat([len, buff]);
  client.write(data);
}

// encode a message
function msgEncode(content, user) {
  const message = new messages.Message();
  const chatMessage = new messages.ChatMessage();
  chatMessage.setContent(content);
  chatMessage.setUser(user);
  message.setType('chat_message');
  message.setChatMessage(chatMessage);
  return message.serializeBinary();
}
