/*
 * Fill in your Plotly user credentials: Your username, api_key, and stream_tokens
 * or you can use the provided demo account's credentials.
 * Find your API key and generate stream tokens in your settings: https://plot.ly/settings
 * More info in the Plotly-Node.js docs here: https://github.com/plotly/plotly-nodejs
*/
var plotly_username = 'workshop';
var plotly_api_key = 'v6w5xlbx9j';
var plotly_stream_tokens = ['25tm9197rz', 'unbi52ww8a'];
var plotly = require('plotly')(plotly_username, plotly_api_key);

/*
 * Describe and embed stream tokens into a plotly graph
*/

var data = [
  {name: "Pin A0", x:[], y:[], stream:{token: plotly_stream_tokens[0], maxpoints:500}},
  {name: "Pin A1", x:[], y:[], stream:{token: plotly_stream_tokens[1], maxpoints:500}}
];
var layout = {fileopt : "overwrite", filename : "arduino-johnny5-demo"};


/*
 * Initialize Johnny-Five,
 * the communication layer between the Arduino and this node program.
*/

var five = require("johnny-five");
var board = new five.Board();

board.on("ready", function() {

  /*
   * Initialize a plotly graph
  */

  plotly.plot(data,layout,function (err, res) {

    if (err) console.log(err);
    console.log("STREAMING=", res.url);
    process.exit(2);
  });
});
