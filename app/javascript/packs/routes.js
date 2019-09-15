import React from "react";
import HomeIndex from "./pages/home/Index.jsx";

const routes = {
    "/home": () => <HomeIndex />,
    "/about": () => <h2>About Page from React.js</h2>
};

export default routes;