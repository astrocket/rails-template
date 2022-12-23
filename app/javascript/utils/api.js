import axios from 'axios';

function getQueryString(params) {
    return Object.keys(params)
        .map(k => encodeURIComponent(k) + '=' + encodeURIComponent(params[k]))
        .join('&');
}

const get = (path, params) => {
    const qs = '?' + getQueryString(params || {});
    const headers = {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Expires': '0'
    }

    return axios({
        method: 'get',
        headers: headers,
        url: path + qs
    })
};

const post = (path, params, headers = null) => {
    headers = headers || {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Expires': '0'
    };
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    return axios({
        method: 'post',
        url: path,
        headers: headers,
        data: params
    })
};

const put = (path, params, headers = null) => {
    headers = headers || {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Expires': '0'
    };
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    return axios({
        method: 'put',
        url: path,
        headers: headers,
        data: params
    })
};

const patch = (path, params, headers = null) => {
    headers = headers || {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Expires': '0'
    };
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    return axios({
        method: 'patch',
        url: path,
        headers: headers,
        data: params
    })
};

export default {
    get: get,
    post: post,
    put: put,
    patch: patch
}
