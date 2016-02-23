(function (root) {
    root.api = {
        _parent: root,
        _loginUser: {},
        _TextboxioConfig: {},
        set parent(o) {
            this.const.page = location.href.getValueByKey("page") ? location.href.getValueByKey("page") : 1;

            this.el.header = document.getElementsByTagName("header")[0];
            this.el.aside = document.getElementsByTagName("aside")[0];
            this.el.article = document.getElementsByTagName("article")[0];
            this.el.footer = document.getElementsByTagName("footer")[0];
            this._parent = o;
        },
        get parent() {
            return this._parent;
        },
        set user(u) {
            this._loginUser = u;
        },
        get user() {
            var base = {
                isLogin: "false",
                userClass: null,
                userId: null,
                userIp: null,
                userName: "Guest",
                userPart: null
            };
            return api.extend(base, this._loginUser);
        },
        set io(option) {
            var base = {
                images: {
                    upload: {
                        url: "/modules/textboxio.asp",
                        basePath: "/resources/upload/textboxio/",
                        allowLocal: true,
                        credentials: false
                    }
                },
                ui: {
                    fonts: ['맑은고딕', '돋움', '돋움체', '바탕', '바탕체', '궁서', '궁서체', 'Comic Sans MS', 'sans-serif', 'Helvetica', 'Arial'],
                    toolbar: {
                        items: ["insert", "format", "emphasis", "align", "listindent",
                            {
                                label: "tools",
                                items: ['find', 'fullscreen']
                            }
                        ]
                    }
                }
            };
            option = api.extend(base, option);
            this._TextboxioConfig = option;
        },
        get io() {
            return this._TextboxioConfig;
        },
        const: {
            rowForPage: 8,
            get rfp(){
                return this.rowForPage;
            },
            set rfp(rowForPage){
                this.rowForPage = rowForPage;
            },
            pageForBlock: 5,
            page: 1,
            location : "씨엔티테크"
        },
        el: {
            header: String.EMPTY,
            aside: String.EMPTY,
            article: String.EMPTY,
            footer: String.EMPTY
        },
        loadPage: function (element, directory, page) {
            api.get.html("/templates/" + directory + "/" + page + ".html", function (article) {
                api.el.article.innerHTML = article;
                api.get.script("/resources/scripts/actions/" + directory + "/" + page + ".js");
                api.get.style("/resources/styles/interfaces/" + directory + "/" + page + ".css");
            });
        },
        console: {
            log: function (message, caller) {
                /**
                 * api.console.log(string)
                 * console.log에 현재시간을 기록하여 출력
                 *
                 * @param string message 출력할 메세지
                 *
                 * @return string message 완성된 메세지
                 */
                var caller = caller ? caller : "";
                var time = new Date();

                message = "[" + caller + time.getHours() + ":"
                    + time.getMinutes() + ":" + time.getSeconds() + "] "
                    + message;
                console.log(message);

                return message;
            },
            error: function (message, caller) {
                /**
                 * api.console.error(string)
                 * console.log에 현재시간을 기록하여 출력
                 *
                 * @param string message 출력할 메세지
                 *
                 * @return string message 완성된 메세지
                 */
                var time = new Date();
                if (caller != null) {
                    caller += " ";
                } else {
                    var caller = "";
                }

                message = "[" + caller + time.getHours() + ":"
                    + time.getMinutes() + ":" + time.getSeconds() + "] "
                    + message;
                console.error(message);

                return message;
            }
        },
        upload: function (option) {
            var base = {
                parentTable: null,
                parent: null,
                file: null,
                path: null,
                success: function () {
                }
            };
            option = api.extend(base, option);

            var div = document.createElement("div")
                , childFrame = document.createElement("iframe")
                , form = document.createElement("form")
                , file = document.createElement("input");

            div.id = "tempForm";
            div.setAttribute("class", "hidden");
            childFrame.name = "child";

            file.name = "FILE";
            file.type = "file";
            file.files = option.file.files;

            var role = document.createElement("input");
            role.name = "ROLE";
            role.type = "hidden";
            role.value = "upload";
            form.appendChild(role);

            if (option.parentTable) {
                var parentTable = document.createElement("input");
                parentTable.name = "parentTable";
                parentTable.type = "hidden";
                parentTable.value = option.parentTable;
                form.appendChild(parentTable);
            }
            if (option.parent) {
                var parent = document.createElement("input");
                parent.name = "parent";
                parent.type = "hidden";
                parent.value = option.parent;
                form.appendChild(parent);
            }
            if (option.path) {
                var path = document.createElement("input");
                path.name = "path";
                path.type = "hidden";
                path.value = option.path.replace(new RegExp("/", "gi"), "\\");
                form.appendChild(path);
            }

            form.method = "POST";
            form.action = "/modules/file.asp";
            form.enctype = "multipart/form-data";
            form.acceptCharset = "euc-kr";
            form.target = "child";
            form.appendChild(file);

            div.appendChild(form);
            div.appendChild(childFrame);

            api.el.article.appendChild(div);
            div = document.getElementById("tempForm");
            form = div.querySelector("form");
            childFrame = div.querySelector("iframe");
            api.set.event(childFrame, "load", function (e) {
                var contents = e.target.contentDocument || e.target.contentWindow.document;
                option.success(contents.body.innerText);

                api.remove.el(document.getElementById("tempForm"));
            });
            form.submit();

            delete div;
            return true;
        },
        ajax: function (option) {
            /* jQuery 를 쓰지 않아 임시로 구현해놓은 ajax 입니다. */
            var xmlHttp;
            if (window.XMLHttpRequest)
                xmlHttp = new XMLHttpRequest();
            else
                xmlHttp = new ActiveXObject("Microsoft.xmlHttp");

            if (!option.url) {
                console.error("Can't find option.url");
                return;
            }

            var base = {
                url: null,
                type: "GET",
                data: null,
                method: true,
                debugLog: false,
                success: null,
                fail: function (readyState, status, statusText) {
                    if (base.debugLog)
                        console.error("Fail> state:"
                            + readyState + " status:" + status + " message"
                            + statusText);
                }
            };
            option = api.extend(base, option);
            option.type = (option.type).toUpperCase();

            xmlHttp.onreadystatechange = function () {
                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                    if (option.success)
                        option
                            .success(xmlHttp.responseText,
                                xmlHttp.readyState);
                } else {
                    if (option.fail)
                        option.fail(xmlHttp.readyState, xmlHttp.status,
                            xmlHttp.statusText);
                }
            };

            var parameter = [];
            var sendData = option.data;
            if (typeof sendData === "string") {
                var tempArray = String.prototype.split.call(sendData, '&');
                for (var i = 0, j = tempArray.length; i < j; i++) {
                    var datum = tempArray[i].split('=');
                    parameter.push(encodeURIComponent(datum[0]) + "="
                        + encodeURIComponent(datum[1]));
                }
            } else if (typeof sendData === 'object'
                && !(sendData instanceof String || (FormData && sendData instanceof FormData))) {
                for (var k in sendData) {
                    var datum = sendData[k];
                    if (Object.prototype.toString.call(datum) == "[object Array]") {
                        for (var i = 0, j = datum.length; i < j; i++) {
                            parameter.push(encodeURIComponent(k) + "[]="
                                + encodeURIComponent(datum[i]));
                        }
                    } else {
                        parameter.push(encodeURIComponent(k) + "="
                            + encodeURIComponent(datum));
                    }
                }
            }

            parameter = parameter.join("&");

            if (option.type == "GET") {
                xmlHttp.open("GET", option.url + (parameter.length > 0 ? "?" : "") + parameter, option.method);
                xmlHttp.send();

                if (option.debugLog)
                    console.log("[" + api.call() + "] GET :" + option.url + "?"
                        + parameter);
            }
            if (option.type == "POST") {
                xmlHttp.open("POST", option.url, option.method);
                xmlHttp.setRequestHeader("Content-type",
                    "application/x-www-form-urlencoded");
                xmlHttp.send(parameter);

                if (option.debugLog)
                    console.log("[" + api.call() + "] POST :" + option.url
                        + " || data:" + parameter);
            }

        },
        extend: function (defaults, options) {
            /**
             * api.extend(object, object)
             * extend 메소드구현. options에 있고 defaults에도 있는 데이터는 options로 대체,
             * options에 없고 defaults에는 있는 데이터는 defaults로 놔둔다.
             * options에 있고 defaults에는 없는 데이터는 options로 넣어준다.
             * jQuery의 $.extend 구현.
             *
             *
             * @param object defaults 비교주체가 될 object
             * @param object options 비교대상가 될 object
             *
             * @return object defaults options에 있고 defaults에도 있는 데이터는 options로 대체,
             * options에 없고 defaults에는 있는 데이터는 defaults로 놔둔다.
             * options에 있고 defaults에는 없는 데이터는 options로 넣어준다.
             */

            for (var key in options) {
                if (options[key] && options[key].constructor
                    && options[key].constructor === Object) {
                    defaults[key] = defaults[key] || {};
                    arguments.callee(defaults[key], options[key]);
                } else {
                    defaults[key] = options[key];
                }
            }
            return defaults;
        },
        copy: function (obj) {
            /**
             * api.copy(object)
             * object deep copy 기능
             *
             * @param object obj copy 하려는 객체
             *
             * @return object
             */
            return JSON.parse(JSON.stringify(obj));
        },
        printPaging: function (pageSection, currentPage, maxCount) {
            var page = api.paging(currentPage, maxCount);
            var currentURL = window.location.href.split('?')[0];
            var URL = currentURL + "?";
            var param = {
                page: api.const.page,
                sType: location.href.getValueByKey("sType") != null ? location.href.getValueByKey("sType") : null,
                sString: location.href.getValueByKey("sString") != null ? location.href.getValueByKey("sString") : null,
                project: location.href.getValueByKey("project") != null ? location.href.getValueByKey("project") : null,
                orderBy: location.href.getValueByKey("orderBy") != null ? location.href.getValueByKey("orderBy") : null
            };
            var ul = document.createElement("ul");
            var func = [];

            if (page.length > 1) {
                for (var idx in page) {
                    var li = document.createElement("li");
                    var a = document.createElement("a");

                    param.page = page[idx].value;
                    a.innerText = page[idx].text == "" ? page[idx].value : page[idx].text;
                    a.setAttribute("href", "?" + api.convert.objectToParameter(param));

                    if (page[idx].prev || page[idx].next) {
                        if (page[idx].prev)
                            li.setAttribute("class", "prev");
                        else if (page[idx].next)
                            li.setAttribute("class", "next");
                    }
                    if (page[idx].current)
                        li.setAttribute("class", "active");
                    li.appendChild(a);
                    ul.appendChild(li);
                }
                if (func[0])
                    pageSection.appendChild(func[0]);
                if (ul)
                    pageSection.appendChild(ul);
                if (func[1])
                    pageSection.appendChild(func[1]);
            }
        },
        paging: function (currentPage, rowCount) {
            /**
             * api.paging(number, number)
             * 현재 페이지와 전체 row 수를 받아 페이징된 리스트를 반환
             *
             * @param number currentPage 현재 페이지
             * @param number rowCount 전체 row 개수
             *
             * @return object pageList 완성된 페이지 리스트
             * @example
             */

            var maxPage = Math.ceil(rowCount / api.const.rfp);
            var prev = 0, next = 0;
            var pageList = [];
            var page = {
                current: false, // 현재페이지 여부
                prev: false, // 이전페이지 여부
                next: false, // 다음페이지 여부
                text: "", // 출력할 텍스트
                value: 0
                // 페이지 번호
                // 이동할 페이지
            };
            var temp = {};

            currentPage = parseInt(currentPage);
            maxPage = parseInt(maxPage);

            /* 현재 페이지가 최대 페이지보다 클 경우 현재 페이지에 최대 페이지수 대체 */
            if (currentPage > maxPage)
                currentPage = maxPage;

            /* 현재 페이지 리스트에 추가 */
            {
                temp = api.copy(page);
                temp.current = true;
                temp.value = currentPage;
                pageList.push(temp);
            }

            var scope = currentPage % api.const.pageForBlock;
            if (scope == 0) {
                prev = api.const.pageForBlock - 1;
                next = 0;
            } else {
                prev = scope - 1;
                next = api.const.pageForBlock - scope;
            }

            /* 이전 페이지 및 이전버튼 리스트에 추가 */
            if (currentPage != 1) {
                for (var idx = 1; idx <= prev; idx++) {
                    temp = api.copy(page);
                    temp.value = currentPage - idx;
                    pageList.unshift(temp);
                }

                if (currentPage > api.const.pageForBlock) {
                    temp = api.copy(page);
                    temp.text = "이전페이지";
                    temp.prev = true;
                    temp.value = currentPage - prev - 1;
                    pageList.unshift(temp);
                }
            }

            /* 다음 페이지 및 다음버튼 리스트에 추가 */
            if (currentPage <= maxPage) {
                if (currentPage % 5 != 0) {
                    for (var idx = 1; idx <= next; idx++) {
                        if (maxPage >= currentPage + idx) {
                            temp = api.copy(page);
                            temp.value = currentPage + idx;
                            pageList.push(temp);
                        }
                    }
                }

                if (maxPage >= currentPage + next) {
                    temp = api.copy(page);
                    temp.text = "다음페이지";
                    temp.next = true;
                    temp.value = currentPage + next + 1;
                    pageList.push(temp);
                }
            }
            return pageList;
        },
        has: {
            class: function (element, name) {
                /**
                 * api.has.class(object, string)
                 * element에 클래스 존재 확인
                 * jQuery의 $.hasClass 구현.
                 *
                 *
                 * @param object element 확인 당할 element
                 * @param string name 확인 될 클래스
                 *
                 * @return object element
                 */
                if (element.getAttribute("class")) {
                    if (element.getAttribute("class").indexOf(name) >= 0) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        },
        add: {
            class: function (element, name) {
                /**
                 * api.add.class(object, string)
                 * element에 클래스 추가
                 * jQuery의 $.addClass 구현.
                 *
                 *
                 * @param object element 추가 당할 element
                 * @param string name 추가 될 클래스
                 *
                 * @return object element
                 */
                var classArray = [];
                if (!api.has.class(element, name)) {
                    classArray = classArray.concat(element.className.split(" "));
                    classArray.push(name);
                    element.className = classArray.join(" ");
                }
                return element;
            }
        },
        remove: {
            class: function (element, name) {
                /**
                 * api.remove.class(object, string)
                 * element에 클래스 삭제
                 * jQuery의 $.removeClass 구현.
                 *
                 *
                 * @param object element 삭제 당할 element
                 * @param string name 삭제 될 클래스
                 *
                 * @return object element
                 */
                var classArray = [];
                if (api.has.class(element, name)) {
                    classArray = classArray.concat(element.className.split(" "));
                    element.className = classArray.join(" ").replace(RegExp(name, "gi"), "");
                }
                return element;
            },
            el: function (element) {
                /**
                 * api.remove.el(object)
                 * element 삭제
                 * jQuery의 $.remove 구현.
                 *
                 *
                 * @param object element 삭제 당할 element
                 *
                 * @return
                 */
                if (element) {
                    if (element.parentNode)
                        element.parentNode.removeChild(element);
                    return true;
                }
                return false;
            }
        },
        get: {
            chart: function (target, data, option) {
                if (Chart) {
                    var base = {
                        responsive: true,
                        maintainAspectRatio: true
                    };
                    option = api.extend(base, option);
                    var canvas = document.createElement("canvas");
                    canvas.className = "chart";
                    target.appendChild(canvas);
                    canvas = target.querySelector(".chart");
                    canvas.className = "";
                    canvas = canvas.getContext("2d");
                    new Chart(canvas).Pie(data, option);
                } else {
                    api.console.error("Chart 라이브러리가 존재하지 않습니다.");
                    return false;
                }
            },
            script: function (url, callback) {
                /**
                 * api.get.script(string, function)
                 * 외부또는 내부 ECMAScript 파일을 불러온다.
                 *
                 * @param string url 불러올 script의 src값
                 * @param string callback script 로드 후 행할 callback 함수
                 *
                 * @return 없음(true)
                 */
                var script = document.createElement('script');
                script.type = "text/javascript";
                script.src = url;
                if (callback)
                    script.onload = callback;
                document.getElementsByTagName('head')[0].appendChild(script);
                return true;
            },
            style: function (url, callback) {
                /**
                 * api.get.style(string, function)
                 * 외부또는 내부 style 파일을 불러온다.
                 *
                 * @param string url 불러올 css의 src값
                 * @param string callback css 로드 후 행할 callback 함수
                 *
                 * @return 없음(true)
                 */

                var style = document.createElement('link');
                style.rel = "stylesheet";
                style.media = "all";
                style.href = url;

                if (callback)
                    style.onload = callback;
                document.getElementsByTagName('head')[0].appendChild(style);
                return true;
            },
            html: function (src, loadAfter) {
                /**
                 * api.get.html(string)
                 * html 로드
                 *
                 * @param string src 로딩할 html의 주소
                 *
                 * @return string 로딩된 html contents
                 */
                var xmlHttp = new XMLHttpRequest();
                xmlHttp.onreadystatechange = function () {
                    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                        if (typeof loadAfter === "function" && loadAfter != null) {
                            loadAfter(xmlHttp.responseText);
                        }
                        return xmlHttp.responseText;
                    }
                };
                xmlHttp.open("GET", src, true);
                xmlHttp.send();
            },
            cookie: function (cookieName) {
                /**
                 * api.get.cookie(string)
                 * cookie 로드
                 *
                 * @param string cookieName 로딩할 쿠키의 이름
                 *
                 * @return string cookieValue 로딩된 쿠키의 값
                 */

                cookieName = cookieName + '=';
                var cookieData = document.cookie;
                var start = cookieData.indexOf(cookieName);
                var cookieValue = '';
                if (start != -1) {
                    start += cookieName.length;
                    var end = cookieData.indexOf(';', start);
                    if (end == -1)
                        end = cookieData.length;
                    cookieValue = cookieData.substring(start, end);
                }
                if (unescape(cookieValue) != null)
                    return unescape(cookieValue);
                else
                    return false;
            },
            cssPath: function (el) {
                /**
                 * api.get.cssPath(object)
                 * element의 셀렉터를 string으로 반환해주는 메소드
                 *
                 * @param object el 셀렉터를 알아내려는 DOM 의 object
                 *
                 * @return string selector 셀렉터를 css의 selector와 같이 반환
                 */

                if (!(el instanceof Element))
                    return;
                var path = [];
                while (el.nodeType === Node.ELEMENT_NODE) {
                    var selector = el.nodeName.toLowerCase();
                    if (el.id) {
                        selector += '#' + el.getAttribute("id");
                    } else {
                        var sib = el, nth = 1;
                        while (sib.nodeType === Node.ELEMENT_NODE
                        && (sib = sib.previousSibling) && nth++)
                            ;
                        selector += ":nth-child(" + nth + ")";
                    }
                    path.unshift(selector);
                    el = el.parentNode;
                }
                return path.join(" ");
            }
        },
        set: {
            flexHeight: function (object) {
                var diff = object.offsetHeight - api.el.article.offsetHeight;
                if (diff > 0) {
                    document.body.style.height = document.body.offsetHeight + diff + 100 + "px";
                }
            },
            center: function (object) {
                var objectWidth = object.offsetWidth != 0 ? object.offsetWidth : parseInt(object.style.width);
                var objectHeight = object.offsetHeight != 0 ? object.offsetHeight : parseInt(object.style.height);
                var vpWidth = window.innerWidth;
                var vpHeight = window.innerHeight;

                object.style.left = (vpWidth - objectWidth) / 2 + 'px';
                object.style.top = (vpHeight - objectHeight) / 2 + 'px';
            },
            location: function (page, url) {
                if (typeof (history.pushState) != "undefined") {
                    var obj = {Page: page, Url: url};
                    history.pushState(obj, obj.Page, obj.Url);
                } else {
                    window.location.href = "homePage";
                    api.console.error("Browser does not support HTML5.");
                }
            },
            event: function (selector, event, callback) {
                /**
                 * api.set.event(string, string, function)
                 * 해당하는 셀렉터에 event binding을 행하는 메소드
                 *
                 * @param string selector event를 넣어줄 DOM 셀렉터
                 * @param string event 넣으려는 event 속성
                 * @param function callback 넣으려는 event 동작
                 *
                 * @return 없음(true)
                 */
                var object = null;
                if (selector != null) {
                    if (typeof selector === "object")
                        object = selector;
                    else if (typeof selector === "string") {
                        object = document.querySelectorAll(selector);
                        if (object.length < 2)
                            object = object[0];
                    }
                    else
                        api.console.error("셀렉터 타입이 잘못되었습니다.");

                    if (object) {
                        if (object.length != undefined && object.childNodes == null) {
                            for (var idx = 0; idx < object.length; idx++)
                                api.set.event(api.get.cssPath(selector[idx]));
                        } else if (typeof selector === "string") {
                            if (object.length > 1) {
                                for (var idx = 0; idx < object.length; idx++) {
                                    object[idx].addEventListener(event,
                                        function (event, selector) {
                                            callback(event);
                                        });
                                }
                            } else {
                                object.addEventListener(event, function (event, selector) {
                                    callback(event);
                                });
                            }
                        } else if (typeof selector === "object") {
                            object.addEventListener(event, function (event, selector) {
                                callback(event);
                            });
                        }
                    } else {
                        api.console.error("DOM '" + selector + "'를 찾을 수 없습니다.");
                    }
                } else {
                    api.console.error("셀렉터를 입력해주세요.");
                }
                return true;
            },
            cookie: function (cookieName, cookieValue, expiredDay) {
                /**
                 * api.set.cookie(string, string, number)
                 * cookie 등록
                 *
                 * @param string cookieName 등록할 쿠키의 이름
                 * @param string cookieValue 등록할 쿠키값
                 * @param number expiredDay 등록할 쿠키의 유효기간
                 *
                 * @return 없음(true)
                 */

                var expire = new Date();
                expire.setDate(expire.getDate() + expiredDay);
                var cookies = cookieName + '=' + escape(cookieValue)
                    + '; path=/ ';
                if (expiredDay != null)
                    cookies += ';expires=' + expire.toGMTString() + ';';
                document.cookie = cookies;
                return true;
            },
            option: function (element, value) {
                for (var i in element.childNodes) {
                    if (element.childNodes[i].value == value) {
                        element.childNodes[i].setAttribute("selected", "");
                    }
                }
            },
            dateSelect: function (selector, currentDate) {
                var element = document.getElementById(selector);
                var i, j, option = null;
                element = {
                    year: element.querySelector(".year"),
                    month: element.querySelector(".month"),
                    day: element.querySelector(".day")
                };

                if (currentDate == null) {
                    currentDate = new Date();
                    element = setDate(element, currentDate);
                } else {
                    currentDate = new Date(currentDate);
                    element = setDate(element, currentDate);
                }
                function setDate(ele, pivot) {
                    ele.year = setYear(ele, pivot);
                    ele.month = setMonth(ele, pivot);
                    ele.day = setDay(ele, pivot);
                    return ele;
                }

                function setYear(ele, pivot) {
                    ele.year.innerHTML = "";
                    for (i = pivot.getFullYear(); i < pivot.getFullYear() + 100; i++) {
                        option = document.createElement("option");
                        option.value = i;
                        option.innerText = i;
                        if (i == pivot.getFullYear())
                            option.setAttribute("selected", "");

                        ele.year.appendChild(option);
                    }

                    ele.year.onchange = function (e) {
                        element = {
                            year: e.target.parentNode.childNodes[1],
                            month: e.target.parentNode.childNodes[3],
                            day: e.target.parentNode.childNodes[5]
                        };
                        var selectedDate = new Date();
                        selectedDate.setFullYear(element.year.value);
                        selectedDate.setMonth(element.month.value - 1);
                        selectedDate.setDate(element.day.value - 1);

                        setMonth(element, selectedDate);
                        setDay(element, selectedDate);
                    };
                    return ele.year;
                }

                function setMonth(ele, pivot) {
                    ele.month.innerHTML = "";
                    for (i = 1; i < 13; i++) {
                        option = document.createElement("option");
                        option.value = i;
                        option.innerText = i;
                        if (i == pivot.getMonth() + 1)
                            option.setAttribute("selected", "");

                        ele.month.appendChild(option);
                        ele.month.onchange = function (e) {
                            element = {
                                year: e.target.parentNode.childNodes[1],
                                month: e.target.parentNode.childNodes[3],
                                day: e.target.parentNode.childNodes[5]
                            };
                            var selectedDate = new Date();
                            selectedDate.setFullYear(element.year.value);
                            selectedDate.setMonth(element.month.value);
                            selectedDate.setDate(2);

                            element.day.innerHTML = "";
                            var lastDayOfMonth = new Date((new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)) - 1);
                            console.log(lastDayOfMonth);
                            for (i = 1; i <= lastDayOfMonth.getDate(); i++) {
                                option = document.createElement("option");
                                option.value = i;
                                option.innerText = i;
                                if (i == pivot.getDate())
                                    option.setAttribute("selected", "");
                                element.day.appendChild(option);
                            }
                        };
                    }
                    return ele.month;
                }

                function setDay(ele, pivot) {
                    ele.day.innerHTML = "";
                    var lastDayOfMonth = new Date((new Date(pivot.getFullYear(), pivot.getMonth() - 1, 1)) - 1);
                    for (i = 1; i <= lastDayOfMonth.getDate(); i++) {
                        option = document.createElement("option");
                        option.value = i;
                        option.innerText = i;
                        if (i == pivot.getDate())
                            option.setAttribute("selected", "");
                        ele.day.appendChild(option);
                    }
                    return ele.day;
                }
            }
        },
        convert: {
            stringToBoolean: function (string) {
                string = string.toUpperCase();
                if (string == "TRUE" || string == "1")
                    return true;
                else if (string == "FALSE" || string == "0")
                    return false;
                else
                    return false;
            },
            objectToParameter: function (object) {
                var param = "";
                for (var key in object) {
                    if (object[key]) {
                        if (param != "")
                            param += "&";
                        param += key + "=" + encodeURIComponent(object[key]);
                    }
                }
                return param;
            },
            toTwiceDigit: function (n) {
                return (n < 10 ? '0' : '') + n;
            }
        }
    };

    String.prototype.getValueByKey = function (k) {
        var p = new RegExp('\\b' + k + '\\b', 'gi');
        var ret = this.search(p) != -1 ? decodeURIComponent(this.substr(
            this.search(p) + k.length + 1).substr(0,
            this.substr(this.search(p) + k.length + 1).search(/(&|;|$)/)))
            : "";
        if (ret == null || ret == "null") {
            ret = "";
        }
        return ret;
    };
    Date.prototype.format = function (param) {
        var yyyy = this.getFullYear().toString();
        var yy = this.getFullYear().toString().substr(2, 2);
        var mm = api.convert.toTwiceDigit((this.getMonth() + 1).toString()); // getMonth() is zero-based
        var dd = api.convert.toTwiceDigit(this.getDate().toString());
        param = param.toUpperCase();
        param = param.indexOf("YYYY") >= 0 ? param.replace("YYYY", yyyy) : param;
        param = param.indexOf("YY") >= 0 ? param.replace("YY", yy) : param;
        param = param.indexOf("MM") >= 0 ? param.replace("MM", mm) : param;
        param = param.indexOf("DD") >= 0 ? param.replace("DD", dd) : param;

        return param;
    };
}(this));