import React from "react";
import HomeIndex from "./pages/home/Index.jsx";

const routes = {
    "/": () => <HomeIndex />,
    "/about": () => <div className="container mx-auto">About Page from React.js</div>
};

export default routes;