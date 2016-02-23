(function (root) {
    const URL = "/modules/account.asp";
    const accountDOM = document.getElementById("account");

    api.remove.class(document.getElementById("logo"), "hidden");

    api.ajax({
        type: "GET",
        url: URL,
        contentType: "application/json;",
        success: function (data) {
            var responseData = JSON.parse(data)
            if (responseData.isLogin != null) {
                api.user = responseData;
                if (api.convert.stringToBoolean(responseData.isLogin)) {
                    // UI 변경 스크립트
                    api.add.class(accountDOM.querySelector(".log .in"), "hidden");
                    api.add.class(accountDOM.querySelector(".form"), "hidden");
                    api.remove.class(accountDOM.querySelector(".mypage"), "hidden");
                    if(api.el.aside) {
                        api.remove.class(api.el.aside.querySelector("li.mypage"), "hidden");
                        api.remove.class(api.el.aside.querySelector("li.project_list"), "hidden");
                        api.remove.class(api.el.aside.querySelector("li.issue_list"), "hidden");
                    }
                    api.remove.class(accountDOM.querySelector(".log .out"), "hidden");
                    api.el.header.setAttribute("isLogin", "true");

                    // 이벤트 스크립트
                    api.set.event(accountDOM.querySelector(".mypage"), "click", function () {
                        location.href = "/mypage";
                    });
                    api.set.event(accountDOM.querySelector(".log .out"), "click", function () {
                        var param = {};
                        param.role = "logout";
                        api.ajax({
                            type: "GET",
                            url: URL,
                            data: param,
                            contentType: "application/json;",
                            success: function (data) {
                                responseData = JSON.parse(data);
                                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);

                                alert(responseData.message);
                                if (responseData.state)
                                    location.reload();
                            }
                        });
                    });
                }
                else {
                    // UI 변경 스크립트
                    api.remove.class(accountDOM.querySelector(".log .in"), "hidden");
                    api.remove.class(accountDOM.querySelector(".form"), "hidden");
                    api.add.class(accountDOM.querySelector(".mypage"), "hidden");
                    if(api.el.aside) {
                        api.add.class(api.el.aside.querySelector("li.project_list"), "hidden");
                        api.add.class(api.el.aside.querySelector("li.issue_list"), "hidden");
                        api.add.class(api.el.aside.querySelector("li.mypage"), "hidden");
                    }
                    api.add.class(accountDOM.querySelector(".log .out"), "hidden");
                    api.el.header.setAttribute("isLogin", "false");

                    var loginEvent = function () {
                        var param = {
                            role: "login",
                            id: accountDOM.querySelector("#login-id").value,
                            pw: accountDOM.querySelector("#login-pw").value
                        };
                        if(param.id == "")
                            alert("아이디를 입력해주세요.");
                        else if(param.pw == "")
                            alert("비밀번호를 입력해주세요.");
                        else {
                            api.ajax({
                                type: "GET",
                                url: URL,
                                data: param,
                                contentType: "application/json;",
                                success: function (data) {
                                    responseData = JSON.parse(data);
                                    responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);

                                    alert(responseData.message);
                                    if (responseData.state)
                                        refresh();
                                }
                            });
                        }
                    };

                    // 이벤트 스크립트
                    api.set.event(accountDOM.querySelector(".log .in"), "click", function () {
                        loginEvent();
                    });
                    api.set.event(accountDOM.querySelector("#login-id"), "keyup", function (e) {
                        if (e.keyCode == 13)
                            loginEvent();
                    });
                    api.set.event(accountDOM.querySelector("#login-pw"), "keyup", function (e) {
                        if (e.keyCode == 13)
                            loginEvent();
                    });
                }
                api.remove.class(accountDOM, "hidden");
            }

            api.set.event(document.getElementById("logo"), "click", function () {
                if (window.innerWidth <= 800) {
                    if (api.el.aside.style.left == "-200px") {
                        api.el.aside.style.left = "0px";
                    }
                    else {
                        api.el.aside.style.left = "-200px";
                    }
                }
            });
        }
    });
    var refresh = function () {
        api.get.html("/templates/header_default.html", function (header) {
            api.get.script("/resources/scripts/actions/header_default.js");
            api.get.style("/resources/styles/interfaces/header_default.css");
            api.el.header.innerHTML = header;
        });
    }
})(this);