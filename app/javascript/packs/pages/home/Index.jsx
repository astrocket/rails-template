import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

function Index() {

    useEffect(() => {
        console.log(window, 'mount');

        return () => {
            console.log(window, 'unmount')
        }
    }, []);

    return (
        <h2>HomeIndex Page from React.js</h2>
    );
}

export default Index;
