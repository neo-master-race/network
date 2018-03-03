// all what we need to import
const net = require('net');
const readline = require('readline');
const prompts = require('prompts');
const messages = require('./messages_pb');

// informations we need to ask the user about the server location
async function askDetails() {
  let questions = [
    {
      type: 'text',
      name: 'host',
      message: 'Server host',
      initial: 'localhost',
    },
    {
      type: 'number',
      name: 'port',
      message: 'Server port',
      initial: 4242,
      min: 0,
      max: 65535,
    },
    {
      type: 'text',
      name: 'user',
      message: 'Username',
      initial: 'NodeJS-' + Math.floor(Math.random() * 65535),
    },
  ];
  return await prompts(questions);
}

// encode a message
function msgEncode(content, user) {
  let message = new messages.Message();
  message.setContent(content);
  message.setUser(user);
  return message.serializeBinary();
}

// decode a message
function msgDecode(msg) {
  let message;
  try {
    message = messages.Message.deserializeBinary(new Uint8Array(msg));
  } catch (e) {
    // in case the message was sent without protobuf
    message = new messages.Message();
    message.setContent(msg);
  }
  return message;
}

// first we get all needed informations from the user, then we create the socket
askDetails().then(response => {
  // just to store the user
  const user = response.user;

  // readline init
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  // client socket init
  const client = new net.Socket();
  client.setEncoding('utf-8');

  // convert the message and send it
  function send_msg(msg) {
    const message = msgEncode(msg, user);
    const buff = Buffer.from(message);
    const len = Buffer.alloc(4); // size of a uint32
    len.writeUInt32LE(buff.length);
    const data = Buffer.concat([len, buff]);
    client.write(data);
  }

  // when we receive data, we log it in the console
  function get_msg(msg) {
    const message = msgDecode(Buffer.from(msg));
    const getUser = message.getUser();
    const msgFrom = getUser === '' ? 'BAD_INPUT=' : getUser + ': ';
    console.log(msgFrom + message.getContent().toString());
  }

  // try to connect
  client.connect(response.port, response.host, () => {
    console.log(`Connected to ${response.host}:${response.port}!`);
    console.log('Type /quit to exit.\n\n');
    send_msg('Node client connected!');
  });

  // do some work when receiving data
  client.on('data', data => {
    let buff = Buffer.from(data);
    let len = buff.readUInt32LE();
    let msg = buff.slice(4); // size of a uint32

    if (msg.length == len) {
      get_msg(msg);
    } else {
      // in the case if there are many messages in one time
      while (msg.length > len) {
        get_msg(msg.slice(0, len));
        buff = msg.slice(len);
        len = buff.readUInt32LE();
        msg = buff.slice(4); // size of a uint32
        if (msg.length == len) {
          get_msg(msg);
        }
      }

      // if something is missing
      if (msg.length < len) {
        console.error('Error: some data are missing from: ' + msg.toString());
      }
    }
  });

  // error handling
  client.on('error', err => {
    console.error(`  !!  ${err}.`);
    client.destroy();
    rl.close();
  });

  // when we read a user input
  rl.on('line', data => {
    if (data == '/quit') {
      client.destroy();
      rl.close();
      console.log('Goodbye!');
    } else {
      send_msg(data);
    }
  });
});
