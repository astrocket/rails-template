import React from "react";
import { useRoutes, A } from "hookrouter";
import routes from "./routes";

function App() {
    const routeResult = useRoutes(routes);
    return (
        <div>
            <A href='/home'>React SPA /home</A>
            <br/>
            <A href='/about'>React SPA /about</A>
            <br/>
            <a href="/">Rails SSR /</a>
            <hr/>
            {routeResult || <h1>404 on React SPA</h1>}
        </div>
    );
}

export default App;