


const EprocRequest = (type, url, queryString, params, done, tryCache) => {
    if (EprocCache.enabled && tryCache) {
        const respCached = EprocCache.getItem(url);
        if (respCached) {
            done(null, respCached);
            return;
        }
    }

    const xhr = new XMLHttpRequest();
    let urlToCall = url.toString().indexOf("http") == -1 ? (WebApiServer + url) : (url);
    xhr.open(type, urlToCall + (queryString ? queryString : ""));
    xhr.setRequestHeader(
        'Authorization', 'Bearer ' + getAuthCookie()
    );
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onload = function () {
        if (EprocCache.enabled && tryCache) {
            EprocCache.setItem(url, xhr.response);    
        }
        done(null, xhr.response);
    };
    xhr.onerror = function () {
        done(xhr.response);
    };
    if (params != null) {
        xhr.send(JSON.stringify(params));
    } else {
        xhr.send();
    }
}

const getAuthCookie = () => {
    return getCookieV2(authCookie);
}

const getCookieV2 = (cname) => {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for (const element of ca) {
        let c = element;
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}




class EprocCache {

    static enabled = true;

    static getItem = (key) => {
        if (!this.enabled) {
            return null;
        }

        let ante_key = `${idpfuUtenteCollegato}`;
        return sessionStorage.getItem(`${ante_key}_${key}`);
    }
    static setItem = (key, value) => {
        let ante_key = `${idpfuUtenteCollegato}`;
        try {
            sessionStorage.setItem(`${ante_key}_${key}`, value);
        } catch(e) {
            this.clear();
        }
    }
    static clear = () => {
        sessionStorage.clear();
    }
}


