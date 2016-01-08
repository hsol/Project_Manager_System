(function (root) {
    const URL = "/modules/issue.asp";
    const issueForm = document.getElementById("issueForm");

    var backURL = null;
    var param = {};
    param.page = api.const.page;
    if (location.href.getValueByKey("rfp") != "")
        param.rfp = location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp;
    if (location.href.getValueByKey("orderBy") != "")
        param.orderBy = location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : "";
    if (location.href.getValueByKey("project") != "")
        param.project = location.href.getValueByKey("project") ? location.href.getValueByKey("project") : "";

    if (location.href.getValueByKey("idx") != "") {
        param.idx = location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : 0;
        backURL = "/issue/view.asp?" + api.convert.objectToParameter(param);
    } else {
        backURL = "/issue/list.asp?" + api.convert.objectToParameter(param);
    }

    setStateList(function(){setPartList(function(){setIssueDetail();});});

    function getIssueInput() {
        var issueForm = document.getElementById("issueForm");
        var form = {
            project : location.href.getValueByKey("project") ? location.href.getValueByKey("project") : "",
            idx : location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : "",
            title: issueForm.querySelector("[name=title]").value,
            targetDate: new Date(issueForm.querySelector("[name=targetYear]").value, issueForm.querySelector("[name=targetMonth]").value-1, issueForm.querySelector("[name=targetDay]").value).format("YYYYMMDD"),
            state: issueForm.querySelector("[name=state]").value,
            part : issueForm.querySelector("[name=part]").value,
            isEnded: issueForm.querySelector("[name=isEnded]").checked ? "1" : "0",
            isEnabled: issueForm.querySelector("[name=isEnabled]").checked ? "1" : "0",
            contents: issueForm.querySelector("[name=contents]").value,
            userList: []
        };
        var userList = issueForm.querySelectorAll("#users .selected li");
        for (var i in userList) {
            if (userList[i].getAttribute)
                form.userList.push(userList[i].getAttribute("data-id"));
        }
        return form;
    }

    function setPartList(callback) {
        var URL = "/modules/part.asp";
        var param = {
            role: "getPart"
        };
        api.ajax({
            type: "GET",
            url: URL,
            data: param,
            contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                if (responseData.state) {
                    var select = document.querySelector("#issueForm .part");
                    var option = null, list = null, i;

                    select.innerHTML = "";
                    for (i in responseData.list) {
                        list = responseData.list[i];
                        option = document.createElement("option");
                        option.value = list.idx;
                        option.innerText = list.name;
                        select.appendChild(option);
                    }
                    callback();
                }
                else {
                    alert(responseData.message);
                }
            }
        });
    }

    function setStateList(callback) {
        var URL = "/modules/state.asp";
        var param = {
            role: "getState",
            class: "Issue"
        };
        api.ajax({
            type: "GET",
            url: URL,
            data: param,
            contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                if (responseData.state) {
                    var select = document.querySelector("#issueForm .state");
                    var option = null, list = null, i;

                    select.innerHTML = "";
                    for (i in responseData.list) {
                        list = responseData.list[i];
                        option = document.createElement("option");
                        option.value = list.idx;
                        option.setAttribute("percent", list.perfection);
                        option.innerText = list.name + "(" + list.perfection + "%)";
                        select.appendChild(option);
                    }
                    callback();
                }
                else {
                    alert(responseData.message);
                }
            }
        });
    }

    function setIssueDetail() {
        var param = {
            role: "getIssueDetail",
            idx: location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : "",
            project:location.href.getValueByKey("project") ? location.href.getValueByKey("project") : ""
        };
        api.ajax({
            type: "GET",
            url: URL,
            data: param,
            contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                if (responseData.state) {
                    var innerHTML = issueForm.innerHTML.replace(RegExp("template", "gi"), "");
                    var users = null;

                    issueForm.innerHTML = null;
                    if ( location.href.getValueByKey("idx")) {
                        responseData.pageTitle = responseData.title;
                        responseData.text_editButton = "수정";
                    }
                    else {
                        responseData.pageTitle = "";
                        responseData.text_editButton = "등록";

                        responseData.issueName = "";
                        responseData.perfection = 0;
                        responseData.description = "";
                    }

                    if (responseData.isEnabled)
                        responseData.isEnabled = responseData.isEnabled.toUpperCase() == "TRUE" ? "checked" : "";
                    else
                        responseData.isEnabled = "";

                    if (responseData.endDate)
                        responseData.isEnded = responseData.endDate != "1900-01-01" ? "checked" : "";
                    else
                        responseData.isEnded = "";

                    issueForm.innerHTML += convertTemplate.from(innerHTML, responseData);
                    if (responseData.users != null) {
                        var selected = issueForm.querySelector("#users ul.selected");
                        for (var i in responseData.users) {
                            var users = responseData.users[i];
                            var user = document.createElement("li");
                            var userDel = document.createElement("span");
                            var userName = document.createElement("span");
                            user.setAttribute("data-id", users.id);
                            userDel.setAttribute("class", "delete");
                            userDel.onclick = function (e) {
                                var userLabel = e.target.parentNode;
                                api.remove.el(userLabel);
                            };
                            userName.setAttribute("class", "name");
                            userName.innerText = users.name;
                            user.appendChild(userDel);
                            user.appendChild(userName);
                            selected.appendChild(user);
                        }
                    }
                    if (responseData.files != null) {
                        var fileList = issueForm.querySelector("#files ul");
                        for (var i in responseData.files) {
                            var files = responseData.files[i];
                            var file = document.createElement("li");
                            var fileDel = document.createElement("span");
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
                            fileDel.setAttribute("class", "delete");
                            fileDel.onclick = function (e) {
                                var fileLi = e.target.parentNode;
                                var URL = "/modules/file.asp";
                                var param = {
                                    role: "remove",
                                    idx: fileLi.getAttribute("data-idx"),
                                    parentTable: fileLi.getAttribute("data-ptable"),
                                    parent: fileLi.getAttribute("data-parent")
                                };
                                api.ajax({
                                    type: "GET", url: URL, data: param, contentType: "application/json;",
                                    success: function (data) {
                                        var responseData = JSON.parse(data);
                                        responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                                        if (responseData.state) {
                                            api.remove.el(fileLi);
                                        } else {
                                            alert(responseData.message);
                                        }
                                    }
                                });
                            };
                            fileName.setAttribute("class", "name");
                            fileName.href = "/modules/file.asp?" + api.convert.objectToParameter(param);
                            fileName.innerText = files.name;
                            file.appendChild(fileDel);
                            file.appendChild(fileName);
                            fileList.appendChild(file);
                        }
                    }


                    api.set.dateSelect("dateSelect", responseData.targetDate);
                    api.set.event(document.getElementById("goBack"), "click", function () {
                        location.href = backURL;
                    });
                    api.set.event(document.getElementById("goEdit"), "click", function (e) {
                        var isNew = e.target.value == "등록";
                        var master = getIssueInput();
                        var param = {};
                        if (isNew) {
                            param = {
                                role : "insertIssue",
                                project : master.project,
                                part : master.part,
                                title : master.title,
                                contents : master.contents,
                                state : master.state,
                                targetDate : master.targetDate,
                                isEnabled : master.isEnabled,
                                userList : JSON.stringify({list:master.userList})
                            };
                        }else{
                            param = {
                                role : "updateIssue",
                                idx : master.idx,
                                part : master.part,
                                title : master.title,
                                contents : master.contents,
                                state : master.state,
                                targetDate : master.targetDate,
                                isEnded : master.isEnded,
                                isEnabled : master.isEnabled,
                                userList : JSON.stringify({list:master.userList})
                            };
                        }

                        api.ajax({type: "GET", url: URL, data: param, contentType: "application/json;",
                            success: function (data) {
                                var responseData = JSON.parse(data);
                                if (api.convert.stringToBoolean(responseData.state)) {
                                    alert((isNew ? "등록" : "수정") + " 하였습니다.");
                                    location.href = backURL;
                                }else{
                                    alert(responseData.message);
                                }
                            }
                        });
                    });
                    api.set.event(document.querySelector("#issueForm .state"), "change", function (e) {
                        var graph = document.querySelector("#issueForm .perfection .percent");
                        var text = document.querySelector("#issueForm .perfection span");

                        graph.style.width = e.target.childNodes[e.target.selectedIndex].getAttribute("percent") + "%";
                        text.innerText = e.target.childNodes[e.target.selectedIndex].getAttribute("percent") + "%";
                    });
                    api.set.event(document.querySelector("#users .addUser"), "click", function () {
                        api.get.html("/templates/include/popup.html", function (pop) {
                            api.remove.el(document.querySelector(".popup_back"));
                            var popup_back = document.createElement("div");
                            api.add.class(popup_back, "popup_back");
                            var popup = document.querySelector(".popup") ? document.querySelector(".popup") : document.createElement("div");
                            popup.innerHTML = pop;

                            window.onresize = function () {
                                if (window.innerHeight < 700)
                                    popup.style.height = window.innerHeight - 100 + "px";
                                else
                                    popup.style.height = "600px";

                                if (window.innerWidth >= 800) {
                                    if (window.innerWidth > 1280)
                                        popup.style.width = "800px";
                                    else
                                        popup.style.width = window.innerWidth / 2 + "px";
                                }
                                else
                                    popup.style.width = "300px";
                                api.set.center(popup);
                            };
                            window.onresize();

                            api.add.class(popup, "popup");

                            api.get.html("/templates/user/select.html", function (select) {
                                api.get.script("/resources/scripts/actions/user/select.js");
                                api.get.style("/resources/styles/interfaces/user/select.css");
                                popup.id = "user_select";
                                popup.querySelector(".contents").innerHTML = select;

                                popup.onclose = function () {
                                    var selected = issueForm.querySelector("#users ul.selected");
                                    var global_userList = document.getElementById("global_userList");

                                    for (var i in global_userList.querySelectorAll("li")) {
                                        var globalLi = global_userList.querySelectorAll("li")[i];
                                        if (globalLi != null) {
                                            var isNotSame = true;
                                            for (var j in selected.querySelectorAll("li")) {
                                                var selectedLi = selected.querySelectorAll("li")[j];
                                                if (selectedLi.getAttribute != null && globalLi.getAttribute != null) {
                                                    if (selectedLi.getAttribute("data-id") == globalLi.getAttribute("data-id")) {
                                                        isNotSame = false;
                                                        break;
                                                    }
                                                }
                                            }
                                            if (isNotSame) {
                                                try {
                                                    var user = document.createElement("li");
                                                    var userDel = document.createElement("span");
                                                    var userName = document.createElement("span");
                                                    user.setAttribute("data-id", globalLi.getAttribute("data-id"));
                                                    userDel.setAttribute("class", "delete");
                                                    userDel.onclick = function (e) {
                                                        var userLabel = e.target.parentNode;
                                                        api.remove.el(userLabel);
                                                    };
                                                    userName.setAttribute("class", "name");
                                                    userName.innerText = globalLi.querySelector(".name").innerText;
                                                    user.appendChild(userDel);
                                                    user.appendChild(userName);
                                                    selected.appendChild(user);
                                                } catch (e) {
                                                }
                                            }
                                        }
                                    }
                                    document.querySelector(".popup .head .exit").onclick();

                                    api.remove.el(global_userList);
                                    api.set.flexHeight(issueForm);
                                };

                                document.body.appendChild(popup_back);
                                document.body.appendChild(popup);
                            });
                        });
                    });
                    api.const.file = {
                        parentTable: "Issue",
                        parent: responseData.idx,
                        file: issueForm.querySelector("#files input[type=file]"),
                        path: null
                    };
                    api.set.event(issueForm.querySelector("#files .uploadFile"),"click", function(){
                        api.upload({
                            parentTable: api.const.file.parentTable,
                            parent: api.const.file.parent,
                            file: api.const.file.file,
                            path: api.const.file.path,
                            success: function (data) {
                                var fileList = issueForm.querySelector("#files ul");
                                var responseData = JSON.parse(data);
                                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                                if (responseData.state) {
                                    var files = {
                                        idx: responseData.idx,
                                        name: responseData.name,
                                        parentTable: "Issue",
                                        parent: api.const.file.parent
                                    };
                                    var file = document.createElement("li");
                                    var fileDel = document.createElement("span");
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
                                    fileDel.setAttribute("class", "delete");
                                    fileDel.onclick = function (e) {
                                        var fileLi = e.target.parentNode;
                                        var URL = "/modules/file.asp";
                                        var param = {
                                            role: "remove",
                                            idx: fileLi.getAttribute("data-idx"),
                                            parentTable: fileLi.getAttribute("data-ptable"),
                                            parent: fileLi.getAttribute("data-parent")
                                        };
                                        api.ajax({
                                            type: "GET", url: URL, data: param, contentType: "application/json;",
                                            success: function (data) {
                                                var responseData = JSON.parse(data);
                                                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                                                if (responseData.state) {
                                                    api.remove.el(fileLi);
                                                } else {
                                                    alert(responseData.message);
                                                }
                                            }
                                        });
                                    };
                                    fileName.setAttribute("class", "name");
                                    fileName.href = "/modules/file.asp?" + api.convert.objectToParameter(param);
                                    fileName.innerText = files.name;
                                    file.appendChild(fileDel);
                                    file.appendChild(fileName);
                                    fileList.appendChild(file);

                                    issueForm.querySelector("#files input[type=file]").value = null;
                                }else{
                                    alert(responseData.message);
                                }
                            }
                        });
                    });

                    if (responseData.stateId)
                        api.set.option(issueForm.querySelector(".state"), responseData.stateId);
                    if (responseData.partId)
                        api.set.option(issueForm.querySelector(".part"), responseData.partId);

                    api.set.flexHeight(issueForm);
                }
                else {
                    alert(responseData.message);
                }
            }
        });
    }
})(this);