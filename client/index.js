// all what we need to import
const net      = require('net');
const readline = require('readline');
const prompts  = require('prompts');
const messages = require('./messages_pb');

// informations we need to ask the user about the server location
async function askDetails() {
  let questions = [
    {
      type: 'text',
      name: 'host',
      message: 'Server host',
      initial: 'localhost'
    },
    {
      type: 'number',
      name: 'port',
      message: 'Server port',
      initial: 4242,
      min: 0,
      max: 65535
    },
    {
      type: 'text',
      name: 'user',
      message: 'Username',
      initial: 'NodeJS'
    },
  ];
  return await prompts(questions);
};

// first we get all needed informations from the user, then we create the socket
askDetails().then(response => {

  // just to store the user
  const user = response.user;

  // readline init
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  // client socket init
  const client = new net.Socket();
  client.setEncoding('utf-8');

  function send_msg(msg) {
    const buff = Buffer.from(msg);
    const len  = Buffer.alloc(4); // size of a uint32
    len.writeUInt32LE(buff.length);
    client.write(Buffer.concat([len, buff]));
  }

  // try to connect
  client.connect(response.port, response.host, () => {
    console.log(`Connected to ${response.host}:${response.port}!`);
    console.log('Type /quit to exit.\n\n');
    send_msg("Node client connected!");
  });

  // when we receive data, we log it in the console
  client.on('data', data => {
    console.log(data.replace(/\n$/, ''));
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
      console.log("Goodbye!");
    } else {
      send_msg(data);
    }
  });
});
