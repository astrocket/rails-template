import React from "react";
import {useRoutes, A} from "hookrouter";
import routes from "./routes";
import Navigation from "./components/Navigation.jsx";

function App() {
  const routeResult = useRoutes(routes);
  return (
    <div className="leading-normal tracking-normal text-gray-900">
      <Navigation/>
      <div className="h-screen pb-14 bg-right bg-cover">
        {routeResult || <h1>404 on React SPA</h1>}
      </div>
    </div>
  );
}

export default App;