(function (root) {
    const URL = "/modules/project.asp";
    const projectForm = document.getElementById("projectForm");

    var backURL = null;
    var param = {};
    param.page = api.const.page;
    if (location.href.getValueByKey("rfp") != "")
        param.rfp = location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp;
    if (location.href.getValueByKey("orderBy") != "")
        param.orderBy = location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : "";

    if (location.href.getValueByKey("idx") != "") {
        param.idx = location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : 0;
        backURL = "/project/view.asp?" + api.convert.objectToParameter(param);
    } else {
        backURL = "/project/list.asp?" + api.convert.objectToParameter(param);
    }

    setStateList(function(){
        setProjectDetail(function(){
            textboxio.replace(projectForm.querySelector("[name=description]"), api.io);
        });
    });

    function getProjectInput() {
        var projectForm = document.getElementById("projectForm");
        var editor = textboxio.getActiveEditor();
        projectForm.querySelector("[name=description]").value = editor.content.get();

        var form = {
            idx: location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : "",
            name: projectForm.querySelector("[name=name]").value,
            targetDate: new Date(projectForm.querySelector("[name=targetYear]").value, projectForm.querySelector("[name=targetMonth]").value - 1, projectForm.querySelector("[name=targetDay]").value).format("YYYYMMDD"),
            state: projectForm.querySelector("[name=state]").value,
            isEnded: projectForm.querySelector("[name=isEnded]").checked ? "1" : "0",
            isEnabled: projectForm.querySelector("[name=isEnabled]").checked ? '1' : '0',
            description: projectForm.querySelector("[name=description]").value,
            userList: []
        };
        var userList = projectForm.querySelectorAll("#users .selected li");
        for (var i in userList) {
            if (userList[i].getAttribute)
                form.userList.push(userList[i].getAttribute("data-id"));
        }
        return form;
    }

    function setStateList(callback) {
        var URL = "/modules/state.asp";
        var param = {
            role: "getState",
            class: "Project"
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
                    var select = projectForm.querySelector(".state");
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
                }
                else {
                    alert(responseData.message);
                }

                if(callback)
                    callback();
            }
        });
    }

    function setProjectDetail(callback) {
        var param = {
            role: "getProject",
            idx: location.href.getValueByKey("idx") ? location.href.getValueByKey("idx") : ""
        };
        api.ajax({
            type: "GET", url: URL, data: param, contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                if (responseData.state) {
                    var innerHTML = projectForm.innerHTML.replace(RegExp("template", "gi"), "");
                    var users = null;
                    var isExist = location.href.getValueByKey("idx") != "";

                    projectForm.innerHTML = null;
                    if (isExist) {
                        responseData.pageTitle = responseData.projectName;
                        responseData.text_editButton = "수정";
                    }
                    else {
                        responseData.pageTitle = "";
                        responseData.text_editButton = "등록";

                        responseData.projectName = "";
                        responseData.perfection = 0;
                        responseData.description = "";
                    }
                    if (responseData.isEnabled)
                        responseData.isEnabled = responseData.isEnabled.toUpperCase() == "TRUE" ? "checked" : "";
                    else
                        responseData.isEnabled = "checked";

                    if (responseData.endDate)
                        responseData.isEnded = responseData.endDate != "1900-01-01" ? "checked" : "";
                    else
                        responseData.isEnded = "";

                    projectForm.innerHTML += convertTemplate.from(innerHTML, responseData);

                    if (responseData.users != null) {
                        var selected = projectForm.querySelector("#users ul.selected");
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
                        if(responseData.files.length < 1)
                            responseData.isfilein = "hidden";
                        else
                            responseData.isfilein = "";
                        var fileList = projectForm.querySelector("#files ul");
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
                        var master = getProjectInput();
                        var param = {};
                        if (isNew) {
                            param = {
                                role: "insertProject",
                                name: master.name,
                                description: master.description,
                                state: master.state,
                                targetDate: master.targetDate,
                                isEnabled: master.isEnabled,
                                userList: JSON.stringify({list: master.userList})
                            };
                        } else {
                            param = {
                                role: "updateProject",
                                idx: master.idx,
                                name: master.name,
                                description: master.description,
                                state: master.state,
                                targetDate: master.targetDate,
                                isEnded: master.isEnded,
                                isEnabled: master.isEnabled,
                                userList: JSON.stringify({list: master.userList})
                            };
                        }

                        api.ajax({
                            type: "POST", url: URL, data: param, contentType: "application/json;",
                            success: function (data) {
                                var responseData = JSON.parse(data);
                                if (api.convert.stringToBoolean(responseData.state)) {
                                    alert((isNew ? "등록" : "수정") + " 하였습니다.");
                                    location.href = backURL;
                                } else {
                                    alert(responseData.message);
                                }
                            }
                        });
                    });
                    api.set.event(document.querySelector("#projectForm .state"), "change", function (e) {
                        var graph = document.querySelector("#projectForm .perfection .percent");
                        var text = document.querySelector("#projectForm .perfection span");

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
                                    var selected = projectForm.querySelector("#users ul.selected");
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
                                    api.set.flexHeight(projectForm);
                                };

                                document.body.appendChild(popup_back);
                                document.body.appendChild(popup);
                            });
                        });
                    });
                    api.const.file = {
                        parentTable: "Project",
                        parent: responseData.idx,
                        file: projectForm.querySelector("#files input[type=file]"),
                        path: null
                    };
                    api.set.event(projectForm.querySelector("#files .uploadFile"),"click", function(){
                        api.upload({
                            parentTable: api.const.file.parentTable,
                            parent: api.const.file.parent,
                            file: api.const.file.file,
                            path: api.const.file.path,
                            success: function (data) {
                                var fileList = projectForm.querySelector("#files ul");
                                var responseData = JSON.parse(data);
                                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                                if (responseData.state) {
                                    var files = {
                                        idx: responseData.idx,
                                        name: responseData.name,
                                        parentTable: api.const.file.parentTable,
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

                                    projectForm.querySelector("#files input[type=file]").value = null;
                                }else{
                                    alert(responseData.message);
                                }
                            }
                        });
                    });
                    if (responseData.stateId)
                        api.set.option(projectForm.querySelector(".state"), responseData.stateId);

                    api.set.flexHeight(projectForm);
                }
                else {
                    alert(responseData.message);
                    history.back();
                }
                callback();
            }
        });
    }
})(this);