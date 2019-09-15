import React, { useState, useEffect } from "react";
import api from 'utils/api';

function Index() {
    const [ helloWorld, setHelloWorld ] = useState('loading...');

    useEffect(() => {
        console.log(window, 'mount');
        api.get('/api/home/index').then((res) => {
            setHelloWorld(res.data.hello);
        });
        return () => {
            console.log(window, 'unmount')
        }
    }, []);

    return (
        <div>
            <h2>HomeIndex Page from React.js</h2>
            <p>{helloWorld}</p>
        </div>
    );
}

export default Index;
