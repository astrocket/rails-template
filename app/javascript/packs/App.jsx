import React from "react";
import {useRoutes, usePath} from "hookrouter";
import routes from "./routes";
import Navigation from "./components/Navigation.jsx";

function App() {
  const routeResult = useRoutes(routes);
  const currentPath = usePath();
  if (/^\/app(.*)/.test(currentPath)) {
    return null;
  }

  return (
    <div className="leading-normal tracking-normal text-gray-900">
      <Navigation/>
      <div className="pb-14 bg-right bg-cover bg-gray-100 py-6 lg:pb-20 lg:pt-8 px-3 lg:px-0">
        <div className="container mx-auto">
          <div className="mx-auto" style={{ maxWidth: "768px" }}>
            {routeResult || <h1>404 on React SPA</h1>}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;