(function (root) {
    const issueView = document.getElementById("issueView");
    const URL = "/modules/issue.asp";

    var param = {};
    param.page = api.const.page;
    if (location.href.getValueByKey("rfp") != "")
        param.rfp = location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp;
    if (location.href.getValueByKey("orderBy") != "")
        param.orderBy = location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : "";
    if (location.href.getValueByKey("project") != "")
        param.project = location.href.getValueByKey("project") ? location.href.getValueByKey("project") : "";

    var listURL = "/issue/list.asp?" + api.convert.objectToParameter(param);

    param.idx = location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : null
    var editURL = "/issue/?" + api.convert.objectToParameter(param);

    if (param.idx === null || isNaN(param.idx)) {
        alert("존재하지 않는 프로젝트입니다.");
        location.href = listURL;
    } else {
        param = {
            role: "getIssueDetail",
            idx: param.idx
        };
    }
    api.ajax({
        type: "GET", url: URL, data: param, contentType: "application/json;",
        success: function (data) {
            var responseData = JSON.parse(data);
            responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
            if (responseData.state) {
                var innerHTML = issueView.innerHTML.replace(RegExp("template", "gi"), "");

                issueView.innerHTML = null;
                issueView.innerHTML += convertTemplate.from(innerHTML, responseData);

                var selected = issueView.querySelector("#issue_users ul.selected");
                if (responseData.users != null) {
                    for (var i in responseData.users) {
                        var users = responseData.users[i];
                        var user = document.createElement("li");
                        var userName = document.createElement("span");
                        user.setAttribute("data-id", users.id);
                        userName.setAttribute("class", "name");
                        userName.innerText = users.name;
                        user.appendChild(userName);
                        selected.appendChild(user);
                    }
                }
                if (responseData.files != null) {
                    if(responseData.files.length < 1)
                        api.remove.el(issueView.querySelector(".file"));

                    var fileList = issueView.querySelector("#files ul");
                    for (var i in responseData.files) {
                        var files = responseData.files[i];
                        var file = document.createElement("li");
                        var fileDown = document.createElement("a");
                        var fileName = document.createElement("a");
                        var param = {
                            role: "download",
                            idx: files.idx,
                            parentTable: files.parentTable,
                            parent: files.parent
                        };
                        file.setAttribute("data-idx", files.idx);
                        file.setAttribute("data-ptable", files.parentTable);
                        file.setAttribute("data-parent", files.parent);
                        fileDown.setAttribute("class", "down");
                        fileDown.href = "/modules/file.asp?" + api.convert.objectToParameter(param);
                        fileName.setAttribute("class", "name");
                        fileName.href = "/modules/file.asp?" + api.convert.objectToParameter(param);
                        fileName.innerText = files.name;
                        file.appendChild(fileDown);
                        file.appendChild(fileName);
                        fileList.appendChild(file);
                    }
                }else{
                    api.remove.el(issueView.querySelector(".file"));
                }

                getReplyList(1);

                api.set.event(document.querySelector("#replyList .insertReply .input input[type=button]"), "click", function (e) {
                    var replyList = document.querySelector("#replyList ul");
                    insertReply();
                });

                api.set.event(document.querySelector("#replyList .moreReply"), "click", function (e) {
                    var replyList = document.querySelector("#replyList ul");
                    getReplyList(parseInt(replyList.getAttribute("page")) + 1);
                });

                api.set.event(document.getElementById("doDelete"), "click", function () {
                    var param = {
                        role: "removeIssue",
                        idx: location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : ""
                    };
                    if (param.idx && confirm("정말 삭제하시겠습니까?")) {
                        api.ajax({
                            type: "GET", url: URL, data: param, contentType: "application/json;",
                            success: function (data) {
                                var responseData = JSON.parse(data);
                                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                                if (responseData.state) {
                                    alert(responseData.message);
                                    location.href = listURL;
                                }
                                else {
                                    alert(responseData.message);
                                }
                            }
                        });
                    }
                });
                api.set.event(document.getElementById("doEdit"), "click", function () {
                    location.href = editURL;
                });
                api.set.event(document.getElementById("goList"), "click", function () {
                    location.href = listURL;
                })

            }
            else {
                console.log(responseData);
                alert(responseData.message);
            }
        }
    });

    function getReplyList(page) {
        var URL = "/modules/reply.asp";
        var param = {
            role: "getReplyList",
            parentTable: "Issue",
            parent: location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : "",
            page: page
        };
        api.ajax({
            type: "GET", url: URL, data: param, contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                if (responseData.state) {
                    api.get.html("/templates/reply_default.html", function (html) {
                        var replyList = document.querySelector("#replyList ul");
                        var temp = document.createElement("ul");

                        if (responseData.maxCount <= api.const.rfp * page)
                            api.remove.el(document.querySelector("#replyList .moreReply"));

                        for (var i in responseData.list) {
                            temp.innerHTML = convertTemplate.from(html, responseData.list[i]);
                            replyList.appendChild(temp.querySelector("li"));
                        }
                        replyList.setAttribute("page", page);

                        api.set.flexHeight(issueView);
                    });
                }
                else {
                    api.remove.el(document.querySelector("#replyList .moreReply"));
                }
            }
        });
    }

    function insertReply() {
        var URL = "/modules/reply.asp";
        var param = {
            role: "insertReply",
            parentTable: "Issue",
            parent: location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : "",
            contents: document.querySelector("#replyList .insertReply input[name=contents]").value
        };
        if (param.contents != "") {
            api.ajax({
                type: "POST", url: URL, data: param, contentType: "application/json;",
                success: function (data) {
                    var responseData = JSON.parse(data);
                    responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                    if (responseData.state) {
                        location.reload();
                        /*
                         api.get.html("/templates/reply_default.html", function(html){
                         var replyList = document.querySelector("#replyList ul");
                         var temp = document.createElement("ul");

                         temp.innerHTML = convertTemplate.from(html, responseData);
                         replyList.appendChild(temp.querySelector("li"));
                         });
                         */
                    }
                    else {
                        alert(responseData.message);
                    }
                }
            });
        } else {
            alert("내용을 입력해주세요.");
        }
    }
})(this);