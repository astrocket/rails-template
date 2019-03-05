import axios from 'axios';

function getQueryString(params) {
    return Object.keys(params)
        .map(k => encodeURIComponent(k) + '=' + encodeURIComponent(params[k]))
        .join('&');
}

const get = (path, params) => {
    const qs = '?' + getQueryString(params || {});

    return axios({
        method: 'get',
        url: path + qs
    })
};

const post = (path, params, headers = null) => {
    headers = headers || {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    };
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    return axios({
        method: 'post',
        url: path,
        headers: headers,
        data: params
    })
};

export default {
    get: get,
    post: post
}
