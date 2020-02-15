import React, {useState, useEffect} from "react";
import {A} from "hookrouter";
import api from 'utils/api';

function Index() {
    const [helloWorld, setHelloWorld] = useState('loading...');

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
      <div className="container pt-24 md:pt-48 px-6 mx-auto flex flex-wrap flex-col md:flex-row items-center">
          <div className="flex flex-col w-full xl:w-2/5 justify-center lg:items-start overflow-y-hidden">
              <h1
                className="my-4 text-3xl md:text-5xl text-purple-800 font-bold leading-tight text-center md:text-left slide-in-bottom-h1">
                  rails-template
              </h1>
              <p
                className="leading-normal text-base md:text-2xl mb-8 text-center md:text-left slide-in-bottom-subtitle">
                  Hello World
              </p>
              <p className="text-red-400 font-bold pb-8 lg:pb-6 text-center md:text-left fade-in">Rails: {helloWorld}</p>
              <p className="text-blue-400 font-bold pb-8 lg:pb-6 text-center md:text-left fade-in">React: {React.version} ({process.env.NODE_ENV})</p>
          </div>
          <div className="w-full pt-16 pb-6 text-sm text-center md:text-left fade-in">
              <a className="text-gray-500 no-underline hover:no-underline" href="#">&copy; Astrocket 2020</a>
          </div>
      </div>
    );
}

export default Index;
