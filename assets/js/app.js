// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.scss';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';
import 'bootstrap';


// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import './components/base';

// Turbolinks
import Turbolinks from 'turbolinks';
Turbolinks.start();

// Load fonts async
import WebFont from 'webfontloader';

WebFont.load({
  custom: {
    families: ['simple-line-icons'],
    urls: ['//cdnjs.cloudflare.com/ajax/libs/simple-line-icons/2.4.1/css/simple-line-icons.css'],
  },
  google: {
    families: ['Open Sans:300,400', 'Bree Serif'],
  },
});
