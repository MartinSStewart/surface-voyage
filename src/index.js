import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

let app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: {
        windowWidth: window.innerWidth,
        windowHeight: window.innerHeight
    }
});
registerServiceWorker();
